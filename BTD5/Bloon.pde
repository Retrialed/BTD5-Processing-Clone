ArrayList<Bloon> bloons = new ArrayList<Bloon>();

Bloon addBloon(int typeID) {
  Bloon bloon;
  BloonType type = BloonTypes[typeID];
  
  if (type.regrow) {
    bloon = new RegrowBloon(type);
  } else {
    bloon = new Bloon(type);
  }
  bloons.add(bloon);
  return bloon;
}

RegrowBloon addRegrowBloon(int typeID) {
  RegrowBloon regrow = new RegrowBloon(BloonTypes[typeID]);
  bloons.add(regrow);
  return regrow;
}

RegrowBloon addRegrowBloon(int typeID, RegrowBloon parent) {
  RegrowBloon regrow = addRegrowBloon(typeID);
  regrow.heritage = new Node(regrow.type.ID, parent.heritage);
  return regrow;
}

void runBloons() {
  int i = 0;
  while (i < bloons.size()) {
    Bloon bloon = bloons.get(i);
    if (!bloon.live) {
      
      //bloons.remove(i);
      
      Bloon last = bloons.remove(bloons.size() - 1);
      if (bloon != last)
        bloons.set(i, last);
      
      grid[bloon.inRow][bloon.inCol].remove(bloon);
      continue;
    }
    
    bloon.passTime();
    bloon.move();
    bloon.refreshGrid();
    i++;
  }
}

void drawBloons() {
  for (Bloon b : bloons)
    b.drawBloon();
}

class RegrowBloon extends Bloon {
   Node heritage;
   int timer = 0;
   
   RegrowBloon(BloonType type) {
     super(type);
     heritage = new Node(type.ID);
   }
   
   void move() {
     super.move();
     timer++;
     if (timer >= 120 && heritage.next != null) {
       timer = 0;
       heritage = heritage.next;
       type = BloonTypes[heritage.data];
       hp = type.hp;
     }
   }
   
   ArrayList<Bloon> dmg(int amt, int placeHolder) {
    if (amt < 0)
      amt *= -1;
    
    if (!live)
      return new ArrayList<Bloon>();
    
      money += Math.min(hp, amt);
      hp -= amt;
      if (hp <= 0) {
        live = false;
      
      ArrayList<Bloon> spawned = new ArrayList<Bloon>();
    
      for (int i : type.children) {
        spawned.addAll(addRegrowBloon(i, this).dmg(-1 * hp, 1));
      }
      
      return spawned;
    }
    
    ArrayList<Bloon> listWithSelf = new ArrayList<Bloon>();
    listWithSelf.add(this);
    return listWithSelf;
  }
}

abstract class StatusEffect extends Component{
  Bloon bloon;
  int timer;
  
  StatusEffect(int timer){
    this.timer = timer;
  }
  
  StatusEffect(StatusEffect other) {
    timer = other.timer;
  }
  
  abstract StatusEffect copy();
}

class SpeedMult extends StatusEffect {
  float spdMult;
  
  SpeedMult(int timer, float mult) {
    super(timer);
    eventName = "Moving";
    spdMult = mult;
  }
  
  SpeedMult(SpeedMult other) {
    super(other);
    eventName = "Moving";
    spdMult = other.spdMult;
  }
  
  void activate(Object... args) {
    bloon.speed *= spdMult;
    if (spdMult < 0 && bloon.speed > 0)
      bloon.speed *= -1;
  }
  
  SpeedMult copy() {
    return new SpeedMult(this);
  }
}

class Bloon {
  int hp, curNode;
  boolean live = true;
  PVector pos = pathNodes[0].copy();
  float angle = 0;
  int inRow = 0;
  int inCol = 0;
  float speed;
  HashMap<String, StatusEffect> activeEffects = new HashMap();
  BloonType type;
  
  Bloon(BloonType bType) {
    type = bType;
    curNode = 0;
    hp = type.hp;
  }
  
  void passTime() {
    Iterator<Map.Entry<String, StatusEffect>> it = activeEffects.entrySet().iterator();

    while (it.hasNext()) {
      Map.Entry<String, StatusEffect> entry = it.next();
      StatusEffect effect = entry.getValue();
    
      if (effect.timer < 0)
        it.remove();
        
      effect.timer--;
    }
  }
  
