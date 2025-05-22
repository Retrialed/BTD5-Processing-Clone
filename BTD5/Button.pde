ArrayList<Button> buttons = new ArrayList<Button>();;
void drawButtons() {
  for (Button button : buttons) {
    button.drawButton();
    button.activateButton();
  }
}

void AddButton(int xPos, int yPos, int radius) {
  buttons.add(new Button(xPos, yPos, radius));
}

class Button {
  int x, y, r;
  
  Button(int xPos, int yPos, int radius) {
    x = xPos;
    y = yPos;
    r = radius;
  }
  
  void drawButton() {
    fill(100);
    circle(x, y, r);
    fill(255);
  }
  
  void activateButton() {
    if (mousePressed && overButton()) {
      background(random(255), random(255), random(255));
    }
  }
  
  boolean overButton() {
    return sq(x - mouseX) + sq(y - mouseY) < sq(r);
  }
}
