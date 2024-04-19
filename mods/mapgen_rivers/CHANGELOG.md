CHANGELOG
=========

## `v1.0.2` (2022-01-10)
- Use builtin logging system and appropriate loglevels
- Skip empty chunks, when generating high above ground (~20% speedup)
- Minor optimizations (turning global variables to local...)

## `v1.0.1` (2021-09-14)
- Automatically switch to `singlenode` mapgen at init time

## `v1.0` (2021-08-01)
- Rewritten pregen code (terrainlib) in pure Lua
- Optimized grid loading
- Load grid nodes on request by default
- Changed river width settings
- Added map size in settings
- Added logs
