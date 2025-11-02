Goal:
To copy part of the tower defense games “Bloons Tower Defense 5.” I will
only add extra maps and towers if I have extra time.
I will focus on implementing the core functionality of the “fun” part of the game. (Enemy movement and mechanics) (Tower attack and progression).

Functionalities:
  Clickable GUI
  Store an array of clickableUI. Clicking on this UI allows you to spawn towers (monkeys), upgrade, or start and end the game. For example, the fast forward button will double the framerate to make the game progress faster. (Unless it crashes)

  Enemy Pathfinding and Appearance
  Enemies (Bloons) will spawn in waves, travel the path using checkpoints, and head towards the end to deplete player health. They will spawn for 85 waves (Won’t implement random waves). I will use hard coded data to spawn bloons at each wave. I already have an array of data containing this data from a past project. This will be a class. They have a unique health mechanic that will be copied from the original game.
  Tower Placement and Mechanics
     Players can spend money to create new towers (monkeys). These will use darts to pop the enemies and stop them from reaching the end. Towers can be upgraded.

Guide:
  Press the start button. Each wave of enemies will require you to press the start button to start
  
  Bloons: They will spawn on the start of the path after you press the start button. If they reach the end of the path, you will lose hearts until you fail at 0.
  
  Monkeys: The class of tower used to defend the path. Click on a monkey that you have enough money for and click on a valid area to place it. A transparent radius representing the tower’s range will appear indicating if you have met the conditions to place it. Use as much of the range as you can to cover the path.
  
  You will receive money for each time a tower damages an enemy or the wave ends. This money will be used to upgrade or place monkeys.
  
  This game ends once you complete wave 85 without depleting your hearts.

