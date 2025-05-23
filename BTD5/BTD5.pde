int fps = 60;

void setup() {
  size(1920, 1080);
  background(200);
  noStroke();
  ellipseMode(RADIUS);
  imageMode(CENTER);
  
  setUpButtons();
}

int x, y = 2;

void draw() {
  drawButtons();
  System.out.println(frameRate);
}

void mousePressed() {
  System.out.println(mouseX + ", " + mouseY);
  activateButtons();
}
