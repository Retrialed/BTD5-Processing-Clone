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
    
    bloon.move();
    bloon.drawBloon();
    i++;
  }
}

class Bloon {
  private int hp, nextNode, typeID, arrID;
  private float spd;
  private PVector pos = startPos.copy();
  private boolean dead = false;
  
  Bloon(int type) {
    typeID = type;
    hp = data(0);
    nextNode = 0;
    spd = data(1) / 30.0;
    arrID = bloons.size();
  }
  
  void dmg(int amt) {
    hp -= amt;
    money += amt;
    if (hp <= 0) {
      money += hp; //Removes extra cash from overflow
      deleteSelf();
      spawnChildren(hp); //Cash comes back here
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
  
  void deleteSelf() {
    if (bloons.size() == 1)
      bloons.remove(0);
    else {
      Bloon last = bloons.remove(bloons.size() - 1);
      bloons.set(arrID, last);
      last.arrID = arrID;
    }
  }
  
  boolean isDead() {
    return dead;
  }
  
  
  void move() {
    PVector dest = pathNodes[nextNode];
    PVector moveVec = PVector.sub(dest, pos);
    
    if (moveVec.magSq() < spd * spd) {
      pos = dest.copy();
      nextNode++;
      if (nextNode == pathNodes.length) {
        lives -= data(2);
        deleteSelf();
      }
    } else {
      pos.add(moveVec.normalize().mult(spd));
    }
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
