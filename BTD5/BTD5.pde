int[] speeds = {30, 60, 120, 240};
int speedLevel = 1;
int money = 600;
int lives = 250;
int frame = 0;
int wave = 0;
int waveProgress = 0;
boolean waveOngoing = false;

PGraphics track, gui;

boolean DRAWING_ON = false;
ArrayList<PVector> points = new ArrayList<PVector>();

void setup() {
  size(1440, 1080);
  background(200);
  noStroke();
  ellipseMode(RADIUS);
  imageMode(CENTER);
  frameRate(speeds[speedLevel]);
  
  setupButtons();
  setupData(); 
    
  
}

void draw() {
  image(track, width/ 2, height / 2);
  if (waveOngoing == true) {
    runBloons();
    manageWave();
    frame++;
  }
  
  drawGUI();
  drawButtons();
  circle(mouseX, mouseY, 10);
  
  //drawMonkeys();
  //System.out.println(frameRate);
}

void manageWave() {
  int[][] waveData = waves[wave];
  
  if (waveProgress >= waveData.length) {
    if (bloons.size() == 0) {
      waveOngoing = false;
      buttons.get(0).setImage("images/preround.png");
      frame = 0;
      waveProgress = 0;
      speedLevel = 1;
      frameRate(speeds[speedLevel]);
      return;
    }
    return;
  }
  
  int[] subWave = waveData[waveProgress];
  int firstSpawnTick = subWave[0];
  int spawnInterval = subWave[1];
  int spawnCount = subWave[2];
  int spawnType = subWave[3];
  
  if (frame > firstSpawnTick + spawnInterval * (spawnCount - 1)) {
    waveProgress++;
    return; 
  }
    
  if ((frame - firstSpawnTick) % spawnInterval == 0)
    addBloon(spawnType);
}

void drawGUI() {
  image(gui, width/2, height/2);
  textAlign(RIGHT, CENTER);
  textSize(20);
  text(money, 1385, 65);
  text(lives, 1385, 115);
  text("FPS: " + (int)frameRate + "/" + speeds[speedLevel], 1385, 165);
}

void mousePressed() {
  System.out.println(mouseX + ", " + mouseY);
  activateButtons();
  
  if (mouseButton == RIGHT)
    for (int i = 0; i < 1 && bloons.size() != 0; i++)
      bloons.get(0).live = false;
      
  if (waveOngoing)
    buttons.get(0).setImage(speedLevel == 1? "images/spd1.png" : "images/spd2.png");
  
  if (DRAWING_ON) {
    PVector point = new PVector(mouseX, mouseY);
    points.add(point);
  
    track.beginDraw();
    track.fill(255, 0, 0); // red
    track.circle(point.x, point.y, 30);
    track.endDraw();
  }
}

void keyPressed() {
  if (key == 'e')
    for (Bloon bl : bloons)
      bl.live = false;
  
  if (DRAWING_ON) {
    if (key == 'q' || key == 'Q') {
      if (!points.isEmpty()) {
        PVector last = points.remove(points.size() - 1);
        track.beginDraw();
        track.fill(0, 255, 0); // green
        track.circle(last.x, last.y, 30);
        track.endDraw();
      }
    }
  
    if (key == 'p' || key == 'P') {
      String str = "";
      str += "{";
      for (int i = 0; i < points.size(); i++) {
        PVector pt = points.get(i);
        str += "{" + int(pt.x) + ", " + int(pt.y) + "}, ";
      }
      str += "};";
      System.out.println(str);
    }
  }
}
