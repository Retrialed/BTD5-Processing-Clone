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

class Monkey {
  MonkeyType type;
  
  PVector pos;
  float angle = 0;
  ArrayList<WeakHashMap<Bloon, Boolean>>[] tiles;
  
  
  int ID;
  String name, atkName;
  Consumer<Monkey> attack;
  PImage sprite;
  int range, delay, size, cost;
  
  Monkey(int typeID, int x, int y) {
    type = MonkeyTypes[typeID].clone();
    pos = new PVector(x, y);
    tiles = getTilesInRange(pos.x, pos.y, type.range);
    
    
    ID = type.ID;
    name = type.name;
    attack = type.attack;
    sprite = type.sprite;
    range = type.range;
    delay = type.delay;
    size = type.size;
    cost = type.cost;
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
        if ((!b.type.camo || (b.type.camo && false)) && PVector.sub(b.pos, pos).magSq() < sq(type.range)) {
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
      delay = getStat("delay");
      attack.accept(this);
    }
  }
  
  void drawMonkey() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    image(type.sprite, 0, 0);
    popMatrix();
  }
}
