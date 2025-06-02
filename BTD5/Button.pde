ArrayList<Button> buttons = new ArrayList<Button>();
int[][] placementGrid;

void setupButtons() {
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
  
  addButton(100, 1000, 50, () -> addBloon(10)).setText("Moab");
  addButton(200, 1000, 50, () -> addBloon(22)).setText("Regrow Ceram");
  
  for (MonkeyType type : MonkeyTypes) {
    addSpawnButton(type);
  }
}

void setupMap() {
  String setMap = "sprint_track";
  
  track = createGraphics(width, height);
  track.beginDraw();
  track.noStroke();
  track.imageMode(CENTER);
  track.image(loadImage("images/" + setMap + "-map.png"), width/2, height/2);
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

void runButtons() {
  for (Button button : buttons) {
    button.drawButton();
    button.ifSelected();
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

Button addSpawnButton(MonkeyType type) {
  SpawnButton button = new SpawnButton(type);
  buttons.add(button);
  return button;
}

class Button {
  int x, y, r;
  String text;
  PImage img;
  Runnable action;

  Button(int xPos, int yPos, int radius, Runnable funct) {
    x = xPos;
    y = yPos;
    r = radius;
    action = funct;
  }

  void activateButton() {
    if (overButton())
      action.run();
  }
  
  void setImage(String image) {
    img = loadImage(image);
  }
  
  void setText(String message) {
    text = message;
  }
  
  void ifSelected() {}

  boolean overButton() {
    return sq(x - mouseX) + sq(y - mouseY) < sq(r);
  }

  void drawButton() {
    if (text != null) {
      textAlign(CENTER, CENTER);
      fill(50, 50, 50, 100);
      circle(x, y, r);
      fill(255);
      text(text, x, y);
    }
    if (img == null) return;
    
    image(img, x, y);
  }
}










class SpawnButton extends Button {
  MonkeyType type;
  
  SpawnButton(MonkeyType monkeyType) {
    super(monkeyType.ID % 2 == 0? 1302 : 1392, monkeyType.ID / 2 * 88 + 240, monkeyType.size, () -> {});
    type = monkeyType;
    img = type.sprite;
  }
  
  void activateButton() {
    if (overButton()) {
      selectedButton = this;
    } else if (selectedButton == this) {
      if (canSpawn()) {
        addMonkey(type.ID, mouseX, mouseY);
        money -= type.cost;
      }
      selectedButton = null;
    }
  }
  
  boolean canSpawn() {
    if (money < type.cost || mouseX != constrain(mouseX, 0, 1247) || mouseY != constrain(mouseY, 0, 900)) return false;
    if (placementGrid[mouseX][mouseY] > 0) return false;
    for (Monkey m : monkeys) {
      float dx = m.pos.x - mouseX;
      float dy = m.pos.y - mouseY;
      if (dx * dx + dy * dy < m.type.size * m.type.size + type.size + type.size) {
        return false;
      }
    }
    
    return true;
  }
  
  void drawButton() {
    if (selectedButton == this) {
      if (canSpawn())
        fill(50, 50, 50, 100);
      else
        fill(255, 0, 0, 100);
        
      circle(mouseX, mouseY, type.range);
      fill(255);
      image(img, mouseX, mouseY);
      return;
    }
      
    image(img, x, y);
  }
}
