ifeq "$(PLATFORM)" ""
PLATFORM := $(shell uname)
endif

ifeq "$(PLATFORM)" "Darwin"
BUILDCOMMAND := swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib
REPLACECOMMAND := ls > /dev/null
else
BUILDCOMMAND := swift build -Xcc -fblocks
REPLACECOMMAND := sed -i -e 's/MySQL.xctest/MySQLTest.xctest/g' .build/debug.yaml
endif

build: 
	@echo --- Building package
	$(BUILDCOMMAND)
test: build
	@echo --- Running tests
	$(REPLACECOMMAND)
	swift test

clean:
	@echo --- Invoking swift build --clean
	swift build --clean
