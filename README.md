# KSplit-Boundary

## Build LLVM 10.0
```
cd llvm-10.0
mkdir build
cd build
cmake -G Ninja -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;compiler-rt;lld" -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_USE_LINKER=gold ..
ninja
```

## 设置环境变量
```
export LLVM_DIR=/path/to/ksplit-boundary/llvm-10.0/build
export PATH=$LLVM_DIR/bin:$PATH
```

## Build parse
```
cd ksplit-boundary
mkdir build
cd build
cmake ..
make
```
