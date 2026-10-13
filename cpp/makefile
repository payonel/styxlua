# Styx for the C++ Lua of payonel/lua (branch lungolua), built against its
# packages: lungoluacpp (release) or lungoluacpp-tests (the engine's debug
# build, with its test library and test scripts), downloaded from GitHub
# Packages into DEPS_DIR once per version. 'make', 'make debug', 'make test'
# ('make debug test' for the debug build). Credentials: gpr.user and
# gpr.key in ~/.gradle/gradle.properties, or GITHUB_ACTOR and GITHUB_TOKEN.
# The version is the Java build's (lungolua_version in java/gradle.properties):
# the engine's packages of a commit share it.
LUNGOLUACPP_VERSION ?= $(shell sed -n 's/^lungolua_version=//p' ../java/gradle.properties)

VARIANT       = release
ifeq ($(findstring debug,$(MAKECMDGOALS)),debug)
VARIANT       = debug
endif

DEPS_DIR     ?= $(HOME)/.cache/payonel
MAVEN_URL     = https://maven.pkg.github.com/payonel/lua/com/payonel
GPR_USER     ?= $(or $(GITHUB_ACTOR),$(shell sed -n 's/^gpr.user=//p' $(HOME)/.gradle/gradle.properties 2>/dev/null))
GPR_KEY      ?= $(or $(GITHUB_TOKEN),$(shell sed -n 's/^gpr.key=//p' $(HOME)/.gradle/gradle.properties 2>/dev/null))
ENGINE_PKG    = $(if $(filter debug,$(VARIANT)),lungoluacpp-tests,lungoluacpp)
ENGINE_DIR    = $(DEPS_DIR)/$(ENGINE_PKG)-$(LUNGOLUACPP_VERSION)
TESTS_DIR     = $(DEPS_DIR)/lungoluacpp-tests-$(LUNGOLUACPP_VERSION)

ifneq ($(MAKECMDGOALS),clean)
include $(ENGINE_DIR)/flags.mk
endif

CWARNSCPP= \
	-Wfatal-errors \
	-Wextra \
	-Wshadow \
	-Wundef \
	-Wwrite-strings \
	-Wredundant-decls \
	-Wdisabled-optimization \
	-Wdouble-promotion \
	-Wmissing-declarations \
	-Werror \
	-Wstrict-overflow=2 \
	-Wconversion \
	-Wlogical-op \
	-Wno-aggressive-loop-optimizations

CXXFLAGS.release =-O2 -DNDEBUG
CXXFLAGS.debug   =-Og -g3 -ggdb
ARCH         ?= -march=native
CXX           = g++
CXXFLAGS      =-Wall $(CXXFLAGS.$(VARIANT)) $(LUNGOLUACPP_CXXFLAGS) $(CWARNSCPP) -fno-stack-protector -fno-common $(ARCH) -MMD -fmax-errors=0 -I. -I$(ENGINE_DIR)/include
ENGINE_LIB    = $(ENGINE_DIR)/lib/liblua-internal.a
LDFLAGS       = -Wl,--whole-archive $(ENGINE_LIB) -Wl,--no-whole-archive $(LUNGOLUACPP_LDFLAGS)

OBJ_DIR       = obj/$(VARIANT)
STYX_O        = $(OBJ_DIR)/lstyx.o
STYX_T        = $(OBJ_DIR)/libstyx.a
TEST_O        = $(OBJ_DIR)/styx_tests.o
TEST_T        = test_styx
GATE_O        = $(OBJ_DIR)/gate.o
GATE_T        = test_gate
VARIANT_STAMP = obj/variant-$(VARIANT)-$(LUNGOLUACPP_VERSION).stamp

all debug: $(STYX_T) $(TEST_T) $(GATE_T)

-include $(STYX_O:.o=.d) $(TEST_O:.o=.d) $(GATE_O:.o=.d)

