"""Bundle real Luau modules for the official Luau CLI; no Roblox engine emulation."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / ".tools" / "foundation-tests.generated.luau"
parts = [r'''
-- Generated from repository source. Minimal module/service adapter only.
local nodes, loaders, cache = {}, {}, {}
local function node(path)
    if nodes[path] then return nodes[path] end
    local value = { path = path, Name = path:match("[^.]+$") }
    function value:WaitForChild(name) assert(self[name], "Missing mock child " .. name); return self[name] end
    nodes[path] = value
    return value
end
local function add(path)
    local result = node(path)
    local parentPath, name = path:match("^(.*)%.([^.]+)$")
    if parentPath then result.Parent = add(parentPath); result.Parent[name] = result end
    return result
end
local game = { JobId = "headless-fixture" }
function game:GetService(name)
    if name == "HttpService" then return { GenerateGUID = function() return "headless-owner" end } end
    return assert(nodes[name], "Unsupported mock service " .. name)
end
local task = { wait = function() return coroutine.yield("WAIT") end }
local function moduleRequire(target)
    local path = target.path
    if cache[path] ~= nil then return cache[path] end
    local factory = assert(loaders[path], "Unsupported module " .. path)
    cache[path] = factory(target, moduleRequire, game, task)
    return cache[path]
end
''']
for folder, prefix in (("shared", "ReplicatedStorage.TrailWars"), ("server", "ServerScriptService.TrailWars")):
    for path in sorted((ROOT / "src" / folder).glob("*.luau")):
        if path.name.endswith(".server.luau"):
            continue
        identity = prefix + "." + path.stem
        parts.append(f"add({json.dumps(identity)})\n")
        parts.append(f"loaders[{json.dumps(identity)}] = function(script, require, game, task)\n")
        parts.append(path.read_text(encoding="utf-8-sig") + "\nend\n")
parts.append('add("ServerStorage.FoundationTests")\nloaders["ServerStorage.FoundationTests"] = function(script, require, game, task)\n')
parts.append((ROOT / "tests" / "FoundationTests.luau").read_text(encoding="utf-8-sig") + "\nend\n")
parts.append('local result = moduleRequire(nodes["ServerStorage.FoundationTests"])()\n')
parts.append('assert(result.failed == 0)\nprint(string.format("HEADLESS FOUNDATION: %d assertions passed; official Luau CLI + minimal service/module mocks; NOT Roblox execution", result.passed))\n')
for suite in ('GameplayTests', 'GameplayEdgeTests', 'MatchServiceTests'):
    suite_path = ROOT / 'tests' / (suite + '.luau')
    if suite_path.exists():
        identity = 'ServerStorage.' + suite
        parts.append(f'add({json.dumps(identity)})\nloaders[{json.dumps(identity)}] = function(script, require, game, task)\n')
        parts.append(suite_path.read_text(encoding='utf-8-sig') + '\nend\n')
        parts.append(f'assert(moduleRequire(nodes[{json.dumps(identity)}])().failed == 0)\n')
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text("\n".join(parts), encoding="utf-8")
print(OUT)
