ArrayList<Bloon> bloons = new ArrayList<Bloon>();
ArrayList<Bloon> interactionQueue = new ArrayList<Bloon>();

Bloon addBloon(int type) {
  Bloon bloon;
  
  if ((13 <= type && type <= 22) || (34 <= type && type <= 43)) {
    bloon = new RegrowBloon(type);
  } else {
    bloon = new Bloon(type);
  }
  bloons.add(bloon);
  return bloon;
}

RegrowBloon addRegrowBloon(int type) {
  RegrowBloon regrow = new RegrowBloon(type);
  bloons.add(regrow);
  return regrow;
}

RegrowBloon addRegrowBloon(int type, RegrowBloon parent) {
  RegrowBloon regrow = addRegrowBloon(type);
  regrow.heritage.addAll(parent.heritage);
  regrow.heritage.add(parent.typeID);
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
      
      continue;
    }
      
    bloon.move();
    bloon.drawBloon();
    interactionQueue.add(bloon);
    i++;
  }
}

class RegrowBloon extends Bloon {
   ArrayList<Integer> heritage = new ArrayList<>();
   int timer = 0;
   
   RegrowBloon(int type) {
     super(type);
   }
   
   void move() {
     super.move();
     timer++;
     if (timer >= 120 && heritage.size() != 0) {
       live = false;
       RegrowBloon grown = addRegrowBloon(heritage.remove(heritage.size() - 1));
       grown.pos = pos;
       grown.curNode = curNode;
       grown.heritage = heritage;
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
    
      for (int i : children[typeID]) {
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
  int hp, curNode, typeID;
  boolean live = true;
  PVector pos = pathNodes[0].copy();
  float angle = 0;
  ArrayList<BloonComponent> components = new ArrayList<>();
  
  void addComponent(BloonComponent comp) {
    comp.bloon = this;
    components.add(comp);
  }
  
  Bloon(int type) {
    typeID = type;
    hp = bloonData[typeID][0];
    curNode = 0;
  }
  
  ArrayList<Bloon> dmg(int amt) {
    ArrayList<Bloon> spawned = dmg(amt, 1);
    
    int count = 0;
        
    for (Bloon child : spawned) {
      child.pos = pos.copy();
      child.curNode = curNode;
      
      for (int j = 0; j < (count + 1) / 2; j++) {
        child.move(count % 2 == 0? 1 : -1, 2);
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
    
      for (int i : children[typeID]) {
        spawned.addAll(addBloon(i).dmg(-1 * hp, 1));
      }
      
      return spawned;
    }
    
    ArrayList<Bloon> listWithSelf = new ArrayList<Bloon>();
    listWithSelf.add(this);
    return listWithSelf;
  }
  
  void move() {
    move(1, 1);
  }
  
  void move(int increment, int mult) {
    if (!live)
      return;
  
    int nextNode = (increment == 1)? curNode + increment : curNode;
  
    if (nextNode >= pathNodes.length) {
      lives -= bloonData[typeID][2];
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
    float distSq = dx * dx + dy * dy;
    float spdSq = bloonData[typeID][1] * bloonData[typeID][1] / 2025.0 * mult * mult;
  
    while (distSq <= spdSq) {
      pos.set(dest);
      spdSq -= distSq;
  
      curNode = constrain(curNode + increment, 0, pathNodes.length - 1);    
      nextNode = (increment == -1) ? curNode : curNode + increment;
  
      if (nextNode >= pathNodes.length) {
        lives -= bloonData[typeID][2];
        live = false;
        return;
      }
  
      if (curNode + increment < 0) {
        pos.set(pathNodes[0]);
        curNode = 0;
        return;
      }
  
  
      dest = pathNodes[nextNode];
      dx = dest.x - pos.x;
      dy = dest.y - pos.y;
      distSq = dx * dx + dy * dy;
    }
  
    float scale = sqrt(spdSq / distSq);
    pos.x += scale * dx;
    pos.y += scale * dy;
  }

  
  void drawBloon() {
    if (!live) {
      return;
    }
    
    if (10 <= typeID && typeID <= 12) {
      pushMatrix();
      translate(pos.x, pos.y);
      PVector dest = pathNodes[curNode];
      rotate(atan2(dest.y - pos.y, dest.x - pos.x) + (float) Math.PI);
      image(bloonSprites[typeID], 0, 0);
      popMatrix();
    } else {
      image(bloonSprites[typeID], pos.x, pos.y);
    }
  }
}

abstract class BloonComponent {
  Bloon bloon;
}
