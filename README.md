# contract-progression

The progression hexagon: a dependency-free Lean core for profile and inventory rules, its ports, and a database commit valve adapter.

## What it is for

The core is a pure reducer over a player's profile: grants add items, a sale needs the item and pays out, an art purchase needs its affinity requirement and the credits, and training raises affinity. Refusals are explicit effects. Fixtures pin each refusal, and property tests hold the affinity gate and the item and credit invariants under any event stream. The adapter replays the Lean script in the engine, commits the profile to SQLite, reopens the database cold and checks the reloaded profile against the Lean golden.

## Build

```sh
cd core
lake build
lake exe progression_emit
```

The second command writes the event script and the golden final profile the adapter checks against.

## Licence

MIT. See [LICENSE](LICENSE).
