# pz-prozimity-based-zombie-spawning
A Project Zomboid mod that spawns more zombies the longer you stay in an area


Outline:
Core:
1. Create a heat map layer to store how long the player has been in each chunk
2. increment the chunk the player is in on the heat map layer at regular time intervals
    a. may want to increment adjacent chunks as well
3. change the quantity of zombies spawned in a chunk based on the heatmap score

Optional:
1. add radio notifications if the player is in a hot chunk
2. add option for the heat map to "cool" over time if chunks are empty
3. add the ability to adjust spawn rates in settings
3. test to find the optimal:
    a. maximum increase
    b. rate of increase
    c. rate of cooling
    d. spawn settings to pair with this
4. Make it so the heat map heats the outside edge of the cell that you're in, so if you wall a large area and remain for a long time, the zombies will gather in the chunks just outside your wall