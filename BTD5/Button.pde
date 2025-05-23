ArrayList<Button> buttons = new ArrayList<Button>();

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

void AddButton(int xPos, int yPos, int radius, Runnable funct) {
  buttons.add(new Button(xPos, yPos, radius, funct));
}



class Button {
  int x, y, r;
  Runnable action;
  
  Button(int xPos, int yPos, int radius, Runnable funct) {
    x = xPos;
    y = yPos;
    r = radius;
    action = funct;
  }
  
  void drawButton() {
    fill(100);
    circle(x, y, r);
    fill(255);
  }
  
  void activateButton() {
    if (overButton())
      action.run();
  }
  
  boolean overButton() {
    return sq(x - mouseX) + sq(y - mouseY) < sq(r);
  }
}
