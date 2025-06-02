import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

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
    m.drawMonkey();
  }
}

class Monkey {
  MonkeyType type;
  
  PVector pos;
  int delay;
  float angle = 0;
  
  Consumer<Monkey> attack;
  
  Monkey(int typeID, int x, int y) {
    pos = new PVector(x, y);
    type = MonkeyTypes[typeID];
    delay = type.delay;
    attack = type.attack;
  }
  
  Bloon target() {
    for (Bloon b : interactionQueue) {
      if (PVector.sub(b.pos, pos).magSq() < type.range * type.range) {
        angle = atan2(b.pos.y - pos.y, b.pos.x - pos.x);
        return b;
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
      delay = type.delay;
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
