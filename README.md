proximity-based-zombie-spawning
A Project Zomboid mod that spawns more zombies the longer you stay in an area

This mod aims to give purpose to the nomadic PZ playstyle, by forcing you to frequently relocate lest the zombie hordes catch up with you and eat you. best used with other nomad mods like vehicle interiors etc.

Current Functionality:
Every hour, the mod adds "heat" at squares at and around each player, stores those heat values in a lua table, spawns zombies in the players chunk proportional to the heat in the player's cell, and reduces the amount of heat at each point in the table. The number of zombies spawned at a given heat value increases based on how close you are to the "peak day."

The formula that governs how many zombies spawn per hour is f(x)=min(max(ciel(-4+(4*(1+a))2^(1+x/240),0),50) where:
- x is the amount of heat
- a is a number between 0 and 1 depending on how close to the peak day you are (after the peak day a = 1)

Using the current formula, if you stand in one spot without moving, the mod will spawn 1,2,3,6,11,22,43,50 zombies per hour after each successive day at day 0
and 2,3,6,11,22,42,50 zombies per hours after each successive day at peak day

Planned Functionality:
-add radio notifications alerting the player to the heat level in  their cell/region

Changelog
---------------------------------------------------------
v1.1.1
07/30/21
-hotfix coordinates bug

V1.1
07/30/2023
-Changed zombie spawning formula to work on multiples of 10 and the cooling formula to work on multiples of 2, so areas take 5 times as long to cool as they do to heat up
-Added compatibility with RV interiors, now if the mod adds heat/spawns zombies while you are in your RV, it adds heat/spawns zombies at the same location it last did that instead of off the edge of the map