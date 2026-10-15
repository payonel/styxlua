-- thaws that stop above a coroutine of the program ('debug.thaw(co,
-- stops)'): the frozen coroutines a program holds persist and restore with
-- the rest of it
local styx = require "styx"
local H = require "harness"
local case = H.case

-- the standard libraries by name (their functions are the host's permanents)
local perms, back = {[_G] = "_G"}, {_G = _G}
for _, name in ipairs{"string", "table", "math", "os", "io", "coroutine", "debug", "utf8", "package"} do
  local lib = _G[name]
  perms[lib], back["lib:" .. name] = "lib:" .. name, lib
  for k, v in pairs(lib) do
    if type(v) == "function" then
      local n = name .. "." .. k
      perms[v], back[n] = n, v
    end
  end
end
for _, name in ipairs{"pcall", "xpcall", "error", "select", "tostring", "tonumber", "ipairs", "pairs", "next",
                      "type", "setmetatable", "getmetatable", "rawget", "rawset", "assert", "print"} do
  perms[_G[name]], back["base." .. name] = "base." .. name, _G[name]
end
-- (the tables of 'require', which a program stopped in it holds)
for _, k in ipairs{"loaded", "preload", "searchers"} do perms[package[k]] = "package." .. k end
-- (only functions persist by name, so the libraries' tables too)
for k, v in pairs(perms) do back[v] = back[v] or k end
back = H.invert(perms)

-- the budget callbacks are the firmware's own functions: a value persist takes
-- them as permanents (it refuses one that is not)

-- a thaw that stops above a coroutine (debug.thaw(co, stops)) leaves a
-- program with frozen coroutines of its own: its 'init' holds the children
-- the firmware's thaws stopped above (one stopped in a close too), and thaws
-- them itself, so its chain freezes through its thaw of a child. Persisted
-- at every freeze, restored, and run on beside the original with the same
-- stops, the copy ends as the original, with the same log
local function spent() debug.freeze() end
perms[spent] = "spent"
back = H.invert(perms)

local function show(v)
  if type(v) == "table" then
    local keys = {}
    for k in pairs(v) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    local parts = {}
    for _, k in ipairs(keys) do parts[#parts + 1] = show(k) .. "=" .. show(v[k]) end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  return type(v) == "string" and string.format("%q", v) or tostring(v)
end

local function program(log)
  return function(stops)
    local init = coroutine.create(function()
      local closer = coroutine.create(function()
        local x <close> = setmetatable({}, {__close = function()
          local s = 0
          for i = 1, 60 do s = s + i end
          log.closed = s
        end})
        coroutine.yield()
      end)
      coroutine.resume(closer)
      stops[closer] = true
      local r = table.pack(coroutine.close(closer))
      log.closestopped = debug.isfrozen(closer)
      while debug.isfrozen(closer) do r = table.pack(debug.thaw(closer)) end
      log.close = r[1]
      local kids = {}
      for k = 1, 3 do
        kids[k] = {arg = k, co = coroutine.create(function(a)
          local s = a
          for part = 1, 3 do
            for i = 1, 30 * k do s = s + i % 7 end
            s = s + coroutine.yield(s)
          end
          return s
        end)}
        stops[kids[k].co] = true
        log[k] = {}
      end
      local results, live = {}, #kids
      while live > 0 do
        for k, kid in ipairs(kids) do
          if not results[k] then
            if debug.isfrozen(kid.co) then
              r = table.pack(debug.thaw(kid.co))
            else
              r = table.pack(coroutine.resume(kid.co, kid.arg))
            end
            assert(r[1], r[2])
            if debug.isfrozen(kid.co) then
              log.stops = (log.stops or 0) + 1
            elseif coroutine.status(kid.co) == "dead" then
              results[k] = r[2]
              live = live - 1
            else
              kid.arg = r[2] % 5
              table.insert(log[k], r[2])
            end
          end
        end
      end
      return table.unpack(results)
    end)
    local r = table.pack(coroutine.resume(init))
    assert(r[1], r[2])
    return table.unpack(r, 2, r.n)
  end
end

-- the firmware: thaws at the freezes after the k-th, stopping above the
-- program's coroutines at every 'every'-th; nil at its p-th freeze. A
-- frozen coroutine the program ends with is one it hands to the firmware,
-- which thaws it to its end
local function drive(st, every, p)
  local r = st.r
  while true do
    local co = st.child or st.co
    if debug.isfrozen(co) then
      if st.k + 1 == p then
        st.r = r
        return nil
      end
      st.k = st.k + 1
      r = table.pack(debug.thaw(co, co == st.co and st.k % every == 0 and st.stops or nil))
    elseif co == st.co and type(r[2]) == "thread" and debug.isfrozen(r[2]) then
      st.child = r[2]
    else
      break
    end
  end
  assert(r[1], r[2])
  return r
end

local function start(n, program)
  local log = {}
  local st = {log = log, stops = setmetatable({}, {__mode = "k"}), k = 0}
  st.co = coroutine.create(program(log))
  debug.setbudget(st.co, n, spent)
  -- (a thread of the firmware's for the program: no budget group of its own)
  local k0 = coroutine.create(function(m) local s = 0 for i = 1, m do s = s + i end return s end)
  st.r = table.pack(coroutine.resume(st.co, st.stops, k0))
  return st
end

-- 'program' persisted at every freeze (every 'stride'-th), restored, and
-- run on beside the original: both end as a run never persisted, with the
-- same log; the number of points
local function everyfreeze(name, program, cfgs, check)
  local points = 0
  for _, cfg in ipairs(cfgs) do
    local n, every, stride = cfg[1], cfg[2], cfg[3]
    local plain = start(n, program)
    local pr = drive(plain, every)
    if check then check(plain.log, pr) end
    for p = 1, math.huge, stride do
      local st = start(n, program)
      if drive(st, every, p) ~= nil then break end
      points = points + 1
      local blob = styx.persist(perms, st)
      local copy = styx.unpersist(back, blob)
      local a, b = drive(st, every), drive(copy, every)
      local where = name .. ": n=" .. n .. " every=" .. every .. " p=" .. p .. ": "
      assert(show(a) == show(pr) and show(b) == show(pr), where .. show(a) .. " / " .. show(b) .. " vs " .. show(pr))
      assert(show(st.log) == show(plain.log) and show(copy.log) == show(plain.log),
             where .. show(copy.log) .. " vs " .. show(plain.log))
    end
  end
  return points
end

case("a program holding the coroutines thaws stopped above persists and restores at every freeze", function()
  local points = everyfreeze("children", program, {{20, 2, 1}, {101, 1, 1}, {7, 5, 3}}, function(log)
    assert(log.stops > 0 and log.closestopped, show(log))
  end)
  print("      persist points: " .. points)
end)

local function busy(m)
  local s = 0
  for i = 1, m or 300 do s = s + i end
  return s
end

-- 'f' under 'k' protected calls
local function nested(k, f)
  if k == 0 then return f() end
  return select(2, pcall(nested, k - 1, f))
end

-- how deep a chain of protected calls goes from here
local function cdepth()
  local depth = 0
  local function rec() depth = depth + 1 pcall(rec) end
  pcall(rec)
  return depth
end

-- each program runs its work in 'init' (resumed by the program's top
-- coroutine), which thaws what a stop left frozen; 'log' records where
-- the stops landed
local function under(work)
  return function(log)
    return function(stops, k0)
      local init = coroutine.create(work)
      local r = table.pack(coroutine.resume(init, log, stops, k0))
      assert(r[1], r[2])
      return table.unpack(r, 2, r.n)
    end
  end
end

local shapes = {
  -- a stop lands in the function of 'coroutine.wrap' (no values), its
  -- coroutine registered by itself
  wrap = under(function(log, stops)
    local me
    local gen = coroutine.wrap(function()
      me = coroutine.running()
      stops[me] = true
      local s = busy()
      coroutine.yield(s)
      return s + busy()
    end)
    local out = {}
    for round = 1, 2 do
      local r = table.pack(gen())
      while r.n == 0 and debug.isfrozen(me) do
        log.wrapstops = (log.wrapstops or 0) + 1
        local t = table.pack(debug.thaw(me))
        r = table.pack(table.unpack(t, 2, t.n))
      end
      out[round] = r[1]
    end
    return out[1], out[2]
  end),
  -- a stop lands in a callback's resume of the coroutine; the program
  -- finds it frozen afterwards
  callback = under(function(log, stops)
    local got
    local c = coroutine.create(function()
      local me = coroutine.running()
      coroutine.yield(function() got = table.pack(coroutine.resume(me)) end)
      return busy()
    end)
    local _, wake = coroutine.resume(c)
    stops[c] = true
    wake()
    log.wakestopped = debug.isfrozen(c)
    while debug.isfrozen(c) do got = table.pack(debug.thaw(c)) end
    return got[2]
  end),
  -- the firmware's thread (no budget group of its own) is stopped above: it
  -- gets the group it ran with
  group = under(function(log, stops, k0)
    stops[k0] = true
    local r = table.pack(coroutine.resume(k0, 500))
    log.stopped = debug.isfrozen(k0)
    log.group = debug.getbudget(k0)
    while debug.isfrozen(k0) do r = table.pack(debug.thaw(k0)) end
    return r[2]
  end),
  -- a stopped coroutine thawed from deeper counts its C calls on top
  depth = under(function(log, stops)
    local c = coroutine.create(function()
      return nested(20, function() stops[coroutine.running()] = true busy() return cdepth() end)
    end)
    local r = table.pack(coroutine.resume(c))
    if debug.isfrozen(c) then
      log.depthstopped = true
      r = nested(10, function() return table.pack(debug.thaw(c)) end)
    end
    while debug.isfrozen(c) do r = table.pack(debug.thaw(c)) end
    return r[2]
  end),
  -- the program hands the firmware a coroutine stopped above, which the
  -- firmware thaws to its end
  handed = under(function(log, stops)
    local c = coroutine.create(function() return busy(2000) end)
    stops[c] = true
    local r = table.pack(coroutine.resume(c))
    if debug.isfrozen(c) then
      log.handed = true
      return c
    end
    return r[2]
  end),
}

case("the shapes a stop leaves persist and restore at every freeze", function()
  local points = 0
  for _, name in ipairs{"wrap", "callback", "group", "depth", "handed"} do
    points = points + everyfreeze(name, shapes[name], {{20, 2, 1}, {7, 3, 2}}, function(log, r)
      assert(log.wrapstops or log.wakestopped or log.stopped or log.depthstopped or log.handed, name .. ": " .. show(log))
      if name == "group" then assert(log.stopped and (log.group == 20 or log.group == 7), show(log)) end
    end)
  end
  print("      persist points: " .. points)
end)
