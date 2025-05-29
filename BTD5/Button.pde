ArrayList<Button> buttons = new ArrayList<Button>();

void setupButtons() {
  addButton(1293, 959, 45, () -> {
    speedLevel = (speedLevel + 1) % speeds.length;
    frameRate(speeds[speedLevel]);
  }).setImage("images/spd1.png");
  
  addButton(200, 100, 30, () -> {
    background(200);
  });
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