  void addEffect(StatusEffect se) {
    StatusEffect newSE = se.copy();
    activeEffects.put(se.getClass().getSimpleName(), newSE);
    newSE.bloon = this;
  }
  
  ArrayList<Bloon> dmg(int amt) {
    ArrayList<Bloon> spawned = dmg(amt, 1);
    
    int count = 0;
        
    for (Bloon child : spawned) {
      child.pos = pos.copy();
      child.curNode = curNode;
      
      for (StatusEffect effect : activeEffects.values()) {
        child.addEffect(effect);
      }
      
      for (int j = 0; j < (count + 1) / 2; j++) {
        child.move(1, (float) 675 / type.speed, type.speed * (count % 2 == 0? 1 : -1));
      }
      
      count++;
    }
    
    return spawned;
  }
  
  ArrayList<Bloon> dmg(int amt, int placeHolder) {
    if (amt < 0)
      amt *= -1;
    
    if (!live)
      return new ArrayList<Bloon>();
    
    money += Math.min(hp, amt);
    hp -= amt;
    if (hp <= 0) {
      live = false;
      
      ArrayList<Bloon> spawned = new ArrayList<Bloon>();
    
      for (int i : type.children) {
        spawned.addAll(addBloon(i).dmg(-1 * hp, 1));
      }
      
      return spawned;
    }
    
    ArrayList<Bloon> listWithSelf = new ArrayList<Bloon>();
    listWithSelf.add(this);
    return listWithSelf;
  }
  
  void refreshGrid() {
    int newRow = gridRow(pos.y);
    int newCol = gridCol(pos.x);
    if (newRow != inRow || newCol != inCol) {
      grid[inRow][inCol].remove(this);
      grid[newRow][newCol].put(this, true);
      inRow = newRow;
      inCol = newCol;
    }
  }
  
  float getSpeed() {
    speed = type.speed;
    
    for (StatusEffect se : activeEffects.values())
      if (se.eventName.equals("Moving"))
        se.activate();
    
    return speed;
  }
  
  void move() {
    move(1, 1, getSpeed());
  }
  
  void move(int increment, float mult, float speed) {
    if (speed < 0) {
      move(-1, 1, speed * -1);
      return;
    }
      
    float spdSq = sq(speed * mult / 45.0);
    
    while (true) {
      if (!live)
        return;
    
      int nextNode = curNode;
      if (increment == 1) nextNode++;
    
      if (nextNode >= pathNodes.length) {
        lives -= type.rbe;
        live = false;
        return;
      }
    
      if (nextNode < 0) {
        pos.set(pathNodes[0]);
        curNode = 0;
        return;
      }
      
      PVector dest = pathNodes[nextNode];
      float dx = dest.x - pos.x;
      float dy = dest.y - pos.y;
      float distSq = sq(dx) + sq(dy);
      
      if (distSq <= spdSq) {
        pos.set(dest);
        spdSq -= distSq;
        if (increment == 1) {
          curNode++;
        } else if (increment == -1) {
          curNode--;
          if (curNode < 0) {
            curNode = 0;
            return;
          }
        }
      } else { 
        float scale = sqrt(spdSq / distSq);
        pos.x += scale * dx;
        pos.y += scale * dy;
        return;
      }
    }
  }
  
  float sqDistToNextNode() {
    PVector dest = pathNodes[curNode + 1];
    float dx = dest.x - pos.x;
    float dy = dest.y - pos.y;
    return sq(dx) + sq(dy);
  }

  
  void drawBloon() {
    if (!live) {
      return;
    }
    
    if (10 <= type.ID && type.ID <= 12) {
      pushMatrix();
      translate(pos.x, pos.y);
      PVector dest = pathNodes[curNode];
      rotate(atan2(pos.y - dest.y, pos.x - dest.x));
      image(type.sprite, 0, 0);
      popMatrix();
    } else {
      image(type.sprite, pos.x, pos.y);
    }
    
    if (HALP) {
      fill(255);
      textAlign(CENTER, CENTER);
      text(hp, pos.x, pos.y);
    }
  }
}

class Node {
  int data;
  Node next;
  
  Node(int d, Node n) {
    data = d;
    next = n;
  }
  
  Node(int d){
    data = d;
  }
}
