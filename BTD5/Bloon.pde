ArrayList<Bloon> bloons = new ArrayList<Bloon>();

int[][] bloonData = new int[][]{
  {2, 2, 2, 2} //example data
};
int[][] nodes = new int[][] {
  {1,2}, {2, 3} //example data
};

PVector[] pathNodes = new PVector[nodes.length];


PVector startPos = new PVector(0, 0);

class Bloon {
  int hp, nextNode, typeID, arrID;
  PVector pos = startPos.copy();
  
  void dmg(int amt) {
    hp -= amt;
    while (hp <= 0) {
      typeID -= 1;
      hp += bloonData[typeID][1];
    }
    if (typeID < 0)
      deleteSelf();
  }
  
  void deleteSelf() {
    bloons.set(arrID, bloons.remove(bloons.size() - 1));
  }
  
  void move() {
    int spd = bloonData[typeID][2]; //Speed will be held inside array. Accessed by reference to datatable
    PVector dest = pathNodes[nextNode];
    
    PVector moveVec = dest.sub(pos);
    float distMoved = spd / 60; //Spd in pixels/sec
    
    if (moveVec.magSq() < distMoved * distMoved)
      pos = dest.clone();
    else
      pos.add(,)
  }
}
