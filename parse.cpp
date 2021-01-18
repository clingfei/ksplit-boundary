#include <iostream>

#include <string>
#include <set>
#include <list>
#include <fstream>
#include <unordered_map>

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

const char* PROG_NAME = "ksplit-bnd";

void usage() {
  cout << PROG_NAME << " <driver.bc> <files.txt> " << endl;
  cout << "\t files.txt contains the absolute path of all the individual bc files in the kernel except drivers dir" << endl;
  cout << "\t e.g., /kernel/path/init/main.bc" << endl;
  cout << "\t by default, this program ignores built-in.o.bc" << endl;
  exit(0);
}

using LiblcdFuncs = std::set<std::string>;
using IRModule = std::unique_ptr<Module>;

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

// Synchronous functions
// 1) Find the list of declared (but not defined) functions in the driver bc file
// 2) Parse all the bc files that would eventually go into vmlinux.bc (except drivers folder)
// 3) Extract a list of bc files in the kernel that has the definitions of the undefined functions in step 1
int main(int argc, char const *argv[]) {
  LLVMContext context;
  SMDiagnostic error;

  std::unordered_map<std::string, IRModule> kernel_bc_map;
  std::unordered_map<std::string, std::set<std::string>> kernel_bc_funcs_map;
  std::set<std::string> needed_kernel_funcs;

  if (argc != 4) {
    usage();
  }

  std::string driver_bc(argv[1]);
  std::string kernel_bc_fname(argv[2]);
  std::string liblcd_funcs(argv[3]);

  std::ifstream kernel_bc_file(kernel_bc_fname);
  populateLiblcdFuncs(liblcd_funcs);

  IRModule driver_mod = parseIRFile(driver_bc, error, context);

  auto dr_mod = driver_mod.get();
  cout << "driver module: " << dr_mod->getName().data() << endl;
  for (Function &fn: *dr_mod) {
    // cout << "Checking " << fn.getName().str() << endl;
    if (fn.isIntrinsic()) {
      continue;
    }

    if (fn.isDeclaration() && (liblcdSet->find(std::string(fn.getName().str())) == liblcdSet->end())) {
      cout << fn.getName().data() << endl;
      needed_kernel_funcs.insert(fn.getName().str());
    } /*else {
      cout << "definition found or liblcd: " << fn.getName().str() << endl;
    }*/
  }

  if (kernel_bc_file.is_open()) {
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
    while (std::getline(kernel_bc_file, line)) {
      if (skip_line(line)) {
        // skip this line
        continue;
      }
      // printf("%s\n", line.c_str());
      IRModule mod = parseIRFile(line, error, context);
 
      auto extract_funcs = [&](auto M) {
        std::set<std::string> needed_funcs;
        // cout << "Module : " << M->getModuleIdentifier() << endl;
        for (Function &fn: *M) {
          if (fn.isDeclaration() || fn.empty()) {// || liblcdSet->find(fn.getName()) != liblcdSet->end()) {
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
        kernel_bc_map[line] = std::move(mod);
      } else {
        cout << "Skipping: " << line << endl;
      }
    }
    kernel_bc_file.close();
  }

  cout << "Done!" << endl;
  for (auto &kv : kernel_bc_funcs_map) {
    cout << kv.first << "\n";
    for (auto &fn : kv.second) {
      cout << "\t" << fn.data() << "\n";
    }
  }
}
