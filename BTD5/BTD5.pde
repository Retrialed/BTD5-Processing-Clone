ArrayList<Bloon> bloons = new ArrayList<Bloon>();
ArrayList<Monkey> monkeys = new ArrayList<Monkey>();

void setup() {
  size(1080, 720);
  background(200);
  stroke(0);
  ellipseMode(CENTER);
  
  buttons.add(new Button(100, 200, 50));
  buttons.add(new Button(200, 100, 50));
}

void draw() {
  drawButtons();
}
