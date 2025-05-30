ArrayList<Bloon> bloons = new ArrayList<Bloon>();

Bloon addBloon(int type) {
  Bloon bloon = new Bloon(type);
  bloons.add(bloon);
  return bloon;
}

void runBloons() {
  int i = 0;
  while (i < bloons.size()) {
    Bloon bloon = bloons.get(i);
    if (!bloon.isAlive()) {
      Bloon last = bloons.remove(bloons.size() - 1);
      
      if (bloon != last)
        bloons.set(i, last);
      
      continue;
    }
      
    bloon.move();
    bloon.move();
    bloon.drawBloon();
    i++;
  }
}

class Bloon {
  private int hp, nextNode, typeID;
  private float spd;
  private boolean live = true;
  PVector pos = pathNodes[0];
  private PVector vel = null;
  
  Bloon(int type) {
    typeID = type;
    hp = data(0);
    nextNode = 0;
    spd = data(1) / (float) speeds[0] / 2.0;
  }
  
  void dmg(int amt) {
    hp -= amt;
    money += amt;
    if (hp <= 0) {
      money += hp; //Removes extra cash from overflow
      spawnChildren(hp); //Cash comes back here
      live = false;
    }
  }
  
  void spawnChildren(int overflow) {
    int count = 0;
    for (int i : children[typeID]) {
      Bloon child = addBloon(i);
      child.pos = pos.copy();
      child.nextNode = nextNode;
      for (int j = 0; j < count * 4; j++)
        child.move();
      child.dmg(-1 * overflow);
      count++;
    }
  }
  
  
  void move() {
    if (nextNode >= pathNodes.length) {return;}
    
    PVector dest = pathNodes[nextNode];
    vel = PVector.sub(dest, pos);
    
    if (vel.magSq() < spd * spd) {
      pos = dest.copy();
      nextNode++;
      if (nextNode >= pathNodes.length) {
        lives -= data(2);
        live = false;
      }
    } else {
      pos.add(vel.normalize().mult(spd));
    }
  }
  
  boolean isAlive() {
    return live;
  }
  
  void drawBloon() {
    if (10 <= typeID && typeID <= 12) {
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(vel.heading());
      image(bloonSprites[typeID], 0, 0);
      popMatrix();
    } else {
      image(bloonSprites[typeID], pos.x, pos.y);
    }
  }
  
  int data(int ind) {
    return bloonData[typeID][ind];
  }
}
