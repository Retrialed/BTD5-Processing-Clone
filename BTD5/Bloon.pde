ArrayList<Bloon> bloons = new ArrayList<Bloon>();
PVector startPos = new PVector(1244, 85);

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
      bloons.remove(i);
      continue;
    }
      
    bloon.move();
    bloon.drawBloon();
    i++;
  }
}

class Bloon {
  private int hp, nextNode, typeID;
  private float spd;
  private boolean live = true;
  private PVector pos = startPos.copy();
  
  Bloon(int type) {
    typeID = type;
    hp = data(0);
    nextNode = 0;
    spd = data(1) / (float) speeds[0];
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
    for (int i : children[typeID]) {
      Bloon child = addBloon(i);
      child.dmg(-1 * overflow);
      child.pos = pos.copy();
      child.nextNode = nextNode;
    }
  }
  
  
  void move() {
    PVector dest = pathNodes[nextNode];
    PVector moveVec = PVector.sub(dest, pos);
    
    if (moveVec.magSq() < spd * spd) {
      pos = dest.copy();
      nextNode++;
      if (nextNode == pathNodes.length) {
        lives -= data(2);
        live = false;
      }
    } else {
      pos.add(moveVec.normalize().mult(spd));
    }
  }
  
  boolean isAlive() {
    return live;
  }
  
  void drawBloon() {
    fill(bloonColors[typeID]);
    circle(pos.x, pos.y, 30);
    fill(255);
  }
  
  int data(int ind) {
    return bloonData[typeID][ind];
  }
}
