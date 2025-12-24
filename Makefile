JS_RUNTIME ?= $(shell if command -v bun >/dev/null 2>&1; then echo bun; else echo node; fi)

BROWSERIFY_BIN = ./node_modules/browserify/bin/cmd.js
WISP_BIN = ./node_modules/wisp/bin/wisp.js
WISP_CURRENT_BIN = ./bin/wisp.js
BUN_CLI_TARGETS ?= bun-linux-x64 bun-darwin-x64 bun-darwin-arm64

BROWSERIFY = $(JS_RUNTIME) $(BROWSERIFY_BIN)
WISP_CURRENT = $(JS_RUNTIME) $(WISP_CURRENT_BIN)
FLAGS =
INSTALL_MESSAGE = "You need to run 'bun install' (or 'npm install') to install build dependencies."
CLEAN_TARGETS = engine backend *.js *.js~ browserify.js dist/*.map dist/*.js~ node_modules
BUILD_DEPS = $(BROWSERIFY_BIN) $(WISP_BIN)
# set make's source file search path
vpath % src

ifdef verbose
	FLAGS = --verbose
endif

ifdef current
	WISP = $(WISP_CURRENT)
	WISP_TARGET = $(WISP_CURRENT_BIN)
else
	WISP = $(JS_RUNTIME) $(WISP_BIN)
	WISP_TARGET = $(WISP_BIN)
endif

CORE = expander runtime sequence string ast reader compiler analyzer
core: $(CORE) writer escodegen
escodegen: escodegen-writer escodegen-generator
node: core wisp node-engine repl
browser: node core browser-engine dist/wisp.min.js
all: browser

cli-bin: wisp
	@command -v bun >/dev/null 2>&1 || (echo "bun is required for cli-bin" && exit 1)
	@mkdir -p dist
	bun build cli.js --compile --outfile dist/wisp-bun

cli-bin-all: wisp
	@command -v bun >/dev/null 2>&1 || (echo "bun is required for cli-bin-all" && exit 1)
	@mkdir -p dist
	@$(foreach target,$(BUN_CLI_TARGETS),echo "Building dist/wisp-$(target)" && bun build cli.js --compile --target=$(target) --outfile dist/wisp-$(target) &&) echo "done"

test: core node recompile
	$(WISP_CURRENT) ./test/test.wisp $(FLAGS)

$(BUILD_DEPS):
	@echo $(INSTALL_MESSAGE)
	@exit 1

clean:
	rm -rf $(CLEAN_TARGETS)

%.js: %.wisp $(WISP_TARGET)
	@mkdir -p $(dir $@)
	$(WISP) --source-uri wisp/$(subst .js,.wisp,$@) < $< > $@

RECOMPILE = backend/escodegen/writer backend/escodegen/generator backend/javascript/writer engine/node engine/browser $(CORE)
recompile: node browser-engine
	$(info Recompiling with current version:)
	@$(foreach file,$(RECOMPILE),\
		echo "	$(file)" && \
		$(WISP_CURRENT) --source-uri wisp/$(file).wisp < src/$(file).wisp > $(file).js~ && \
		mv $(file).js~ $(file).js &&) echo "...done"

### core ###

repl: repl.js

reader: reader.js

compiler: compiler.js

runtime: runtime.js

sequence: sequence.js

string: string.js

ast: ast.js

analyzer: analyzer.js

expander: expander.js

wisp: wisp.js

writer: backend/javascript/writer.js

### escodegen backend ###

escodegen-writer: backend/escodegen/writer.js

escodegen-generator: backend/escodegen/generator.js

### platform engine bundles ###

node-engine: ./engine/node.js

browser-engine: ./engine/browser.js

dist/wisp.js: engine/browser.js $(WISP_TARGET) $(BROWSERIFY_BIN) browserify.js core recompile
	@mkdir -p dist
	$(JS_RUNTIME) browserify.js > dist/wisp.js

dist/wisp.min.js: dist/wisp.js
	@mkdir -p dist
	$(JS_RUNTIME) build dist/wisp.js --outfile dist/wisp.min.js --minify --target=browser
