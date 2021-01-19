#include <iostream>

#include <string>
#include <set>
#include <list>
#include <fstream>
#include <unordered_map>

#include <llvm/IR/Attributes.h>
#include <llvm/IR/Module.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/GenericValue.h>

using std::unique_ptr;
using std::cout;
using std::endl;

using llvm::Module;
using llvm::SMDiagnostic;
using llvm::LLVMContext;
using llvm::parseIRFile;
using llvm::StringRef;
using llvm::ExecutionEngine;
using llvm::EngineBuilder;
using llvm::ArrayRef;
using llvm::GenericValue;
using llvm::Function;
using llvm::AttributeList;
using llvm::Attribute;

const char* PROG_NAME = "ksplit-bnd";

void usage() {
  cout << PROG_NAME << " <driver.bc> <files.txt> <liblcd_funcs.txt>" << endl;
  cout << "\t files.txt contains the absolute path of all the individual bc files in the kernel except drivers dir" << endl;
  cout << "\t e.g., /kernel/path/init/main.bc" << endl;
  cout << "\t by default, this program ignores built-in.o.bc" << endl;
  exit(0);
}

using LiblcdFuncs = std::set<std::string>;
using IRModule = std::unique_ptr<Module>;
using KernelModulesMap = std::unordered_map<std::string, std::set<std::string>>;
using StringSet = std::set<std::string>;


LiblcdFuncs *liblcdSet;

void populateLiblcdFuncs(std::string fname) {
  std::ifstream liblcd_funcs(fname);

  if (!liblcdSet) {
    liblcdSet = new std::set<std::string>();
  }

  if (liblcd_funcs) {
    for (std::string line; std::getline(liblcd_funcs, line);) {
      liblcdSet->insert(line);
    }
  }
}

StringSet getUndefinedFuncs(std::unique_ptr<Module> &mod_ptr) {
  auto module = mod_ptr.get();
  StringSet undefined_fns;

  cout << __func__ << ": module: " << module->getModuleIdentifier() << endl;

  for (Function &fn: *module) {
    // cout << "Checking " << fn.getName().str() << endl;
    if (fn.isIntrinsic()) {
      continue;
    }

    if (fn.isDeclaration() && (liblcdSet->find(std::string(fn.getName().str())) == liblcdSet->end())) {
      cout << fn.getName().data() << endl;
      undefined_fns.insert(fn.getName().str());
    }
  }
  return undefined_fns;
}

StringSet getDefinedFuncs(std::unique_ptr<Module> &mod_ptr) {
  auto module = mod_ptr.get();
  StringSet defined_fns;

  cout << __func__ << ": module: " << module->getModuleIdentifier() << endl;

  for (Function &fn: *module) {
    // cout << "Checking " << fn.getName().str() << endl;
    if (fn.isIntrinsic()) {
      continue;
    }

    // cout << fn.getFunctionType()->printLeft() << endl;
    //if (fn.getAttributes().hasAttribute(AttributeList::FunctionIndex, Attribute::InlineHint))
    if (fn.hasLocalLinkage())
      cout << "Inline function " << fn.getName().data() << endl;
    if (!fn.isDeclaration()) {// && fn.getFunctionType() == llvm::GlobalValue::ExternalLinkage) {
      cout << fn.getName().data() << endl;
      defined_fns.insert(fn.getName().str());
    }
  }
  return defined_fns;
}

