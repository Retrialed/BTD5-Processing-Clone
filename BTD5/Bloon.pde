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
  regrow.heritage.addAll(parent.heritage);
  regrow.heritage.add(parent.type.ID);
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
      
    bloon.move();
    bloon.refreshGrid();
    bloon.drawBloon();
    i++;
  }
}

class RegrowBloon extends Bloon {
   ArrayList<Integer> heritage = new ArrayList<>();
   int timer = 0;
   
   RegrowBloon(BloonType type) {
     super(type);
   }
   
   void move() {
     super.move();
     timer++;
     if (timer >= 120 && heritage.size() != 0) {
       timer = 0;
       type = BloonTypes[(heritage.remove(heritage.size() - 1))];
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

class Bloon {
  int hp, curNode;
  boolean live = true;
  PVector pos = pathNodes[0].copy();
  float angle = 0;
  ArrayList<BloonComponent> components = new ArrayList<>();
  int inRow = 0;
  int inCol = 0;
  
  BloonType type;
  
  void addComponent(BloonComponent comp) {
    comp.bloon = this;
    components.add(comp);
  }
  
  Bloon(BloonType bType) {
    type = bType;
    curNode = 0;
    hp = type.hp;
  }
  
  ArrayList<Bloon> dmg(int amt) {
    ArrayList<Bloon> spawned = dmg(amt, 1);
    
    int count = 0;
        
    for (Bloon child : spawned) {
      child.pos = pos.copy();
      child.curNode = curNode;
      
      for (int j = 0; j < (count + 1) / 2; j++) {
        child.move(count % 2 == 0? 1 : -1, (float) 675 / type.speed);
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
  
  void move() {
    move(1, 1);
  }
  
  void move(int increment, float mult) {
    float spdSq = sq(type.speed * mult / 45.0);
    
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
  }
}

abstract class BloonComponent {
  Bloon bloon;
}
