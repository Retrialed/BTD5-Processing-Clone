ArrayList<Monkey> monkeys = new ArrayList<Monkey>();
enum TargetMode {
  FIRST, LAST, STRONGEST, CLOSEST;
  
  public TargetMode next() {
    return values()[(this.ordinal() + 1) % values().length];
  }
  
  public TargetMode prev() {
    return values()[(this.ordinal() + values().length + 1) % values().length];
  }
}

Monkey addMonkey(int type, int xPos, int yPos) {
  Monkey monkey = new Monkey(type, xPos, yPos);
  Button b = new MonkeyButton(monkey);
  buttons.add(b);
  monkeys.add(monkey);
  return monkey;
}

void runMonkeys() {
  int i = 0;
  while (i < monkeys.size()) {
    Monkey m = monkeys.get(i);
    if (!m.live) {
      monkeys.remove(i);
      continue;
    }
    
    m.attack();
    i++;
  }
}

void drawMonkeys() {
  for (Monkey m : monkeys)
    m.drawMonkey();
}

class Monkey extends MonkeyType{
  PVector pos;
  float angle = 0;
  boolean live = true;
  ArrayList<WeakHashMap<Bloon, Boolean>>[] tiles;
  int[] upgrades = new int[]{0, 0};
  ArrayList<Consumer<Proj>> projUpgrades = new ArrayList();
  TargetMode targetingMode = TargetMode.FIRST;
  
  Monkey(int typeID, int x, int y) {
    super(MonkeyTypes[typeID]);
    pos = new PVector(x, y);
    tiles = getTilesInRange(pos.x, pos.y, range);
  }
  
  void refreshTiles() {
    tiles = getTilesInRange(pos.x, pos.y, range);
  }
  
  void addProjUpgrade(Consumer<Proj> upgrade) {
    projUpgrades.add(upgrade);
  }
  
  boolean upgrade(int path) {
    if (upgrades[path] >= upgradeTree[path].length || upgradeTree[path][upgrades[path]].cost > money || (upgrades[(path + 1) % 2] >= 3 && upgrades[path] >= 2)) return false;
    
    Upgrade upg = upgradeTree[path][upgrades[path]];
    money -= upg.cost;
    upg.apply(this);
    
    upgrades[path] += 1;
    return true;
  }
  
  Bloon target() {
    Bloon bloon = null;
    ArrayList<Bloon> bloonsInRange = new ArrayList();
    
    //Full Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[0]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        if ((!b.type.camo || (b.type.camo && false))) {
          bloonsInRange.add(b);
        }
      }
    }
    
    //Partial Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[1]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        if ((!b.type.camo || camoVision) && PVector.sub(b.pos, pos).magSq() < sq(range)) {
          bloonsInRange.add(b);
        }
      }
    }
    
    for (Bloon b : bloonsInRange){
      boolean bool = false;
      if (bloon == null)
        bool = true;
      else {
        switch (targetingMode) {
          case FIRST: 
            bool = isFirster(b, bloon);
            break;
          case LAST: 
            bool = !isFirster(b, bloon);
            break;
          case STRONGEST: 
            bool = isStronger(b, bloon);
            break;
          case 
            CLOSEST: bool = isCloser(b, bloon);
            break;
        }
      }
      
      if (bool)
        bloon = b;
    }
    
    if (bloon != null)
      angle = atan2(bloon.pos.y - pos.y, bloon.pos.x - pos.x);
    return bloon;
  }
  
  boolean isFirster(Bloon b1, Bloon b2) {
    return b1.curNode > b2.curNode || (b1.curNode == b2.curNode && b1.sqDistToNextNode() < b2.sqDistToNextNode());
  }
  
  boolean isStronger(Bloon b1, Bloon b2) {
    return b1.type.rbe > b2.type.rbe || (b1.type.rbe == b2.type.rbe && isFirster(b1, b2));
  }
  
  boolean isCloser(Bloon b1, Bloon b2) {
    return PVector.sub(pos, b1.pos).magSq() < PVector.sub(pos, b2.pos).magSq();
  }
  
  void attack() {
    if (!attack.cooldown()) return;
    
    Bloon target = target();
    if (target == null) return; 
    else {
      attack.activate(this);
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
