#pragma once

#include "lua.h"

/*
** Styx: the kernel's persistence. The host persists the whole state while
** it is at rest (no Lua code runs: the kernel has frozen or suspended its
** programs and yielded back to the host) and restores it into a new
** state; what it needs back it anchors in the registry (the main thread's
** stack is not part of a state). Scripts cannot persist.
**
** luaL_persiststate writes the state to 'w'; 'perms' is the stack index of
** the permanents table (object -> key), or 0 for none. Nothing is
** allocated in the state and no Lua code runs. 'L' is the main thread, or
** a thread the state holds (for a frozen main thread, the host's other
** thread, anchored before): luaL_restorestate gives it back. Gives LUA_OK,
** or an error status with a message.
*/
struct luaL_StyxResult
{
  int status;
  HostString msg;
};
luaL_StyxResult(luaL_persiststate)(lua_State* L, int perms, lua_Writer* w);

/*
** The kernel's restore, in one call: a new state with allocator 'f', which
** hashes as the persisting state did (its tables keep their order), set
** up by 'setup' (if given), which opens the same libraries and makes the
** host's permanents, in the same order as for the persisting state, and
** pushes the inverse permanents table (key -> object), or nil; then the
** whole state in 'data' (luaL_persiststate) is restored into it (a frozen
** main thread into its main thread). Gives the restored thread the state
** was persisted from (its main thread, or the host's other thread), or
** NULL with a message (nothing is left open).
*/
struct luaL_RestoreSetup
{
  virtual ~luaL_RestoreSetup() = default;
  virtual void setup(lua_State* L) = 0;
};
struct luaL_Restored
{
  lua_State* L;
  HostString msg;
};
luaL_Restored(luaL_restorestate)(lua_Alloc* f, byte_view data, luaL_RestoreSetup* setup);

void luaL_openstyx(lua_State* L);

/* Styx's round trip of one value, for its own tests (the engine persists
   whole states only: luaL_persiststate, luaL_restorestate); the module of
   the test scripts ('persist([perms,] v)', 'unpersist([perms,] s)') */
luaL_StyxResult lua_styxpersistvalue(lua_State* L, int perms, int idx, lua_Writer* w);
luaL_StyxResult lua_styxunpersistvalue(lua_State* L, int perms, byte_view data);
int lua_styxtestmodule(lua_State* L);
/* can a persist of the state write all the value at 'idx' holds? (see lstyx.cpp) */
luaL_StyxResult lua_styxcheck(lua_State* L, int idx, int perms);
