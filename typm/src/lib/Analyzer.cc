//===-- Analyzer.cc - the kernel-analysis framework-------------===//
//
// It constructs a global call-graph based on multi-layer type
// analysis.
//
//===-----------------------------------------------------------===//

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/SystemUtils.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/raw_ostream.h"

#include <memory>
#include <vector>
#include <sstream>
#include <sys/resource.h>
#include <iomanip>

#include "Analyzer.h"
#include "CallGraph.h"
#include "Config.h"


using namespace llvm;

Module *driver_module;

// Command line parameters.
cl::list<std::string> InputFilenames(
    cl::Positional, cl::OneOrMore, cl::desc("<input bitcode files>"));

cl::opt<unsigned> VerboseLevel(
    "verbose-level", cl::desc("Print information at which verbose level"),
    cl::init(0));

cl::opt<int> MLTA(
    "mlta",
	cl::desc("Multi-layer type analysis for refining indirect-call \
		targets"),
	cl::NotHidden, cl::init(0));

cl::opt<int> TyPM(
    "typm",
	cl::desc("Type-based dependence analysis for program modularization \
		targets"),
	cl::NotHidden, cl::init(1));
GlobalContext GlobalCtx;

cl::opt<int> PHASE(
    "phase",
	cl::desc("How many iterations? \
		targets"),
	cl::NotHidden, cl::init(2));


void IterativeModulePass::run(ModuleList &modules) {

	ModuleList::iterator i, e;
	OP << "[" << ID << "] Initializing " << modules.size() << " modules ";
	bool again = true;
	while (again) {
		again = false;
		for (i = modules.begin(), e = modules.end(); i != e; ++i) {
			again |= doInitialization(i->first);
			OP << ".";
		}
	}
	OP << "\n";

	unsigned iter = 0, changed = 1;
	while (changed) {
		++iter;
		changed = 0;
		unsigned counter_modules = 0;
		unsigned total_modules = modules.size();
		for (i = modules.begin(), e = modules.end(); i != e; ++i) {
			OP << "[" << ID << " / " << iter << "] ";
			OP << "[" << ++counter_modules << " / " << total_modules << "] ";
			OP << "[" << i->second << "]\n";

			bool ret = doModulePass(i->first);
			if (ret) {
				++changed;
				OP << "\t [CHANGED]\n";
			} else
				OP << "\n";
		}
		OP << "[" << ID << "] Updated in " << changed << " modules.\n";
	}

	OP << "[" << ID << "] Postprocessing ...\n";
	again = true;
	while (again) {
		again = false;
		for (i = modules.begin(), e = modules.end(); i != e; ++i) {
			// TODO: Dump the results.
			again |= doFinalization(i->first);
		}
	}

	OP << "[" << ID << "] Done!\n\n";
}

void PrintResults(GlobalContext *GCtx) {

	int TotalTargets = 0;
	for (auto IC : GCtx->IndirectCallInsts) {
		TotalTargets += GCtx->Callees[IC].size();
	}
	float AveIndirectTargets = 0.0;
	if (GCtx->NumValidIndirectCalls)
		AveIndirectTargets =
			(float)GCtx->NumIndirectCallTargets/GCtx->IndirectCallInsts.size();

	int totalsize = 0;
	for (auto &curEle: GCtx->Callees) {
		if (curEle.first->isIndirectCall()) {
			totalsize += curEle.second.size();
		}
	}
	OP << "\n@@ Total number of final callees: " << totalsize << "\n";

	OP<<"############## Result Statistics ##############\n";
	cout<<"# Ave. Number of indirect-call targets: \t"<<std::setprecision(5)<<AveIndirectTargets<<"\n";
	OP<<"# Number of indirect calls: \t\t\t"<<GCtx->IndirectCallInsts.size()<<"\n";
	OP<<"# Number of indirect calls with targets: \t"<<GCtx->NumValidIndirectCalls<<"\n";
	OP<<"# Number of indirect-call targets: \t\t"<<GCtx->NumIndirectCallTargets<<"\n";
	OP<<"# Number of address-taken functions: \t\t"<<GCtx->AddressTakenFuncs.size()<<"\n";
	OP<<"# Number of second layer calls: \t\t"<<GCtx->NumSecondLayerTypeCalls<<"\n";
	OP<<"# Number of second layer targets: \t\t"<<GCtx->NumSecondLayerTargets<<"\n";
	OP<<"# Number of first layer calls: \t\t\t"<<GCtx->NumFirstLayerTypeCalls<<"\n";
	OP<<"# Number of first layer targets: \t\t"<<GCtx->NumFirstLayerTargets<<"\n";

}

