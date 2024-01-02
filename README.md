# Moondark
## Aiming to be an ultimate fantasy experience for Minetest
A personal project for my own satisfaction. Textures and color palette are a work in progress. The theme may get more grim down the line. The aim of this project is to recapture some of the nostalgia of learning Minec*** for the first time, as well as the epic adventure and progression of terraria. I am dividing the game into distinct progression phases, each with their own set of struggles and challenges

APIs:
- Herbs: register and generate herbs given particular conditions, for intelligent gameplay and rare ingredients.
- Astrology: Seasons, Moon phases, (planned seasonal block changes, and planets).
- Status Effects: Register status effects and activate them. My alternative to a hunger or sprint system.
- Node Critters: Register blocky friends to make your world a little more crunchy.

Features:
- QOL mods (weilded light, wood cutting, gridless craft).
- Large trees (that's a big one for some people, myself included).
- Higher/lower terrain than default valleys mapgen.
- Rake: Because who wants to spend 2 minutes picking up a few dozen sticks? (Credits to Warr's Nodecore for the idea, implementation varied greatly.)
- In-theme hotbar and hearts/bubbles
- Stone tools and starter ingredients.

These are just a few of many systems being given a boilerplate implementation and demo features. The goal is to make a fantasy-themed abstraction layer on top of the engine that is easy to use and learn. Eventually, a fully fledged game may begin serious development. Until then, here's some spoilers I have to rope you in:
- Environmental Effects API: nodes, map variables, and various other factors could effect the player in a number of ways.
- Conduct API: Player behavior can disrupt a delicate balance between matter and spirit, making nature react in self-defense.
- Mob API: A mob API build from the ground up to offer a diverse array of tools.
- Smithing System: No more furnaces to melt your metal ores like butter, have fun stoaking and containing a forge fire! ... Of varying sizes...

## Installation

- Unzip the archive, rename the folder to `moondark` and
place it in .. `minetest/games/`

- GNU/Linux: If you use a system-wide installation place it in `~/.minetest/games/`.

The Minetest engine can be found at [GitHub](https://github.com/minetest/minetest).

## Licensing

See `LICENSE`
