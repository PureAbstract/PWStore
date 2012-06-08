### Configuration
INCLUDE_DIRS=../Classes ../OSX_Support ../../Catch/single_include /usr/include/libxml2
SOURCE_DIRS=. ../Classes ../OSX_Support

FRAMEWORKS=Foundation Security
LIBS=stdc++ xml2
BUILDDIR=build
TESTS = Tests


# object files for 'Tests'
Tests_objects = Tests.o NSCompoundStream.o NSData+AES.o OSX_SecRandom.o NSData+BlockAES.o XmlDocument.o NSData+CryptoHash.o

## Output Directories
BINDIR=$(BUILDDIR)/bin
OBJDIR=$(BUILDDIR)/obj
DIRS = $(BUILDDIR) $(BINDIR) $(OBJDIR)

vpath %.m  $(SOURCE_DIRS)
vpath %.mm $(SOURCE_DIRS)
vpath %.h  $(SOURCE_DIRS)
vpath %.o  $(OBJDIR)

OCFLAGS= -Wextra -Wall
## Rules
MMFRAMEWORKS=$(foreach framework,$(FRAMEWORKS),-framework $(framework))
INCLUDES=$(foreach include,$(INCLUDE_DIRS),-I $(include))
LIBRARIES=$(foreach lib,$(LIBS),-l$(lib))
COMPILE.objc   = gcc $(OCFLAGS) $(INCLUDES) -x objective-c -c -o $@ $<
COMPILE.objcxx = gcc $(OCFLAGS) $(INCLUDES) -x objective-c++ -c -o $@ $<
LINK.objc   = gcc $(MMFRAMEWORKS)
LINK.objcxx = $(LINK.objc) $(LIBRARIES) -o $@ $^

$(OBJDIR)/%.o: %.mm
	$(COMPILE.objcxx)

$(OBJDIR)/%.o: %.m
	$(COMPILE.objc)

$(BINDIR)/% :
	$(LINK.objcxx)



.PHONY: all
all: tests

.PHONY: tests
tests: executables
	$(BINDIR)/Tests

.PHONY: executables
executables: dirs $(foreach exe,$(TESTS),$(BINDIR)/$(exe))

.PHONY: clean
clean:
	rm -rf $(BUILDDIR)

### Create Directories
.PHONY: dirs
dirs: $(DIRS)

$(DIRS):
	mkdir -p $@
###

### The actual stuff...

$(BINDIR)/Tests: $(foreach obj,$(Tests_objects),$(OBJDIR)/$(obj))

Tests.o: Tests.mm NSCompoundStream.h NSData+AES.h NSData+BlockAES.h XmlDocument.h NSData+CryptoHash.h

OSX_SecRandom.o: OSX_SecRandom.m OSX_SecRandom.h

NSCompoundStream.o: NSCompoundStream.m NSCompoundStream.h

NSData+AES.o: NSData+AES.m NSData+AES.h

NSData+BlockAES.o: NSData+BlockAES.m NSData+BlockAES.h NSData+AES.h

XmlDocument.o : XmlDocument.m XmlDocument.h

NSData+CryptoHash.o : NSData+CryptoHash.m NSData+CryptoHash.h
