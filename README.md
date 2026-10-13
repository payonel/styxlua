# StyxLua

Styx persists a whole Lua state and restores it into a new one, so a host
can stop its Lua programs anywhere (frozen or suspended), save them, and go
on with them later, in another process. It is a library for both ports of
Lua 5.5 on [payonel/lua](https://github.com/payonel/lua) (branch
`lungolua`): `java/` is StyxLua, for LungoLua, the Java port (package
`com.payonel.styxlua`), and `cpp/` is styxcpp, for the C++ engine it is
ported from, line by line. `tests/` holds the Styx test scripts both run.

Styx is a host library: the host persists (`luaL_persiststate`) and
restores (`luaL_restorestate`); scripts cannot, and nothing can `require`
it. A host may give scripts `styx.persistable` (`luaL_openstyx`), which
tells whether a persist of the state could write all that a value holds.
The design record is [docs/styx.md](docs/styx.md).

## Using it

From Gradle:

```gradle
repositories {
	maven {
		url = 'https://maven.pkg.github.com/payonel/styxlua'
		credentials {
			username = providers.gradleProperty('gpr.user').orElse(providers.environmentVariable('GITHUB_ACTOR')).getOrNull()
			password = providers.gradleProperty('gpr.key').orElse(providers.environmentVariable('GITHUB_TOKEN')).getOrNull()
		}
	}
	maven {
		url = 'https://maven.pkg.github.com/payonel/lua'
		credentials { /* the same */ }
	}
}

dependencies {
	implementation 'com.payonel:styxlua:1.0.0-<commit>'
	implementation 'com.payonel:lungolua:<the version styxlua was built with>'
}
```

From C++: `com.payonel:styxcpp:1.0.0-<commit>` is a `.tar.gz` of
`include/lstyx.h`, `lib/libstyx.a` and `flags.mk` (the engine version it
was built with), to link with that version's `com.payonel:lungoluacpp`.

Reading GitHub Packages takes a token with `read:packages` (`gpr.user`
and `gpr.key` in `~/.gradle/gradle.properties`).

## Building

Both builds use the engine version in `java/gradle.properties`
(`lungolua_version`): the engine's packages of a commit share it.

```
cd java
./gradlew build          # the jar and its sources
./gradlew check          # the Styx tests, then the Styx gate over the engine's tests
./gradlew check -Pdebug  # the same with the engine's debug checks

cd cpp
make                     # libstyx.a and the test programs
make test                # the Styx tests, then the Styx gate over the engine's tests
make debug test          # the same with the engine's debug build
```

A change to `cpp/` comes with its port to `java/`, pushed together.

Each push to `master` builds and tests both and publishes
`com.payonel:styxlua:1.0.0-<commit>` and `com.payonel:styxcpp:1.0.0-<commit>`
to this repository's packages.
