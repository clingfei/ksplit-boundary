
CXX := clang++
CXXFLAGS += -g -std=c++2a
CXXFLAGS += -I /usr/include/llvm-10 -I /usr/include/llvm-c-10/


LD_FLAGS += -lLLVM-10

all:
	$(CXX) -o parse parse.cpp $(CXXFLAGS) $(LD_FLAGS)

.PHONY = clean

clean:
	@rm -f parse
