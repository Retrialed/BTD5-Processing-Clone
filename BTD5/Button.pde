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
  
  Button speedButton = new Button(1293, 959, 45, () -> {
    if (waveOngoing == false) {
      startWave();
      return;
    }
    if (mouseButton == LEFT) {
      //speedLevel += inverseSpeed? -1 : 1;
      if (inverseSpeed)
        speedLevel -= 1;
      else
        speedLevel *= 2;
      if (speedLevel == 1) {
        inverseSpeed = false;
      }
    } else if (mouseButton == RIGHT) {
      if (speedLevel == 1) {
        inverseSpeed = true;
      }
      if (inverseSpeed)
        speedLevel += 1;
      else
        speedLevel *= 0.5;
    }
  });
  speedButton.setImage("images/preround.png");
  buttons.add(speedButton);
  
  Button resetSpeed = new Button(1293, 1010, 80, 9, () -> {speedLevel = 1; inverseSpeed = false;});
  buttons.add(resetSpeed);
  
  Button sellButton = new Button(100, 1020, 90, 22, () -> {
      selectedMonkey.live = false;
      selectedButton.live = false;
      money += selectedMonkey.cost * 0.8;
      selectedMonkey = null;
      selectedButton = null;
    }
  );
  sellButton.setImage("images/sell.png");
  selectedMonkeyButtons.add(sellButton);
  
  Button target = new Button(100, 1060, 90, 20, () -> {});
  target.setImage("images/targeting.png");
  selectedMonkeyButtons.add(target);
  
  Button left = new Button(32, 1060, 22, () -> {
    selectedMonkey.targetingMode = selectedMonkey.targetingMode.prev();
  });
  selectedMonkeyButtons.add(left);
  
  Button right = new Button(168, 1060, 22, () -> {
    selectedMonkey.targetingMode = selectedMonkey.targetingMode.next();
  });
  selectedMonkeyButtons.add(right);
  
  PImage upgrade = loadImage("images/upgrade.png");
  upgrade.resize(450, 150);
  
  Button upg1 = new Button(450, 1000, 225, 75, () -> {
    if (selectedMonkey.upgrade(0));
  });
  upg1.img = upgrade;
  selectedMonkeyButtons.add(upg1);
  
  Button upg2 = new Button(950, 1000, 225, 75, () -> {selectedMonkey.upgrade(1);});
  upg2.img = upgrade;
  selectedMonkeyButtons.add(upg2);
  
  for (MonkeyType type : MonkeyTypes) {
    SpawnButton b = new SpawnButton(type);
    buttons.add(b);
  }
  
  if (HALP) {
    Button add = new Button(100, 100, 50, () -> addBloon(43));
    buttons.add(add);
    Button add1 = new Button(100, 200, 50, () -> addBloon(10));
    buttons.add(add1);
    Button add2 = new Button(100, 300, 50, () -> addBloon(11));
    buttons.add(add2);
    Button add3 = new Button(100, 400, 50, () -> addBloon(12));
    buttons.add(add3);
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
    for (Button b : selectedMonkeyButtons) {
      b.drawButton();
    }
    textAlign(CENTER, CENTER);
    text(selectedMonkey.name, 100, 920);
    image(selectedMonkey.sprite, 100, 965);
    text("Sell: $" + (int) (selectedMonkey.cost * 0.8), 100, 1020);
    text(selectedMonkey.targetingMode.toString(), 100, 1060);
    Upgrade up1 = null;
    Upgrade up2 = null;
    if (selectedMonkey.upgrades[0] < selectedMonkey.upgradeTree[0].length) 
      up1 = selectedMonkey.upgradeTree[0][selectedMonkey.upgrades[0]];
    if (selectedMonkey.upgrades[1] < selectedMonkey.upgradeTree[1].length) 
      up2 = selectedMonkey.upgradeTree[1][selectedMonkey.upgrades[1]];
      
    String up1Text = "Max Upgrade Reached";
    String up2Text = "Max Upgrade Reached";
    
    if (up1 != null)
      up1Text = up1.desc + "\nCost: " + up1.cost;
    if (up2 != null)
      up2Text = up2.desc + "\nCost: " + up2.cost;
      
    if (selectedMonkey.upgrades[0] >= 3 && selectedMonkey.upgrades[1] >= 2)
      up2Text = "Locked Out: Other path has already been upgraded thrice.";
    if (selectedMonkey.upgrades[1] >= 3 && selectedMonkey.upgrades[0] >= 2)
      up1Text = "Locked Out: Other path has already been upgraded thrice.";
      
    text(up1Text, 450, 1000, 225, 75);
    text(up2Text, 950, 1000, 225, 75);
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
  
  int i = 0;
  while (i < buttons.size()) {
    Button button = buttons.get(i);
    if (!button.live) {
      buttons.remove(i);
      continue;
    }
    i++;
  }
}

void drawButtons() {
  for (Button button : buttons)
    button.drawButton();
  
  textAlign(CENTER, CENTER);
  text("Click to reset speed", 1293, 1010);
}

void activateButtons() {
  int i = 0;
  while (i < buttons.size()) {
    Button button = buttons.get(i);
    if (button.select()) break;
    i++;
  }
  
  i = 0;
  while (i < buttons.size()) {
    Button button = buttons.get(i);
    button.activateButton();
    i++;
  }
  
  i = 0;
  while (i < selectedMonkeyButtons.size() && selectedMonkey != null) {
    Button button = selectedMonkeyButtons.get(i);
    button.activateButton();
    i++;
  }
}

class Button {
  float x, y, r;
  float l, w;
  int shape;
  boolean live = true;
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
  
  boolean select() {return false;}

  boolean overButton() {
    if (shape == 0) return sq(x - mouseX) + sq(y - mouseY) < sq(r);
    if (shape == 1) return mouseX == constrain(mouseX, x - l, x + l) && mouseY == constrain(mouseY, y - w, y + w);
    return false;
  }

  void drawButton() {
    if (img == null) {
      if (shape == 0) {
        fill(50, 50, 50, 100);
        circle(x, y, r);
        fill(255);
      }
      if (shape == 1) {
        fill(50, 50, 50, 100);
        rect(x, y, l, w);
        fill(255);
      }
    
      return;
    }
    
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
    
    if (!overButton() && selectedButton == this && mouseY < 900) {
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
    for (int x = Math.max(mouseX - type.size, 0); x <= Math.min(mouseX + type.size, width); x++) {
      for (int y = Math.max(mouseY - type.size, 0); y <= Math.min(mouseY + type.size, height); y++) {
        float dx = x - mouseX;
        float dy = y - mouseY;
        
        if (dx * dx + dy * dy > sq(type.size)) continue;
        
        if (placementGrid[x][y] > 0) return false;
      }
    }
    
    for (Monkey m : monkeys) {
      float dx = m.pos.x - mouseX;
      float dy = m.pos.y - mouseY;
      if (sq(dx) + sq(dy) < sq(m.size + type.size)) {
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
      image(img, mouseX, mouseY);
      circle(mouseX, mouseY, type.size);
      fill(255);
      textAlign(CENTER, CENTER);
      text("Cost: " + type.cost, mouseX, mouseY - 40);
      fill(50, 50, 50, 100);
      for (Monkey m : monkeys) {
        circle(m.pos.x, m.pos.y, m.size);
      }
      return;
    }
      
    image(img, x, y);
  }
}
