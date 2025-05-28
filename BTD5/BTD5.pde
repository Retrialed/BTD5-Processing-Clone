int[] speeds = {30, 60, 120};
int speedLevel = 0;
int money = 600;
int lives = 250;

PGraphics bgBuffer;
PImage bg;

boolean DRAWING_ON = false;
ArrayList<PVector> points = new ArrayList<PVector>();

void setup() {
  size(1440, 1080);
  background(200);
  noStroke();
  ellipseMode(RADIUS);
  imageMode(CENTER);
  frameRate(speeds[speedLevel]);
  
  setUpButtons();
  
  for (int i = 0; i < nodes.length; i++)
    pathNodes[i] = new PVector(nodes[i][0], nodes[i][1]);
    
  bgBuffer = createGraphics(width, height);
  bgBuffer.beginDraw();
  bgBuffer.noStroke();
  bgBuffer.imageMode(CENTER);
  bgBuffer.image(loadImage("images/sprint_track-map.png"), width/2, height/2);
  bgBuffer.image(loadImage("images/sidebar.png"), width/2, height/2);
  bgBuffer.endDraw();
  
  addBloon(4);
}

int egg = 0;

void draw() {
  image(bgBuffer, width/ 2, height / 2);
  drawButtons();
  drawGUI();
  runBloons();
  
  egg++;
  if (egg % 30 == 0 && egg < 150) {
    addBloon(4);
  }
  //if (egg % 10 == 0 && bloons.size() > 0) {
  //  bloons.get(0).dmg(1);
  //}
  circle(mouseX, mouseY, 10);
  
  //drawMonkeys();
  //System.out.println(frameRate);
}

void drawGUI() {
  textAlign(RIGHT, CENTER);
  textSize(20);
  text(money, 1385, 65);
  text(lives, 1385, 115);
}

void mousePressed() {
  System.out.println(mouseX + ", " + mouseY);
  activateButtons();
  buttons.get(0).setImage(speedLevel == 0? "images/spd1.png" : "images/spd2.png");
  
  if (DRAWING_ON) {
    PVector point = new PVector(mouseX, mouseY);
    points.add(point);
  
    bgBuffer.beginDraw();
    bgBuffer.fill(255, 0, 0); // red
    bgBuffer.circle(point.x, point.y, 30);
    bgBuffer.endDraw();
  }
}

void keyPressed() {
  if (DRAWING_ON) {
    if (key == 'q' || key == 'Q') {
      if (!points.isEmpty()) {
        PVector last = points.remove(points.size() - 1);
        bgBuffer.beginDraw();
        bgBuffer.fill(0, 255, 0); // green
        bgBuffer.circle(last.x, last.y, 30);
        bgBuffer.endDraw();
      }
    }
  
    if (key == 'p' || key == 'P') {
      String str = "";
      str += "{";
      for (int i = 0; i < points.size(); i++) {
        PVector pt = points.get(i);
        str += "{" + int(pt.x) + ", " + int(pt.y) + "}, ";
      }
      str += "}";
      System.out.println(str);
    }
  }
}
