int[] speeds = {60, 120, 240, 480};
int speedLevel = 0;
int money = 600;
int lives = 999999999;
int frame = 0;
int wave = 0;
int waveProgress = 0;
boolean waveOngoing = false;

Button selectedButton;

PGraphics track, gui;

boolean DRAWING_ON = false;
ArrayList<PVector> points = new ArrayList<PVector>();

int testFrames = 0;

void setup() {
  size(1440, 1080, P2D);
  smooth();
  background(200);
  noStroke();
  ellipseMode(RADIUS);
  imageMode(CENTER);
  frameRate(speeds[speedLevel]);
  
  setupData();
  
}

void setupData() {
  setupMap();
  
  setupBloonTypes();
  
  setupProjTypes();
  setupAttacks();
  
  setupMonkeyTypes();
  setupButtons();
  for (int i = 0; i < nodes.length; i++)
    pathNodes[i] = new PVector(nodes[i][0], nodes[i][1]);
}

void draw() {
  if (lives <= 0) {
    textSize(50);
    textAlign(CENTER, CENTER);
    text("Game Over!", width/2, height/2);
    return;
  }
  
  image(track, width/ 2, height / 2);
  if (waveOngoing == true) {
    manageWave();
    runBloons();
  }
  
  //if (testFrames % 2 == 0) {
  //  addProj(0, new PVector(width / 2, height / 2 + 150), 0);
  //}
  
  runMonkeys();
  runProjs();
  
  drawGUI();
  runButtons();
  
  interactionQueue = new ArrayList<Bloon>();
  testFrames++;
}











void manageWave() {
  int[][] waveData = waves[wave];
  
  if (waveProgress >= waveData.length) {
    if (bloons.size() == 0) {
      waveOngoing = false;
      buttons.get(0).setImage("images/preround.png");
      frame = 0;
      waveProgress = 0;
      speedLevel = 0;
      frameRate(speeds[speedLevel]);
      money += 99 + wave;
      return;
    }
    return;
  }
  
  int[] subWave = waveData[waveProgress];
  int spawnInterval = subWave[0] * 2;
  int spawnCount = subWave[1];
  int spawnType = subWave[2];
  
  if (frame >= spawnInterval * spawnCount) {
    frame = 0;
    waveProgress++;
    return; 
  }
    
  if (frame % spawnInterval == 0) {
    addBloon(spawnType);
  }
  
  frame++;
}

void drawGUI() {
  fill(255);
  image(gui, width/2, height/2);
  textAlign(RIGHT, CENTER);
  textSize(20);
  text(money, 1385, 65);
  text(lives, 1385, 115);
  text("Bloons alive: " + bloons.size(), 1224, 27);
  textAlign(LEFT, CENTER);
  text("Wave " + wave + "/" + (waves.length - 1), 1300, 140);
  text("FPS: " + (int)frameRate + "/" + speeds[speedLevel], 1300, 165);
  
  if (DRAWING_ON) {
    for (int i = 0; i < points.size(); i++) {
      PVector pt = points.get(i);
      circle(pt.x, pt.y, 10);
      text(i, pt.x + 10, pt.y - 5);
    }
  }
}

void mousePressed() {
  System.out.println(mouseX + ", " + mouseY);
  activateButtons();
  
  //if (mouseButton == LEFT) {
  //  addMonkey(0, mouseX, mouseY);
  //}
  
  //if (mouseButton == RIGHT)
  //  for (int i = 0; i < 1 && bloons.size() != 0; i++) {
  //    Bloon b = bloons.get(0);
  //    b.dmg(b.hp);
  //  }
      
  if (waveOngoing)
    buttons.get(0).setImage(speedLevel == 0? "images/spd1.png" : "images/spd2.png");
  
  if (DRAWING_ON) {
    PVector point = new PVector(mouseX, mouseY);
    points.add(point);
  }
}

void keyPressed() {
  if (key == 'e')
    for (Bloon bl : bloons)
      bl.live = false;
  
  if (DRAWING_ON) {
    if (key == 'q' || key == 'Q') {
      if (!points.isEmpty()) {
        //PVector last = 
        points.remove(points.size() - 1);
      }
    }
  
    if (key == 'p' || key == 'P') {
      String str = "";
      str += "{\n";
      for (int i = 0; i < points.size(); i++) {
        PVector pt = points.get(i);
        str += "  {" + int(pt.x) + ", " + int(pt.y) + "}, // " + i + "\n";
      }
      str += "};";
      System.out.println(str);
    }
  }
}
