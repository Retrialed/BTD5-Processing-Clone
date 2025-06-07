ArrayList<Monkey> monkeys = new ArrayList<Monkey>();

Monkey addMonkey(int type, int xPos, int yPos) {
  Monkey monkey = new Monkey(type, xPos, yPos);
  addMonkeyButton(monkey);
  monkeys.add(monkey);
  return monkey;
}

void runMonkeys() {
  for (Monkey m : monkeys) {
    m.attack();
  }
}

void drawMonkeys() {
  for (Monkey m : monkeys)
    m.drawMonkey();
}

class Monkey extends MonkeyType{
  PVector pos;
  float angle = 0;
  ArrayList<WeakHashMap<Bloon, Boolean>>[] tiles;
  int delay;
  
  Monkey(int typeID, int x, int y) {
    super(MonkeyTypes[typeID]);
    pos = new PVector(x, y);
    tiles = getTilesInRange(pos.x, pos.y, range);
  }
  
  Bloon target() {
    //Full Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[0]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        if ((!b.type.camo || (b.type.camo && false))) {
          angle = atan2(b.pos.y - pos.y, b.pos.x - pos.x);
          return b;
        }
      }
    }
    
    //Partial Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[1]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        if ((!b.type.camo || (b.type.camo && false)) && PVector.sub(b.pos, pos).magSq() < sq(range)) {
          angle = atan2(b.pos.y - pos.y, b.pos.x - pos.x);
          return b;
        }
      }
    }
    
    return null;
  }
  
  void attack() {
    if (delay > 0) {
      delay--;
      return;
    }
    
    Bloon target = target();
    if (target == null) return; 
    else {
      delay = cooldown;
      attack.accept(this);
    }
  }
  
  void drawMonkey() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    image(sprite, 0, 0);
    popMatrix();
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
    for (int x = mouseX - type.size; x <= mouseX + type.size; x++) {
      for (int y = mouseY - type.size; y <= mouseY + type.size; y++) {
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
      fill(50, 50, 50, 100);
      for (Monkey m : monkeys) {
        circle(m.pos.x, m.pos.y, m.size);
      }
      return;
    }
      
    image(img, x, y);
  }
}
