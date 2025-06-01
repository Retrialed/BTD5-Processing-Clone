ArrayList<Button> buttons = new ArrayList<Button>();

void setupButtons() {
  track = createGraphics(width, height);
  track.beginDraw();
  track.noStroke();
  track.imageMode(CENTER);
  track.image(loadImage("images/sprint_track-map.png"), width/2, height/2);
  track.endDraw();
  
  gui = createGraphics(width, height);
  gui.beginDraw();
  gui.noStroke();
  gui.imageMode(CENTER);
  gui.image(loadImage("images/sidebar.png"), width/2, height/2);
  
  if (DRAWING_ON) {
    for (int i = 0; i < nodes.length; i++) {
      points.add(new PVector(nodes[i][0], nodes[i][1]));
    } 
  }
  
  gui.endDraw();
  
  addButton(1293, 959, 45, () -> {
    if (waveOngoing == false) {
      waveOngoing = true;
      wave++;
      return;
    }
    speedLevel = (speedLevel + 1) % speeds.length;
    frameRate(speeds[speedLevel]);
  }).setImage("images/preround.png");
  
  addButton(1302, 242, 30, () -> {
    background(200);
  }).setImage("images/monkeys/dart.png");
}

void drawButtons() {
  for (Button button : buttons) {
    button.drawButton();
  }
}

void activateButtons() {
  for (Button button : buttons) {
    button.activateButton();
  }
}

Button addButton(int xPos, int yPos, int radius, Runnable funct) {
  Button button = new Button(xPos, yPos, radius, funct);
  buttons.add(button);
  return button;
}

class Button {
  int x, y, r;
  PImage img;
  Runnable action;

  Button(int xPos, int yPos, int radius, Runnable funct) {
    x = xPos;
    y = yPos;
    r = radius;
    action = funct;
  }

  void drawButton() {
    if (img != null)
      image(img, x, y);
    else {
      fill(100);
      circle(x, y, r);
      fill(255);
    }
  }

  void activateButton() {
    if (overButton())
      action.run();
  }
  
  void setImage(String image) {
    img = loadImage(image);
  }

  boolean overButton() {
    return sq(x - mouseX) + sq(y - mouseY) < sq(r);
  }
}
