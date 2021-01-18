
CXXFLAGS += -g -std=c++2a
CXXFLAGS += -I /usr/include/llvm-6.0 -I /usr/include/llvm-c-6.0/


LD_FLAGS += -lLLVM-6.0

all:
	g++ -o parse parse.cpp $(CXXFLAGS) $(LD_FLAGS) 

.PHONY = clean

clean:
	@rm -f parse
