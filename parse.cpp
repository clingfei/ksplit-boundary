#include <iostream>

#include <filesystem>
#include <fstream>
#include <iterator>
#include <list>
#include <llvm/IR/AbstractCallSite.h>
#include <llvm/IR/Attributes.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Support/SourceMgr.h>
#include <map>
#include <set>
#include <string>
#include <unordered_map>

#include "typm/src/lib/CallGraph.h"

// #define DEBUG

using std::cout;
using std::endl;
using std::unique_ptr;

using llvm::ArrayRef;
using llvm::Attribute;
using llvm::AttributeList;
// using llvm::AbstractCallSite;
using llvm::CallInst;
using llvm::dyn_cast;
using llvm::Function;
using llvm::LLVMContext;
using llvm::Module;
using llvm::outs;
using llvm::parseIRFile;
using llvm::SMDiagnostic;
using llvm::StringRef;

// Typedef
using String = std::string;
using IRModule = std::unique_ptr<Module>;
using StringSet = std::set<String>;
using IRModuleMap = std::unordered_map<String, IRModule>;
using KernelModulesMap = std::unordered_map<String, StringSet>;
using ModuleMap =
    std::unordered_map<String, std::pair<KernelModulesMap, KernelModulesMap>>;
namespace fs = std::filesystem;
using Path = fs::path;

const char *PROG_NAME = "ksplit-bnd";
constexpr auto bc_files_dir = "/home/clf/linux-5.10.100-device/bc-files";
const Path BC_FILES_REPO = Path(bc_files_dir);

// platform_register/device_register均在drivers/base目录下

const std::list<std::string> device_types = {
    "struct.platform_device", "struct.device", "struct.rtc_device"};

const std::list<std::string> driver_types = {"struct.platform_driver",
                                             "struct.device_driver"};

const std::map<String, String> driverClassMap = {
    {"arch/arm64", "arch_arm64"},
    {"drivers/base/regmap", "regmap"},
    {"drivers/block", "block"},
    {"drivers/char", "char"},
    {"drivers/edac", "edac"},
    {"drivers/firmware", "firmware"},
    {"drivers/foobar", "foobar"},
    {"drivers/hwmon", "hwmon"},
    {"drivers/input", "input"},
    {"drivers/i2c", "i2c"},
    {"drivers/leds", "leds"},
    {"drivers/misc", "misc"},
    {"drivers/net", "net_ethernet"},
    {"drivers/pci/hotplug", "pci_hotplug"},
    {"drivers/gpu", "gpu"},
    {"drivers/md", "md"},
    {"sound/soc/codecs", "sound"},
    {"drivers/nvme", "block"},
    {"drivers/powercap", "powercap"},
    {"drivers/pinctrl", "pinctrl"},
    {"drivers/i2c", "i2c"},
    {"drivers/spi", "spi"},
    {"drivers/w1", "one-wire"},
    {"drivers/usb", "usb"},
    {"drivers/tty", "tty"}};

void usage() {
  cout << PROG_NAME << " <drivers_bc_list> <kernel_bc_list>" << endl;
  cout << "\t <drivers_bc_list> contains the absolute path of all driver.ko.bc "
          "files"
       << endl;
  cout << "\t <kernel_bc_list> contains the absolute path of all the "
          "individual bc "
          "files in the kernel"
       << endl;
  exit(0);
}

