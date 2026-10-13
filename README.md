# Styx (styxcpp)

Styx persists a whole Lua state and restores it into a new one, so a host
can stop its Lua programs anywhere (frozen or suspended), save them, and go
on with them later, in another process. This branch, `styxcpp`, is Styx for
the C++ Lua of [payonel/lua](https://github.com/payonel/lua) (branch
`lua-c++`); `master` is the Java one, for LungoLua.

Styx is a host library: the host persists (`luaL_persiststate`) and
restores (`luaL_restorestate`); scripts cannot, and nothing can `require`
it. A host may give scripts `styx.persistable` (`luaL_openstyx`), which
tells whether a persist of the state could write all that a value holds.
The API is in `lstyx.h`; the design record is [docs/styx.md](docs/styx.md).

## Building

Styx works on the engine's own objects, so it builds against the engine's
packages, which the makefile downloads from GitHub Packages into
`~/.cache/payonel` (once per version):

- `com.payonel:lungoluacpp`: the engine's headers and libraries, and its
  interpreter;
- `com.payonel:lungoluacpp-tests`: the same from the engine's debug build
  (with its test library), and its test scripts.

The version is `LUNGOLUACPP_VERSION` in the makefile. Reading packages
takes a GitHub token with `read:packages`: `gpr.user` and `gpr.key` in
`~/.gradle/gradle.properties`, or `GITHUB_ACTOR` and `GITHUB_TOKEN`.

```
make               # libstyx.a, test_styx and test_gate (release)
make test          # the Styx tests, then the Styx gate over the engine's tests
make debug test    # the same against the engine's debug build
make package PKG_VERSION=<v>   # styxcpp-<v>.tar.gz
```

A package the engine made locally (`make package` there) can stand in for
a download: put it in the cache directory as
`lungoluacpp-<version>.tar.gz` (and `lungoluacpp-tests-<version>.tar.gz`)
and build with that `LUNGOLUACPP_VERSION`.

Each push to `styxcpp` builds and tests it and publishes
`com.payonel:styxcpp:1.0.0-<commit>` to this repository's packages.