# the package of a version, downloaded once (a .tar.gz already in DEPS_DIR
# is used as it is: a package made locally with the engine's 'make package')
$(DEPS_DIR)/%/flags.mk:
	@mkdir -p $(DEPS_DIR)
	@pkg='$*'; artifact=$${pkg%-$(LUNGOLUACPP_VERSION)}; tgz='$(DEPS_DIR)/$*.tar.gz'; \
	if [ ! -f "$$tgz" ]; then \
	  echo "downloading com.payonel:$$artifact:$(LUNGOLUACPP_VERSION)"; \
	  curl -fsSL -u "$(GPR_USER):$(GPR_KEY)" -o "$$tgz.part" \
	    "$(MAVEN_URL)/$$artifact/$(LUNGOLUACPP_VERSION)/$$pkg.tar.gz" && mv "$$tgz.part" "$$tgz" || exit 1; \
	fi; \
	rm -rf '$(DEPS_DIR)/$*' && mkdir -p '$(DEPS_DIR)/$*' && tar -xzf "$$tgz" -C '$(DEPS_DIR)/$*' --strip-components=1

$(VARIANT_STAMP):
	mkdir -p obj
	$(RM) obj/variant-*.stamp
	touch $@

$(OBJ_DIR):
	mkdir -p $@

$(STYX_O): lstyx.cpp $(VARIANT_STAMP) | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -MF $(OBJ_DIR)/lstyx.d -o $@ -c $<

$(STYX_T): $(STYX_O)
	$(RM) $@
	ar rc $@ $(STYX_O)
	ranlib $@

$(TEST_O): tests/styx/styx_tests.cpp $(VARIANT_STAMP) | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -MF $(OBJ_DIR)/styx_tests.d -o $@ -c $<

$(TEST_T): $(TEST_O) $(STYX_O) $(ENGINE_LIB)
	$(CXX) -o $@ $(TEST_O) $(STYX_O) $(LDFLAGS)

$(GATE_O): tests/gate/gate.cpp $(VARIANT_STAMP) | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -MF $(OBJ_DIR)/gate.d -o $@ -c $<

$(GATE_T): $(GATE_O) $(STYX_O) $(ENGINE_LIB)
	$(CXX) -o $@ $(GATE_O) $(STYX_O) $(LDFLAGS)

# the Styx tests, then the Styx gate: the engine's deep tests and the
# upstream suite (portable mode) run with a freeze at every budget point,
# and at every n-th freeze the whole state is persisted and restored and
# the run goes on in the restored state; they run in a copy of the
# engine's test scripts with the Styx scripts added
RUN_DIR       = $(OBJ_DIR)/tests
TEST_TEMP_DIR ?= 1
STYX_GATE_DEEP ?= 7
STYX_GATE_ALL ?= 5000

test: $(TEST_T) $(GATE_T) $(TESTS_DIR)/flags.mk
	$(RM) -r $(RUN_DIR)
	mkdir -p $(RUN_DIR)
	cp -r $(TESTS_DIR)/tests/. $(RUN_DIR)/
	cp -r ../tests/styx $(RUN_DIR)/styx
	cd $(RUN_DIR)/styx && $(CURDIR)/$(TEST_T)
	cd $(RUN_DIR) && GATE_LUA=$(ENGINE_DIR)/bin/lua $(CURDIR)/$(GATE_T) 97 --styx $(STYX_GATE_DEEP) deep/all.lua
	mkdir -p $(RUN_DIR)/libs/_$(TEST_TEMP_DIR)/P1
	cd $(RUN_DIR) && ulimit -S -s 8192 && cat /dev/null | \
	  GATE_LUA=$(ENGINE_DIR)/bin/lua $(CURDIR)/$(GATE_T) 97 --styx $(STYX_GATE_ALL) all.lua

# the package hosts build against: styxcpp (lstyx.h, libstyx.a, and the
# engine version it was built with); 'make package PKG_VERSION=<v>'
PKG_VERSION  ?= dev
PKG_DIR       = $(OBJ_DIR)/pkg/styxcpp

package: $(STYX_T)
	$(RM) -r $(PKG_DIR)
	mkdir -p $(PKG_DIR)/include $(PKG_DIR)/lib
	cp lstyx.h $(PKG_DIR)/include/
	cp $(STYX_T) $(PKG_DIR)/lib/
	printf 'STYXCPP_VERSION = $(PKG_VERSION)\nLUNGOLUACPP_VERSION = $(LUNGOLUACPP_VERSION)\n' > $(PKG_DIR)/flags.mk
	tar -czf styxcpp-$(PKG_VERSION).tar.gz -C $(OBJ_DIR)/pkg styxcpp

clean:
	$(RM) -r obj
	$(RM) $(TEST_T) $(GATE_T)

.PHONY: all debug test package clean
