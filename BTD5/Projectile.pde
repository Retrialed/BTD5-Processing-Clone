ArrayList<Proj> projs = new ArrayList<Proj>();

Proj addProj() {
  Proj proj = new Proj(1, 1, 10, 100, new PVector(800, 800), new PVector(10, 10));
  projs.add(proj);
  return proj;
}

void runProjs() {
  
}

class Proj {
  private PVector pos, vel;
  private int dmg, p, r, d;
  private boolean live = true;
  
  Proj(int damage, int pierce, int radius, int distance, PVector position, PVector velocity) {
    dmg = damage;
    p = pierce; 
    r = radius;
    d = distance;
    pos = position;
    vel = velocity;
  }
  
  void move() {
    if (p <= 0 || d <= 0) {
      live = false;
      return;
    }
    
    pos.add(vel);
    d -= vel.mag();
    checkForBloon();
  }
  
  void draw() {
    fill(100);
    circle(pos.x, pos.y, r);
    fill(255);
  }
  
  void checkForBloon() {
    for (Bloon b : bloons) {
      if (sq(pos.x - b.pos.x) + sq(pos.y - b.pos.y) < sq(r + b.data(3))) {
        b.dmg(dmg);
        p -= 1;
      }
    }
  }
}
