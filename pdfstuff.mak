CXXFLAGS=-std=c++17 -O2 -Wall -Wextra `pkg-config --cflags libpodofo`
LDLIBS=`pkg-config --libs libpodofo`
pdfstuff: pdfstuff.cc
	@$(info CXX      $@)$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@
