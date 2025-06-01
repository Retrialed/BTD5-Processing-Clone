ArrayList<Bloon> bloons = new ArrayList<Bloon>();
ArrayList<Bloon> interactionQueue = new ArrayList<Bloon>();

Bloon addBloon(int type) {
  Bloon bloon = new Bloon(type);
  bloons.add(bloon);
  return bloon;
}

void runBloons() {
  int i = 0;
  while (i < bloons.size()) {
    Bloon bloon = bloons.get(i);
    if (!bloon.live) {
      Bloon last = bloons.remove(bloons.size() - 1);
      
      if (bloon != last)
        bloons.set(i, last);
      
      continue;
    }
      
    bloon.drawBloon();
    bloon.move();
    interactionQueue.add(bloon);
    i++;
  }
}

class Bloon {
  int hp, curNode, typeID;
  boolean live = true;
  PVector pos = pathNodes[0].copy();
  float angle = 0;
  
  Bloon(int type) {
    typeID = type;
    hp = data(0);
    curNode = 0;
  }
  
  void dmg(Proj proj) {
    proj.alreadyHit.addAll(dmg(proj.dmg));
  }
  
  ArrayList<Bloon> dmg(int amt) {
    if (!live)
      return new ArrayList<Bloon>();
    
    money += Math.min(hp, amt);
    hp -= amt;
    if (hp <= 0) {
      live = false;
      
      return spawnChildren(hp);
    }
    
    ArrayList<Bloon> listWithSelf = new ArrayList<Bloon>();
    listWithSelf.add(this);
    return listWithSelf;
  }
  
  ArrayList<Bloon> spawnChildren(int overflow) {
    overflow *= -1;
    ArrayList<Integer> spawned = getSpawned(overflow, typeID);
    ArrayList<Bloon> spawnedBloons = new ArrayList<>();
    
    int count = 0;
    for (int i : spawned) {
      Bloon child = addBloon(i);
      child.pos = pos.copy();
      child.curNode = curNode;
      
      for (int j = 0; j < (count + 1) / 2; j++) {
        child.move(count % 2 == 0? 1 : -1, 2);
      }
      
      spawnedBloons.add(child);
      count++;
    }
    
    return spawnedBloons;
  }
  
  ArrayList<Integer> getSpawned(int overflow, int id) {
    ArrayList<Integer> spawned = new ArrayList<>();
    
    for (int i : children[id]) {
      if (overflow < bloonData[i][0]) {
        money += overflow;
        spawned.add(i);
      } else {
        money += bloonData[i][0];
        spawned.addAll(getSpawned(overflow - bloonData[i][0], i));
      }
    }
    
    return spawned;
  }
  
  void move() {
    move(1, 1);
  }
  
void move(int increment, int mult) {
  if (!live)
    return;

  int nextNode = (increment == 1)? curNode + increment : curNode;

  if (nextNode >= pathNodes.length) {
    lives -= data(2);
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
  float spdSq = data(1) * data(1) / 2025.0 * mult * mult;

  while (distSq <= spdSq) {
    pos.set(dest);
    spdSq -= distSq;

    curNode = constrain(curNode + increment, 0, pathNodes.length - 1);    
    nextNode = (increment == -1) ? curNode : curNode + increment;

    if (nextNode >= pathNodes.length) {
      lives -= data(2);
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
    if (10 <= typeID && typeID <= 12) {
      pushMatrix();
      translate(pos.x, pos.y);
      PVector dest = pathNodes[curNode];
      rotate(atan2(dest.y - pos.y, dest.x - pos.x));
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
