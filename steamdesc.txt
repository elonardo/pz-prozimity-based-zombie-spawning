pz-prozimity-based-zombie-spawning
A Project Zomboid mod that spawns more zombies the longer you stay in an area

This mod aims to give purpose to the nomadic PZ playstyle, by forcing you to frequently relocate lest the zombie hordes catch up with you and eat you. best used with other nomad mods like vehicle interiors etc.

Current Functionality:
Every hour, the mod adds "heat" at squares at and around each player, stores those heat values in a lua table, spawns zombies in the players chunk proportional to the heat in the player's cell, and reduces the amount of heat at each point in the table. The formula that governs how many zombies spawn from heat can be seen in the calibration xlsx file in the mod folder. The number of zombies spawned at a given heat value increases based on how close you are to the "peak day."

Planned Functionality:
-add radio notifications alerting the player to the heat level in  their cell/region