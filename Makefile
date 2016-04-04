build: clean
	@echo --- Building package
	swift build -Xcc -fblocks

test: clean build
	@echo --- Running tests
	swift test

clean:
	@echo --- Invoking swift build --clean
	swift build --clean
