# KSplit-Boundary

## Build LLVM 15.0
```
./build-llvm.sh
```

## 设置环境变量
```
export LLVM_DIR=/path/to/llvm-15.0/build
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

## Usage
```
1. generate kernel_bc.list/driver_bc.list
2. generate exported_funcs
3. generate driver's global_op_struct_names
4. mv global_op_struct_name /path/to/build/configs/critical-structs
5. ./parse driver_bc.list kernel_bc.list exported_funcs
```
