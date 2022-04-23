CXXFLAGS=-std=c++17 -O2 -Wall -Wextra
LDLIBS=-lpodofo
pdfstuff: pdfstuff.cc
	@$(info CXX      $@)$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@
