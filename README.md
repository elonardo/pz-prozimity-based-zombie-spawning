pz-prozimity-based-zombie-spawning
A Project Zomboid mod that spawns more zombies the longer you stay in an area

This mod aims to give purpose to the nomadic PZ playstyle, by forcing you to frequently relocate lest the zombie hordes catch up with you and eat you. best used with other nomad mods like vehicle interiors etc.

Current Functionality:
Every hour, the mod adds "heat" at squares at and around each player, stores those heat values in a lua table, spawns zombies in the players chunk proportional to the heat in the player's cell, and reduces the amount of heat at each point in the table. The net effect of this, is that every hour 45 zombies are queued to be spawned over a period of 5 hours around 
the player's location, so the longer the player stays in an area, the more zombies will accumulate there, and the faster those zombies will accumulate. The heat value 
(and therefore number of zombies spawned) scales with your peak day multiplier, so when you hit your peak day, more zombies will spawn near you.

A technical note on how the mod works:
The current spawning system is not ideal, as it creates an negatively sloped line of zombie spawns over time and shifts that line to the right the longer you stay in an area. 
Two consequences of that are that it's very difficult to clear the zombies from an area when you first arrive to create a window where you can loot, sleep, or carry out other 
operations and that eventually you will effectively render the whole map uninhabitable as in order to reduce the total number of global zombies you need to kill 45 zombies 
per hour on average (even while you're sleeping). A better system would be to spawn zombies in the cell logarithmically based on heat, ie. when you first arrive, very few 
additional zombies spawn, but over time this increases and after a certain amount of time (3-4 days perhaps) the number of zombies spawning increases sharply. This would 
require changes to how the heat map is calculated to add heat to the cell, rather than to the square. Those changes are coming in a future update.

Planned Functionality:
1. change the heat system to operate by cell rather than by square (still trying to figure out the right functions to get the cell x,y coords and get a random square in a cell)
2. do a check to make sure it doesn't spawn zombies right next to a player
3. balance
4. add radio notifications alerting the player to the heat level