String getDriverClass(String ko_file) {
  String class_name;

  for (auto &e : driverClassMap) {
    if (ko_file.find(e.first) != String::npos) {
      class_name = e.second;
      break;
    }
  }
  if (class_name.empty()) {
    cout << "class name empty for " << ko_file << endl;
  }
  cout << "class_name: " << class_name << endl;
  return class_name;
}
// 记录extern的全局变量名
StringSet getUndefinedGlobals(std::unique_ptr<Module> &mod_ptr) {
  auto module = mod_ptr.get();
  StringSet undefined_globals;

  cout << __func__ << ": module: " << module->getModuleIdentifier() << endl;

  for (auto &g : module->getGlobalList()) {
    if (g.isDeclaration()) {
      undefined_globals.insert(g.getName().str());
      /*cout << g.getName().str() << " is_ext: " << g.isExternallyInitialized()
          << " hasInitializer: " << g.hasInitializer()
          << " isDecl: " << g.isDeclaration()
          << " \n";*/
    }
  }

  return undefined_globals;
}
// 记录extern的函数名
StringSet getUndefinedFuncs(std::unique_ptr<Module> &mod_ptr) {
  auto module = mod_ptr.get();
  StringSet undefined_fns;

  cout << __func__ << ": module: " << module->getModuleIdentifier() << endl;

  for (Function &fn : *module) {
    // cout << "Checking " << fn.getName().str() << endl;
    if (fn.isIntrinsic()) {
      continue;
    }

    if (fn.isDeclaration()) {
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

  for (Function &fn : *module) {
    // cout << "Checking " << fn.getName().str() << endl;
    if (fn.isIntrinsic()) {
      continue;
    }

    if (fn.hasLocalLinkage())
      cout << "Inline function " << fn.getName().data() << endl;
    if (!fn.isDeclaration()) { // && fn.getFunctionType() ==
      // llvm::GlobalValue::ExternalLinkage) {
      cout << fn.getName().data() << endl;
      defined_fns.insert(fn.getName().str());
    }
  }
  return defined_fns;
}

StringSet extract_transitive_closures(Module *M,
                                      StringSet &needed_kernel_funcs) {
  StringSet needed_funcs;
  // cout << "Module : " << M->getModuleIdentifier() << endl;
  for (auto &F : *M) {
    if (F.isDeclaration() || F.empty()) {
      continue;
    } else if (needed_kernel_funcs.find(F.getName().str()) !=
               needed_kernel_funcs.end()) {
      // we need this bc file for kernel.bc
      // cout << "\tMatched function " << fn.getName().data() << endl;
      for (auto &bb : F) {
        for (auto &I : bb) {

          // auto cs = AbstractCallSite(&I);
          // if (!cs.getInstruction())
          // {
          //   continue;
          // }
          // auto called = cs.getCalledValue()->stripPointerCasts();
          // auto fun = dyn_cast<Function>(called);
          // if (fun)
          // {
          //   if (fun->isDeclaration() || fun->empty() || fun->isIntrinsic())
          //     continue;
          //   cout << "Called func : " << fun->getName().str() << endl;
          //   needed_funcs.insert(fun->getName().str());
          // }
          auto cs = dyn_cast<CallInst>(&I);
          if (!cs) {
            continue;
          }
          auto fun = cs->getCalledFunction();
          if (fun) {
            if (fun->isDeclaration() || fun->empty() || fun->isIntrinsic())
              continue;
            cout << "Called func : " << fun->getName().str() << endl;
            needed_funcs.insert(fun->getName().str());
          }
        }
      }
      needed_funcs.insert(F.getName().str());
    }
  }
  return needed_funcs;
}

// Filter out the kernel bc files by keeping the files we need for the analysis
std::pair<KernelModulesMap, KernelModulesMap>
filterKernelBcFiles(String kernel_bc_list) {
  KernelModulesMap kernel_map;
  KernelModulesMap kernel_global_map;
  std::ifstream kernel_bc_files(kernel_bc_list);

  if (kernel_bc_files.is_open()) {
    String line;
    // driver_dirs中包含的是drivers下面的不应该被过滤掉的路径
    std::list<String> driver_dirs = {
        "drivers/base",
        // "drivers/edac/edac_mc",
        // "drivers/clk",
        // "drivers/acpi",
        // "drivers/powercap",
        // "drivers/ptp",
        // "drivers/oprofile",
        "drivers/rtc/.rtc-lib",
        "drivers/rtc/.interface",
        // "drivers/input",
        // "drivers/pci",
        // "drivers/edac/.edac_mc",
        // "drivers/i2c",
        // "drivers/gpu/drm/.drm",
        // "drivers/md",
        // "drivers/misc/mei/",
        // "drivers/net/.mdio",
        // "drivers/hwmon/.hwmon",
        // "drivers/nvme/host/.core",
        // "drivers/usb/core",
    };

    std::list<String> exclusions = {
        "..", "builtin", "drivers/", ".mod.o.bc", ".ko.bc", "arch/arm64/boot",
        "sound", "crypto", "kasan", "kcsan", "printk",
        // added by myself
        /*
         * Error:
         * Attribute 'elementtype' can only be applied to intrinsics.
         * LLVM ERROR: Broken module found, compilation aborted!
         */
        // Error: Attribute 'elementtype' can only be applied to intrinsics.
        "kernel/trace/.trace_irqsoff.o.bc",
        "kernel/trace/.trace_functions_graph.o.bc", "kernel/trace/.fgraph.o.bc",
        "kernel/trace/.trace_hwlat.o.bc",
        "kernel/trace/.preemptirq_delay_test.o.bc",
        "kernel/trace/.preemptirq_delay_test.o.bc",
        "kernel/trace/.tracing_map.o.bc", "kernel/trace/.trace_kdb.o.bc",
        "kernel/trace/.trace_preemptirq.o.bc", "kernel/trace/.trace_stack.o.bc",
        "kernel/trace/"};

    auto skip_line = [&](auto line) {
      // Check if the line contains any of the exclusion list
      for (auto &s : exclusions) {
        auto pos = line.find(s);
        if (pos != String::npos) {
          // if a valid match is found, check if it is one of the driver_dirs
          // we need. If needed, do not skip
          for (auto &s1 : driver_dirs) {
            auto pos2 = line.find(s1);
            if (pos2 != String::npos) {
              return false;
            }
          }
          return true;
        }
      }
      return false;
    };

    while (std::getline(kernel_bc_files, line)) {
      if (skip_line(line)) {
        continue;
      }
      LLVMContext context;
      SMDiagnostic error;
#ifdef DEBUG
      std::cout << "parsing IR file: " << line << "\n";
#endif
      IRModule mod = parseIRFile(line, error, context);
      if (mod) {
        StringSet kernel_funcs;
        StringSet kernel_globs;

        for (Function &fn : *mod.get()) {
          if (fn.isDeclaration() || fn.empty()) {
            continue;
          }
          kernel_funcs.insert(fn.getName().str());
        }
#ifdef DEBUG
        std::cout
            << "===================dumping kernel_funcs=====================\n";
        std::cout << "There are " << kernel_funcs.size() << " kernel funcs\n";
// for (auto str : kernel_funcs) {

// }
#endif
        for (auto &g : mod->getGlobalList()) {
          if (g.isDeclaration()) {
            continue;
          }
          if (g.hasExternalLinkage() && g.isDefinitionExact() &&
              !g.isDeclaration()) {
            // cout << g.getName().str() << "\n";
            kernel_globs.insert(g.getName().str());
          }
        }
        // 记录的是文件名到内核函数的映射
        kernel_map.insert(std::make_pair(line, kernel_funcs));
        // 记录的是文件名到内核全局变量的映射
        kernel_global_map.insert(std::make_pair(line, kernel_globs));
      } else {
#ifdef DEBUG
        cout << "parseIR error\n";
        error.print("", outs());
        cout << "\n";
#endif
        cout << "Skipping: " << line << endl;
      }
    }
  }
  return std::make_pair(kernel_map, kernel_global_map);
}

std::pair<KernelModulesMap, KernelModulesMap>
synchronousPass(String driver_bc, KernelModulesMap kernel_map,
                KernelModulesMap kernel_glob_map) {
  KernelModulesMap kernel_bc_funcs_map;
  KernelModulesMap kernel_bc_globs_map;
  StringSet needed_kernel_funcs;
  StringSet needed_kernel_globs;

  LLVMContext context;
  SMDiagnostic error;

  IRModule driver_mod = parseIRFile(driver_bc, error, context);

  if (!driver_mod) {
    cout << "Couldn't parse IR file " << driver_bc << "\n";
    error.print("", outs());
    outs() << "\n";
    return std::make_pair(kernel_bc_funcs_map, kernel_bc_globs_map);
  }

  needed_kernel_funcs = getUndefinedFuncs(driver_mod);
  needed_kernel_globs = getUndefinedGlobals(driver_mod);

  auto extract_funcs = [&](auto M) {
    std::set<String> needed_funcs;
    // cout << "Module : " << M->getModuleIdentifier() << endl;
    for (Function &fn : *M) {
      if (fn.isDeclaration() || fn.empty()) {
        continue;
      } else if (needed_kernel_funcs.find(fn.getName().str()) !=
                 needed_kernel_funcs.end()) {
// we need this bc file for kernel.bc
#ifdef DEBUG
        cout << "\tMatched function " << fn.getName().data() << endl;
#endif
        needed_funcs.insert(fn.getName().str());
      }
    }
    return needed_funcs;
  };

  auto extract_needed_funcs = [&](auto set) {
    StringSet needed_funcs;
    for (auto &fn : set) {
      if (needed_kernel_funcs.find(fn) != needed_kernel_funcs.end()) {
        // we need this bc file for kernel.bc
        // cout << "\tMatched function " << fn.getName().data() << endl;
        needed_funcs.insert(fn);
      }
    }
    return needed_funcs;
  };

  for (auto &bc : kernel_map) {
    StringSet funcs = bc.second;

    auto needed_list = extract_needed_funcs(funcs);
    // auto needed_list = extract_transitive_closures(mod.get(),
    // needed_kernel_funcs);
    if (!needed_list.empty()) {
      kernel_bc_funcs_map[bc.first] = needed_list;
    }
    // kernel_bc_map[line] = std::move(mod);
  }

  auto extract_needed_globs = [&](auto set) {
    StringSet needed_globs;
    for (auto &g : set) {
      if (needed_kernel_globs.find(g) != needed_kernel_globs.end()) {
        // we need this bc file for kernel.bc
        // cout << "\tMatched function " << fn.getName().data() << endl;
        needed_globs.insert(g);
      }
    }
    return needed_globs;
  };

  for (auto &bc : kernel_glob_map) {
    StringSet globs = bc.second;

    auto needed_list = extract_needed_globs(globs);
    // auto needed_list = extract_transitive_closures(mod.get(),
    // needed_kernel_funcs);
    if (!needed_list.empty()) {
      kernel_bc_globs_map[bc.first] = needed_list;
    }
    // kernel_bc_map[line] = std::move(mod);
  }

  return std::make_pair(kernel_bc_funcs_map, kernel_bc_globs_map);
}

// synchronous:
// list of functions directly reached from the driver
// asynchronous:
// list of call sites that indirectly invoke the driver functions
// 1) which driver function are passed across the boundary (i.e., registered
// with a subsystem)
KernelModulesMap asynchronousPass(String driver_bc, KernelModulesMap kernel_map,
                                  std::string func_list) {
  KernelModulesMap kernel_bc_funcs_map;
  StringSet needed_kernel_funcs;

  LLVMContext context;
  SMDiagnostic error;

  IRModule driver_mod = parseIRFile(driver_bc, error, context);
  std::vector<std::string> kernel_list;

  needed_kernel_funcs = getDefinedFuncs(driver_mod);
  // 调用typm的函数，初始化需要处理的函数指针

  for (auto &iter : kernel_map) {
    kernel_list.push_back(iter.first);
  }
  return typm_init(driver_bc, kernel_list, func_list);
}

// Synchronous functions
// 1) Find the list of declared (but not defined) functions in the driver bcfile
// 2) Parse all the bc files that would eventually go into vmlinux.bc (except
// drivers folder) 3) Extract a list of bc files in the kernel that has the
// definitions of the undefined functions in step 1
int main(int argc, char const *argv[]) {
  LLVMContext context;
  SMDiagnostic error;

  std::unordered_map<String, IRModule> kernel_bc_map;

  if (argc != 4) {
    usage();
  }

  String driver_list(argv[1]);
  String kernel_list(argv[2]);
  StringSet drivers;

  ModuleMap ko_map;
  std::unordered_map<string, std::set<string>> async_results;

  std::ifstream driver_bc_files(driver_list);

  auto [kernel_map, kernel_glob_map] = filterKernelBcFiles(kernel_list);

  if (driver_bc_files.is_open()) {
    String driver_ko;
    while (std::getline(driver_bc_files, driver_ko)) {
      drivers.insert(driver_ko);
      auto [kernel_bc_funcs_map, kernel_bc_globs_map] =
          synchronousPass(driver_ko, kernel_map, kernel_glob_map);
      for (auto &[k, v] : kernel_bc_globs_map) {
        cout << k << ": \n";
        for (auto &s : v) {
          cout << "\t" << s << "\n";
        }
      }
      ko_map[driver_ko] =
          std::make_pair(kernel_bc_funcs_map, kernel_bc_globs_map);
    }
  }

  cout << "Synchronous pass Done!" << endl;

  for (auto driver_ko : drivers) {
    // kernel_bc_funcs_map records the mapping from driver's exported_funcs to
    // its possible callers.
    auto kernel_bc_funcs_map = asynchronousPass(driver_ko, kernel_map, argv[3]);
    for (auto iter = kernel_bc_funcs_map.begin();
         iter != kernel_bc_funcs_map.end(); iter++) {
      // ko_map[driver_ko].first 是string 到stringset的映射
      for (auto filename : iter->second) {
        async_results[driver_ko].insert(filename);
      }
    }
  }

  cout << "Asynchronous pass Done!" << endl;

  for (auto &mod : ko_map) {
    Path ko_path(mod.first);
    auto ko_name = ko_path.stem().stem();
    auto ko_fname = ko_path.filename();
    auto driver_class = getDriverClass(mod.first);
    Path kernel_bc = ko_name;
    kernel_bc += "_kernel.bc";
    auto linked_kernel_bc = ko_path.replace_filename(kernel_bc);
    cout << "kernel bc: " << linked_kernel_bc << endl;
    Path dest;
    dest += BC_FILES_REPO;
    dest /= driver_class;
    dest /= ko_name;

    cout << "========= " << mod.first << " =========" << endl;

    // prepare args for llvm-link
    // String llvm_link_args("llvm-link -only-needed -o ");
    String llvm_link_args("llvm-link -only-needed -o ");
    llvm_link_args += linked_kernel_bc;

    String kernel_bc_files;
    StringSet kernel_bc_set;

    // collect the kernel.bc files that are needed for generating
    // driver_kernel.bc
    auto &[func_map, glob_map] = mod.second;
    for (auto &kv : func_map) {
      cout << kv.first << "\n";
      // kv.first里面保存的是文件名
      kernel_bc_set.insert(kv.first);
      // kernel_bc_files += " " + kv.first;
    }

    for (auto &kv : glob_map) {
      cout << kv.first << "\n";
      // kernel_bc_files += " " + kv.first;
      kernel_bc_set.insert(kv.first);
    }

    std::ofstream bc_set("kernel_bc_set");
    bc_set << "===================================synchronous result=========================\n";
    for (auto &bc : kernel_bc_set) {
      bc_set << bc << "\n";
    }
    bc_set << "===================================asynchronous result=========================\n";
    // collect the kernel.bc files that are needed for generating
    // driver_kernel.bc
    for (auto filename : async_results[mod.first]) {
      kernel_bc_set.insert(filename);
    }
    bc_set.close();

    for (auto &bc : kernel_bc_set) {
      kernel_bc_files += " " + bc;
    }

    if (kernel_bc_files.empty()) {
      cout << "No matching kernel_bc files found! skipping " << mod.first
           << endl;
      continue;
    }

    llvm_link_args += kernel_bc_files;
    cout << llvm_link_args << endl;

    // invoke llvm-link
    auto fp = popen(llvm_link_args.c_str(), "r");

    if (!fp) {
      cout << "Cmd: " << llvm_link_args << " failed!\n" << endl;
      // TODO: Do what now?
      continue;
    }

    String out_buffer;
    std::array<char, 256> buffer;
    while (fgets(buffer.data(), 256, fp) != NULL) {
      out_buffer += buffer.data();
    }

    if (!out_buffer.empty()) {
      cout << "cmd output: " << out_buffer << endl;
    }
    // auto ret = std::system(llvm_link_args.c_str());
    // cout << "exit status : " << WEXITSTATUS(ret) << endl;

    // create dest dir if !exists
    if (!fs::exists(dest)) {
      cout << "Creating " << dest << endl;
      fs::create_directories(dest);
    }

    // Copy driver.ko.bc file
    cout << "1. Copy " << mod.first << " -> " << dest / ko_fname << endl;
    fs::copy_file(mod.first, dest / ko_fname,
                  fs::copy_options::overwrite_existing);

    // Copy driver_kernel.ko.bc file
    cout << "2. Copy " << linked_kernel_bc << " -> " << dest / kernel_bc
         << endl;
    fs::copy_file(linked_kernel_bc, dest / kernel_bc,
                  fs::copy_options::overwrite_existing);
    cout << "======================" << endl;
  }
}
