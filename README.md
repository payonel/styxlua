# StyxLua

Styx persists a whole Lua state and restores it into a new one, so a host
can stop its Lua programs anywhere (frozen or suspended), save them, and go
on with them later, in another process. This is Styx for
[LungoLua](https://github.com/payonel/lua) (branch `lua-java`), the Java
port of Lua 5.5: package `com.payonel.styxlua`. Branch `styxcpp` is the
same library for the C++ Lua it is ported from (branch `lua-c++`).

Styx is a host library: the host persists (`Lstyx.luaL_persiststate`) and
restores (`Lstyx.luaL_restorestate`); scripts cannot, and nothing can
`require` it. A host may give scripts `styx.persistable`
(`Lstyx.luaL_openstyx`), which tells whether a persist of the state could
write all that a value holds. The design record is
[docs/styx.md](docs/styx.md).

## Using it

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

Reading GitHub Packages takes a token with `read:packages` (`gpr.user`
and `gpr.key` in `~/.gradle/gradle.properties`).

## Building

The Java build is in `java/`, with Gradle; the engine it builds against is
`lungolua_version` in `java/gradle.properties`, and its tests use the
engine's test library and test scripts (`com.payonel:lungolua-tests`).

```
cd java
./gradlew build          # the jar and its sources
./gradlew check          # the Styx tests, then the Styx gate over the engine's tests
./gradlew check -Pdebug  # the same with the engine's debug checks
```

The C++ files at the top are the `styxcpp` sources this port follows line
by line; each change there comes here in a merge commit with its Java port.

Each push to `master` builds and tests it and publishes
`com.payonel:styxlua:1.0.0-<commit>` to this repository's packages.
