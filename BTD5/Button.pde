ArrayList<Button> buttons = new ArrayList<Button>();
ArrayList<Button> selectedMonkeyButtons = new ArrayList<Button>();
int[][] placementGrid;
Monkey selectedMonkey;

void setupButtons() {
  gui = createGraphics(width, height);
  gui.beginDraw();
  gui.noStroke();
  gui.imageMode(CENTER);
  PImage guiImage = loadImage("images/sidebar.png");
  //guiImage.resize(width, height);
  gui.image(guiImage, width/2, height/2);
  
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
    if (mouseButton == LEFT) {
      speedLevel += inverseSpeed? -1 : 1;
      if (speedLevel == 1) {
        inverseSpeed = false;
      }
    } else if (mouseButton == RIGHT) {
      if (speedLevel == 1) {
        inverseSpeed = true;
      }
      speedLevel += inverseSpeed? 1 : -1;
    }
  }).setImage("images/preround.png");
  
  addButton(1100, 1050, 50, () -> addBloon(10)).setText("Moab");
  addButton(1200, 1050, 50, () -> addBloon(22)).setText("Regrow Ceram");
  
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
  
  if (DRAWING_ON) {
    for (int i = 0; i < points.size(); i++) {
      PVector pt = points.get(i);
      circle(pt.x, pt.y, 10);
      text(i, pt.x + 10, pt.y - 5);
    }
  }
  
  if (selectedMonkey != null) {
    textAlign(CENTER, CENTER);
    text(selectedMonkey.name, 100, 950);
    image(selectedMonkey.sprite, 100, 1000);
  } else {
    textAlign(LEFT, CENTER);
    text("Wave " + wave + "/" + (waves.length - 1), 50, 975);
    text("Bloons alive: " + bloons.size(), 50, 1000);
    
    
    textAlign(RIGHT, CENTER);
    text("FPS: " + (int)frameRate + "/" + 60, 1240, 960);
    if (waveOngoing)
      text("LMB/RMB to cycle speeds.", 1240, 940);
    else
      text("Click to start wave.", 1240, 940);
    text("Speed Multiplier: " + (inverseSpeed? "1 / " + speedLevel : speedLevel), 1240, 980);
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
  float l, w;
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
  
  Button(float xPos, float yPos, float len, float wid, Runnable funct) {
    x = xPos;
    y = yPos;
    l = len;
    w = wid;
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
    if (shape == 1) return mouseX == constrain(mouseX, x - l, x + l) && mouseY == constrain(mouseY, y - w, y + w);
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
      rect(x, y, l, w);
      fill(255);
      text(text, x, y);
    }
    if (img == null) return;
    
    image(img, x, y);
  }
}

class MonkeyButton extends Button {
  Monkey monkey;
  
  MonkeyButton(Monkey m) {
    super(m.pos.x, m.pos.y, m.size, () -> {});
    monkey = m;
  }
  
  boolean select() {
    if (overButton()) {
      if (selectedButton == this) {
        selectedButton = null;
        selectedMonkey = null;
        return true;
      } else {
        selectedButton = this;
        return true;
      }
    } 
    
    
    return false;
  }
  
  void activateButton() {
    if (selectedButton == this) {
      selectedMonkey = monkey;
    }
    
    if (!overButton() && selectedButton == this) {
        selectedButton = null;
        selectedMonkey = null;
    }
  }

  void drawButton() {
    if (selectedButton == this) {
      fill(50, 50, 50, 100);
      circle(monkey.pos.x, monkey.pos.y, monkey.range);
      fill(255);
    }
  }
}
