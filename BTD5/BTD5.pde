int fps = 60;
int money = 600;
int hp = 250;


void setup() {
  size(1920, 1080);
  background(200);
  noStroke();
  ellipseMode(RADIUS);
  imageMode(CENTER);
  
  for (int i = 0; i < nodes.length; i++)
    pathNodes[i] = new PVector(nodes[i][1], nodes[i][2]);
  
  setUpButtons();
}

int x, y = 2;

void draw() {
  drawButtons();
  drawMonkeys();
  drawBalloons();
  System.out.println(frameRate);
}

void mousePressed() {
  System.out.println(mouseX + ", " + mouseY);
  activateButtons();
}
