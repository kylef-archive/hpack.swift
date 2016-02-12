.PHONY: test
test:
	@swift build
	@.build/debug/spectre-build
