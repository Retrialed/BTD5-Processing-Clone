

void setup() {
  size(1080, 720);
  background(200);
  noStroke();
  ellipseMode(RADIUS);
  
  AddButton(100, 200, 30, () -> {
    background(random(255), random(255), random(255));
  });
  AddButton(200, 100, 30, () -> {
    background(200);
  });
}

void draw() {
  drawButtons();
}

void mousePressed() {
  System.out.println(mouseX + ", " + mouseY);
  activateButtons();
}