int typm_driver_init(std::string driver_ko) {
    SMDiagnostic Err;
    LLVMContext *LLVMCtx = new LLVMContext();
	std::unique_ptr<Module> M = parseIRFile(driver_ko, Err, *LLVMCtx);

    if (M == NULL) {
        OP << "typm: error loading file '"
				<< driver_ko << "'\n";
		return -1;
    }

    Module *Module = M.release();
    driver_module = Module;
	StringRef MName = StringRef(strdup(driver_ko.data()));
	GlobalCtx.Modules.push_back(std::make_pair(Module, MName));
	GlobalCtx.ModuleMaps[Module] = driver_ko;

    // ENABLE_MLTA = MLTA;
	// ENABLE_TYDM = TyPM;
	// MAX_PHASE_CG = PHASE;
	// if (!ENABLE_TYDM)
	// 	MAX_PHASE_CG = 1;

	// CallGraphPass CGPass(&GlobalCtx);
	// // CGPass.run(GlobalCtx.Modules);
    // CGPass.doInitialization(Module);

    return 0;
}

int typm_kernel_init(std::vector<std::string> &kernel_list) {
    SMDiagnostic Err;
    for (auto kernel_bc : kernel_list) {
        LLVMContext *LLVMCtx = new LLVMContext();
		std::unique_ptr<Module> M = parseIRFile(kernel_bc, Err, *LLVMCtx);
        if (M == NULL) {
            OP << "typm: error loading file '"
				<< kernel_bc << "'\n";
			continue;
        }

        Module *Module = M.release();
		StringRef MName = StringRef(strdup(kernel_bc.data()));
		GlobalCtx.Modules.push_back(std::make_pair(Module, MName));
		GlobalCtx.ModuleMaps[Module] = kernel_bc;
    }

    return 0;
}

std::unordered_map<std::string, std::set<std::string>>
typm_init(std::string driver_ko, std::vector<std::string> &kernel_list, std::string func_list) {
	typm_driver_init(driver_ko);
    typm_kernel_init(kernel_list);
	//
	// Main workflow
	//

	// Build global callgraph.
	
	ENABLE_MLTA = MLTA;
	ENABLE_TYDM = TyPM;
	MAX_PHASE_CG = PHASE;
	if (!ENABLE_TYDM)
		MAX_PHASE_CG = 1;

	CallGraphPass CGPass(&GlobalCtx);
	CGPass.run(GlobalCtx.Modules);
	//CGPass.processResults();

#ifdef MAP_CALLER_TO_CALLEE
    std::unordered_map<std::string, std::set<std::string>> result;   
    std::ifstream target_funcs(func_list);
    if (!target_funcs.is_open()) {
        errs() << "error when loading : " << func_list << "\n";
    }
    std::string func_name;
    while (std::getline(target_funcs, func_name)) {
        Function *func = driver_module->getFunction(func_name);
        if (!func) {
            errs() << "cannot find " << func->getName() << "\n";
            continue;
        }
        outs() << "dump result for " << func->getName() << "\n";
        for (auto filename : GlobalCtx.CallerFiles[func]) {
            outs() << filename << "\n";
            result[func->getName().str()].insert(filename);
        }
    }
#endif

	// Print final results
	PrintResults(&GlobalCtx);

	return result;
}

