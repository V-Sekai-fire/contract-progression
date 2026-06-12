# progression

The progression hexagon: a dependency-free core holding the profile and
inventory rules — credits, the affinity gate on arts, valid item transitions —
behind narrow ports, with the sqlite commit valve as a working adapter.

It follows the V-Sekai `core/` + `ports/` + `adapters/` triad
([hexagonal decision](https://v-sekai-multiplayer-fabric.github.io/manuals/decisions/20260610-hexagonal-core-ports-adapters.html))
and the [progression hexagon decision](https://v-sekai-multiplayer-fabric.github.io/manuals/decisions/20260611-hexagon-progression-core.html).

## The core

`core/ProgressionCore/Core.lean` is the pure reducer over the profile: grants
add items, sells require the item and pay out, an art purchase needs the
affinity requirement and the credits (refusals are explicit effects), and
training raises affinity.

- `#guard` fixtures pin the gate, the duplicate refusal, the unfunded refusal,
  and the sell-without-item refusal.
- Plausible properties: the affinity gate holds under any event stream, item
  counts stay positive and arts unique, and credits move only by priced amounts.
- `lake exe progression_emit` writes the script and the golden final profile.

## The sqlite valve

`adapters/godot-sqlite/progression_sqlite.gd` applies the Lean script in the
merged build, commits the profile through `feat/module-sqlite` (the degraded
`commit_sink` of the progression decision), reopens the database cold, and
asserts the reloaded profile equals the Lean golden.

```sh
GODOT=bin/godot.linuxbsd.editor.double.x86_64
PROG_SCRIPT=adapters/fixture/progression_script.txt \
PROG_GOLDEN=adapters/fixture/progression_golden.csv \
PROG_DB=/tmp/profile.db \
$GODOT --headless --script adapters/godot-sqlite/progression_sqlite.gd
# -> PROGRESSION SQLITE PASS: reloaded profile matches the Lean golden
```

The cockroach + zone-backend adapter is the durable path; this valve keeps the
loop demonstrable without it.