KernelModulesMap synchronousPass(std::string driver_bc, std::string kernel_bc) {
  KernelModulesMap kernel_bc_funcs_map;
  StringSet needed_kernel_funcs;

  LLVMContext context;
  SMDiagnostic error;

  std::ifstream kernel_bc_files(kernel_bc);

  IRModule driver_mod = parseIRFile(driver_bc, error, context);

  needed_kernel_funcs = getUndefinedFuncs(driver_mod);

  if (kernel_bc_files.is_open()) {
    std::string line;
    // TODO: Exclusions should not omit files from drivers/base
    std::list<std::string> exclusions = {
      "..", "builtin", "/drivers/"};
    auto skip_line = [&](auto line) {
      bool ok = false;
      for (auto &s : exclusions) {
          ok |= (line.find(s) != std::string::npos);
      }
      return ok;
    };
    while (std::getline(kernel_bc_files, line)) {
      if (skip_line(line)) {
        // skip this line
        continue;
      }
      IRModule mod = parseIRFile(line, error, context);

      auto extract_funcs = [&](auto M) {
        std::set<std::string> needed_funcs;
        // cout << "Module : " << M->getModuleIdentifier() << endl;
        for (Function &fn: *M) {
          if (fn.isDeclaration() || fn.empty()) {
            continue;
          } else if (needed_kernel_funcs.find(fn.getName().str()) != needed_kernel_funcs.end()) {
            // we need this bc file for kernel.bc
            // cout << "\tMatched function " << fn.getName().data() << endl;
            needed_funcs.insert(fn.getName().str());
          }
        }
        return needed_funcs;
      };

      if (mod) {
        auto needed_list = extract_funcs(mod.get());
        if (!needed_list.empty()) {
          kernel_bc_funcs_map[line] = needed_list;
        }
        //kernel_bc_map[line] = std::move(mod);
      } else {
        cout << "Skipping: " << line << endl;
      }
    }
    kernel_bc_files.close();
  }
  return kernel_bc_funcs_map;
}

void asynchronousPass(std::string driver_bc, std::string kernel_bc) {
  KernelModulesMap kernel_bc_funcs_map;
  StringSet needed_kernel_funcs;

  LLVMContext context;
  SMDiagnostic error;

  std::ifstream kernel_bc_files(kernel_bc);

  IRModule driver_mod = parseIRFile(driver_bc, error, context);

  needed_kernel_funcs = getDefinedFuncs(driver_mod);

#if 0
  if (kernel_bc_files.is_open()) {
    std::string line;
    std::list<std::string> exclusions = {
      "..", "builtin", "/drivers/"};
    auto skip_line = [&](auto line) {
      bool ok = false;
      for (auto &s : exclusions) {
          ok |= (line.find(s) != std::string::npos);
      }
      return ok;
    };
    while (std::getline(kernel_bc_files, line)) {
      if (skip_line(line)) {
        // skip this line
        continue;
      }
      IRModule mod = parseIRFile(line, error, context);
 
      auto extract_funcs = [&](auto M) {
        std::set<std::string> needed_funcs;
        // cout << "Module : " << M->getModuleIdentifier() << endl;
        for (Function &fn: *M) {
          if (fn.isDeclaration() || fn.empty()) {
            continue;
          } else if (needed_kernel_funcs.find(fn.getName().str()) != needed_kernel_funcs.end()) {
            // we need this bc file for kernel.bc
            // cout << "\tMatched function " << fn.getName().data() << endl;
            needed_funcs.insert(fn.getName().str());
          }
        }
        return needed_funcs;
      };

      if (mod) {
        auto needed_list = extract_funcs(mod.get());
        if (!needed_list.empty()) {
          kernel_bc_funcs_map[line] = needed_list;
        }
        //kernel_bc_map[line] = std::move(mod);
      } else {
        cout << "Skipping: " << line << endl;
      }
    }
    kernel_bc_files.close();
  }
  return kernel_bc_funcs_map;
#endif
}

// Synchronous functions
// 1) Find the list of declared (but not defined) functions in the driver bc file
// 2) Parse all the bc files that would eventually go into vmlinux.bc (except drivers folder)
// 3) Extract a list of bc files in the kernel that has the definitions of the undefined functions in step 1
int main(int argc, char const *argv[]) {
  LLVMContext context;
  SMDiagnostic error;

  std::unordered_map<std::string, IRModule> kernel_bc_map;

  if (argc != 4) {
    usage();
  }

  std::string driver_bc(argv[1]);
  std::string kernel_bc_files(argv[2]);
  std::string liblcd_funcs(argv[3]);

  populateLiblcdFuncs(liblcd_funcs);

  auto kernel_bc_funcs_map = synchronousPass(driver_bc, kernel_bc_files);

  cout << "Synchronous pass Done!" << endl;

  for (auto &kv : kernel_bc_funcs_map) {
    cout << kv.first << "\n";
    for (auto &fn : kv.second) {
      cout << "\t" << fn.data() << "\n";
    }
  }

  asynchronousPass(driver_bc, kernel_bc_files);
}
