# LumiBlock Architecture

LumiBlock is an offline-first Godot 4 portrait puzzle game. `BoardModel` is a pure 8x8 model with atomic placement and de-duplicated row/column clearing. `PieceCatalog` owns normalized polyomino definitions and seeded tray generation. `ScoringEngine` contains configurable scoring formulas. `SaveService` uses versioned JSON with a temporary-file replacement write.

The current native prototype uses a single drawing scene for a small, dependency-free playable surface. The model and service boundaries are intentionally separate so screens can be split into reusable `.tscn` components as visual assets and accessibility requirements expand.
