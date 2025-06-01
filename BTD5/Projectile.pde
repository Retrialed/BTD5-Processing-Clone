ArrayList<Proj> projs = new ArrayList<Proj>();

Proj addProj(int type, PVector position, float angle) {
  Proj proj = new Proj(type, position, angle);
  
  int[] data = projData[type];
  if (data[0] == 0) {
    proj.addComponent(new Piercing(data[5]));
  }
  projs.add(proj);
  return proj;
}

void runProjs() {
  int i = 0;
  while (i < projs.size()) {
    Proj proj = projs.get(i);
    if (!proj.live) {
      Proj last = projs.remove(projs.size() - 1);
      
      if (proj != last)
        projs.set(i, last);
      
      continue;
    }
      
    proj.move();
    proj.drawProj();
    i++;
  }
}

class Proj {
  PVector pos, vel;
  int dmg, r, time, dmgType;
  float spd;
  boolean live = true;
  ArrayList<Bloon> alreadyHit = new ArrayList<Bloon>();
  ArrayList<ProjComponent> components = new ArrayList<>();
  
  Proj(int type, PVector position, float angle) {
    int[] data = projData[type];
    dmg = data[1];
    r = data[2];
    spd = data[3];
    time = data[4];
    vel = new PVector(spd, 0).rotate(angle);
    pos = position;
  }
  
  void addComponent(ProjComponent comp) {
    comp.proj = this;
    components.add(comp);
  }
  
  void move() {
    if (time < 0 || !live) {
      live = false;
      return;
    }
    
    pos.add(vel);
    checkForBloon();
    
    time--;
  }
  
  void drawProj() {
    if (!live) return;
    circle(pos.x, pos.y, r);
  }
  
  void dmg(Bloon b) {
    for (ProjComponent comp : components) {comp.onHit(b);}
    
    if (components.size() == 0) {
      alreadyHit.addAll(b.dmg(dmg));
    }
  }
  
  void checkForBloon() {
    for (Bloon b : interactionQueue) {
      if (!live) return;
      if (alreadyHit.indexOf(b) == -1 && sq(pos.x - b.pos.x) + sq(pos.y - b.pos.y) < sq(r + bloonData[b.typeID][3])) {
        dmg(b);
      }
    }
  }
}

abstract class ProjComponent {
  Proj proj;
  
  void onHit(Bloon b) {}
}

class Piercing extends ProjComponent {
  int p;
  
  Piercing(int pierce) {
    p = pierce;
  }
  
  void onHit(Bloon b) {
    if (b.typeID == 23 || b.typeID == 44) {
      proj.live = false;
      return;
    }
    
    proj.alreadyHit.addAll(b.dmg(proj.dmg));
    p--;
    if (p <= 0) proj.live = false;
  }
}
