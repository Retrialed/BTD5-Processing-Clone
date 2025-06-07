import java.util.WeakHashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.function.Consumer;
import java.util.Set;
import java.util.LinkedList;

int speedLevel = 1;
int frameWait = 1;
boolean inverseSpeed = false;
int money = 600;
int lives = 9999999;
int frame = 0;
int wave = 40;
int waveProgress = 0;
boolean waveOngoing = false;
float GRIDSIZE = 80;

Button selectedButton;

PGraphics track, gui;

ArrayList<PVector> points = new ArrayList<PVector>();
boolean DRAWING_ON = false;
boolean CONTINUOUS_WAVES = true;
boolean HALP = false;

void setup() {
  size(1440, 1080, P2D);
  smooth();
  noStroke();
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  imageMode(CENTER);
  
  setupData();
}

void setupData() {
  setupMap();
  setupGrid();
  
  setupBloonTypes();
  
  setupProjTypes();
  setupAttacks();
  
  setupMonkeyTypes();
  setupButtons();
  
  
  for (int i = 0; i < nodes.length; i++)
    pathNodes[i] = new PVector((nodes[i][0]), (nodes[i][1]));
}

//float angle = 0;
//float radius = 49;

void draw() {
  if (lives <= 0) {
    textSize(50);
    textAlign(CENTER, CENTER);
    text("Game Over!", width/2, height/2);
    return;
  }
  
  image(track, width/ 2, height / 2);
  
  if (!inverseSpeed || !waveOngoing) {
    for (int i = 0; i < (waveOngoing? speedLevel : 1); i++) {
      if (waveOngoing == true) {
        manageWave();
        runBloons();
        runMonkeys();
        }
      runProjs();
    }
  } else if (inverseSpeed && frameWait >= speedLevel) {
    if (waveOngoing == true) {
      manageWave();
      runBloons();
      runMonkeys();
      }
    runProjs();
    
    frameWait = 1;
  } else {
    frameWait++;
  }
  
  
  drawBloons();
  drawProjs();
  drawGUI();
  drawButtons();
  drawMonkeys();
}

void manageWave() {
  int[][] waveData = waves[wave];
  
  
  
  if (waveProgress >= waveData.length) {
    if (bloons.size() == 0) {
      if (wave == 0) return;
      endWave();
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

void startWave() {
  waveOngoing = true;
  wave++;
}

void endWave() {
  waveOngoing = false;
  buttons.get(0).setImage("images/preround.png");
  frame = 0;
  waveProgress = 0;
  money += 99 + wave;
  
  if (CONTINUOUS_WAVES) startWave();
}

void mousePressed() {
  activateButtons();
  
  //if (mouseButton == RIGHT)
  //  for (int i = 0; i < 1 && bloons.size() != 0; i++) {
  //    Bloon b = bloons.get(0);
  //    b.dmg(b.hp);
  //  }
      
  if (waveOngoing)
    buttons.get(0).setImage(speedLevel == 1? "images/spd1.png" : "images/spd2.png");
  
  if (DRAWING_ON) {
    PVector point = new PVector(mouseX, mouseY);
    points.add(point);
  }
}

void keyPressed() {
  if (key == 'c')
    println(mouseX + ", " + mouseY);
    
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

void setupMap() {
  String setMap = "sprint_track";
  
  track = createGraphics(width, height);
  track.beginDraw();
  track.noStroke();
  track.imageMode(CENTER);
  PImage map = loadImage("images/" + setMap + "-map.png");
  //map.resize(width, height);
  track.image(map, width/2, height/2);
  track.endDraw();
  
  PImage placementMask = loadImage("images/" + setMap + "-mask.png");
  placementMask.loadPixels();
  placementGrid = new int[placementMask.width][placementMask.height];
  
  color red = color(255, 0 , 0);
  color blue = color(0, 0, 255);
  
  for (int x = 0; x < placementGrid.length; x++) {
    for (int y = 0; y < placementGrid[x].length; y++) {
      int i = x + y * placementMask.width;
      if (placementMask.pixels[i] == red) {
        placementGrid[x][y] = 1;
      } else if (placementMask.pixels[i] == blue) {
        placementGrid[x][y] = 2;
      }
    }
  }
}
