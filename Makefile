
CXX := clang++
CXXFLAGS += -g -std=c++2a -Wall
# if running with nix, comment this out
# CXXFLAGS += -I /usr/include/llvm-10 -I /usr/include/llvm-c-10/
CXXFLAGS += -I /home/clf/clang-10.0.1/include/

LD_FLAGS += -lLLVM

all:
	$(CXX) -o parse parse.cpp $(CXXFLAGS) $(LD_FLAGS)

.PHONY = clean

clean:
	@rm -f parse
