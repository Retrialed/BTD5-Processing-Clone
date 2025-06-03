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
      startWave();
      return;
    }
    if (mouseButton == LEFT)
      speedLevel = (speedLevel + 1) % speeds.length;
    else
      speedLevel = (speedLevel + speeds.length - 1) % speeds.length;
    frameRate(speeds[speedLevel]);
  }).setImage("images/preround.png");
  
  addButton(100, 1000, 50, () -> addBloon(10)).setText("Moab");
  addButton(200, 1000, 50, () -> addBloon(22)).setText("Regrow Ceram");
  
  for (MonkeyType type : MonkeyTypes) {
    addSpawnButton(type);
  }
}

void drawGUI() {
  fill(255);
  image(gui, width/2, height/2);
  textAlign(RIGHT, CENTER);
  textSize(20);
  text(money, 1385, 65);
  text(lives, 1385, 115);
  text("Bloons alive: " + bloons.size(), 1224, 27);
  if (waveOngoing)
    text("LMB/RMB to cycle speeds.", 1436, 1050);
  else
    text("Click to start wave.", 1436, 1050);
  textAlign(LEFT, CENTER);
  text("Wave " + wave + "/" + (waves.length - 1), 1300, 140);
  text("FPS: " + (int)frameRate + "/" + speeds[speedLevel], 1300, 165);
  
  if (DRAWING_ON) {
    for (int i = 0; i < points.size(); i++) {
      PVector pt = points.get(i);
      circle(pt.x, pt.y, 10);
      text(i, pt.x + 10, pt.y - 5);
    }
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

void drawButtons() {
  for (Button button : buttons)
    button.drawButton();
}

void activateButtons() {
  for (int i = buttons.size() - 1; i >= 0; i--) {
    Button button = buttons.get(i);
    if (button.select()) break;
  }
  
  for (int i = buttons.size() - 1; i >= 0; i--) {
    Button button = buttons.get(i);
    button.activateButton();
  }
}

Button addButton(float xPos, float yPos, float radius, Runnable funct) {
  Button button = new Button(xPos, yPos, radius, funct);
  buttons.add(button);
  return button;
}

Button addButton(int x1, int y1, int x2, int y2, Runnable funct) {
  Button button = new Button(x1, y1, x2, y2, funct);
  buttons.add(button);
  return button;
}

Button addSpawnButton(MonkeyType type) {
  SpawnButton button = new SpawnButton(type);
  buttons.add(button);
  return button;
}

Button addMonkeyButton(Monkey m) {
  MonkeyButton button = new MonkeyButton(m);
  buttons.add(button);
  return button;
}

class Button {
  float x, y, r;
  float x1, x2, y1, y2;
  int shape;
  String text;
  PImage img;
  Runnable action;

  Button(float xPos, float yPos, float radius, Runnable funct) {
    x = xPos;
    y = yPos;
    r = radius;
    action = funct;
    shape = 0;
  }
  
  Button(float x1, float y1, float x2, float y2, Runnable funct) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
    action = funct;
    shape = 1;
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
  
  boolean select() {return false;}

  boolean overButton() {
    if (shape == 0) return sq(x - mouseX) + sq(y - mouseY) < sq(r);
    if (shape == 1) return mouseX == constrain(mouseX, x1, x2) && mouseY == constrain(mouseY, y1, y2);
    return true;
  }

  void drawButton() {
    if (text != null && shape == 0) {
      textAlign(CENTER, CENTER);
      fill(50, 50, 50, 100);
      circle(x, y, r);
      fill(255);
      text(text, x, y);
    }
    if (text != null && shape == 1) {
      textAlign(CENTER, CENTER);
      fill(50, 50, 50, 100);
      rect(x1, y1, x2, y2);
      fill(255);
      text(text, x, y);
    }
    if (img == null) return;
    
    image(img, x, y);
  }
}

Monkey selectedMonkey;

class MonkeyButton extends Button {
  MonkeyType type;
  Monkey monkey;
  
  MonkeyButton(Monkey m) {
    super(m.pos.x, m.pos.y, m.type.size, () -> {});
    monkey = m;
    type = m.type;
  }
  
  boolean select() {
    if (overButton()) {
      selectedButton = this;
      return true;
    }
    else if (selectedButton == this) {
      selectedButton = null;
      return false;
    }
    
    return false;
  }
  
  void activateButton() {
    //if (selectedButton == this && mouseY < 900) {
    //  selectedButton = null;
    //  selectedMonkey = null;
    //} else {
    //  selectedMonkey = monkey;
    //}
  }

  void drawButton() {
    if (selectedButton == this) {
      fill(50, 50, 50, 100);
      circle(monkey.pos.x, monkey.pos.y, type.range);
      fill(255);
    }
  }
}


class SpawnButton extends Button {
  MonkeyType type;
  boolean placing = false;
  
  SpawnButton(MonkeyType monkeyType) {
    super(monkeyType.ID % 2 == 0? 1302 : 1392, monkeyType.ID / 2 * 88 + 240, monkeyType.size, () -> {});
    type = monkeyType;
    img = type.sprite;
  }
  
  void activateButton() {
    if (placing) {
      if (canSpawn()) {
        addMonkey(type.ID, mouseX, mouseY);
        money -= type.cost;
      }
      placing = false;
      selectedButton = null;
    } else if (overButton()) {
      placing = true;
    }
      
  }
  
  boolean canSpawn() {
    if (money < type.cost || mouseX != constrain(mouseX, 0, 1247) || mouseY != constrain(mouseY, 0, 900)) return false;
    if (placementGrid[mouseX][mouseY] > 0) return false;
    for (Monkey m : monkeys) {
      float dx = m.pos.x - mouseX;
      float dy = m.pos.y - mouseY;
      if (sq(dx) + sq(dy) < sq(m.type.size) + sq(type.size)) {
        return false;
      }
    }
    
    return true;
  }
  
  void drawButton() {
    if (placing) {
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
