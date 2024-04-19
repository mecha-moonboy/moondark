# Map Generator with Rivers
`mapgen_rivers v1.0.2` by Gaël de Sailly.

Semi-procedural map generator for Minetest 5.x. It aims to create realistic and nice-looking landscapes for the game, focused on river networks. It is based on algorithms modelling water flow and river erosion at a broad scale, similar to some used by researchers in Earth Sciences. It is taking some inspiration from [Fastscape](https://github.com/fastscape-lem/fastscape).

Its main particularity compared to conventional Minetest mapgens is that rivers that flow strictly downhill, and combine together to form wider rivers, until they reach the sea. Another notable feature is the possibility of large lakes above sea level.

![Screenshot](https://content.minetest.net/uploads/fff09f2269.png)

It used to be composed of a Python script doing pre-generation, and a Lua mod reading the pre-generation output and generating the map. The code has been rewritten in full Lua for version 1.0 (July 2021), and is now usable out-of-the-box as any other Minetest mod.

# Author and license
License: GNU LGPLv3.0

Code: Gaël de Sailly

Flow routing algorithm concept (in `terrainlib/rivermapper.lua`): Cordonnier, G., Bovy, B., & Braun, J. (2019). A versatile, linear complexity algorithm for flow routing in topographies with depressions. Earth Surface Dynamics, 7(2), 549-562.

# Requirements
No required dependency, but [`biomegen`](https://gitlab.com/gaelysam/biomegen) recommended (provides biome system).

# Installation
This mod should be placed in the `mods/` directory of Minetest like any other mod.

# Usage
It is recommended to use it **only in new worlds, with `singlenode` mapgen**. On first start, it runs pre-generation to produce a grid, from which the map will be generated. This usually takes a few seconds, but depending on custom settings this can grow considerably longer.

By default, it only generates a 15k x 15k map, centered around the origin. To obtain a bigger map, you can increase grid size and/or block size in settings, but this can be more ressource-intensive (as the map has to be loaded in full at pre-generation).

## Settings
Settings can be found in Minetest in the `Settings` tab, `All settings` -> `Mods` -> `mapgen_rivers`.

Most settings are world-specific and a copy is made in `mapgen_rivers.conf` in the world folder, during world first use, which means that further modification of global settings will not alter existing worlds.

## Map preview
The Python script `view_map.py` can display the full map. You need to have Python 3 installed, as well as the libraries `numpy`, `matplotlib`, and optionally `colorcet`. For `conda` users, an `environment.yml` file is provided.

It can be run from command line by passing the world folder. Example:
```
./view_map.py ~/.minetest/worlds/test_mg_rivers
```
