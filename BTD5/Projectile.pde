ArrayList<Proj> projs = new ArrayList<Proj>();

Proj addProj() {
  Proj proj = new Proj(1, 50, 0, 300000, new PVector(width / 2, height/2 + 200), (float) Math.PI / 4);
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
      
    proj.drawProj();
    proj.move();
    i++;
  }
}

class Proj {
  PVector pos, vel;
  int dmg, r, time;
  float spd;
  boolean live = true;
  ArrayList<Bloon> alreadyHit = new ArrayList<Bloon>();
  
  Proj(int damage, int radius, int speed, float duration, PVector position, float angle) {
    dmg = damage;
    r = radius;
    spd = speed / 45.0;
    time = (int) (duration * 60);
    vel = new PVector(spd, 0).rotate(angle);
    pos = position;
  }
  
  void move() {
    if (time < 0) {
      live = false;
      return;
    }
    
    pos.add(vel);
    checkForBloon();
    
    time--;
  }
  
  void drawProj() {
    fill(100);
    circle(pos.x, pos.y, r);
    fill(255);
  }
  
  void checkForBloon() {
    for (Bloon b : interactionQueue) {
      if (alreadyHit.indexOf(b) == -1 && sq(pos.x - b.pos.x) + sq(pos.y - b.pos.y) < sq(r + b.data(3))) {
        b.dmg(this);
        alreadyHit.add(b);
      }
    }
  }
}
