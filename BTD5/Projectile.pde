ArrayList<Proj> projs = new ArrayList<Proj>();

Proj addProj(int type, PVector position, float angle, PImage spriteAdded) {
  Proj proj = new Proj(type, position, angle, spriteAdded);
  if (ProjTypes[type].dmgType == 0) {
    proj.addComponent(new Piercing(ProjTypes[type].extra));
  } else if (ProjTypes[type].dmgType == 1) {
    proj.addComponent(new Energy());
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
    
    proj.time--;
    proj.move();
    proj.move();
    proj.drawProj();
    i++;
  }
}

class Proj {
  ProjType type;
  PVector pos;
  PImage sprite;
  int time;
  float angle;
  boolean live = true;
  ArrayList<Bloon> alreadyHit = new ArrayList<Bloon>();
  ArrayList<ProjComponent> components = new ArrayList<>();
  
  Proj(int typeID, PVector position, float spawnAngle, PImage spriteAdded) {
    type = ProjTypes[typeID];
    time = type.lifespan;
    pos = position;
    angle = spawnAngle;
    sprite = spriteAdded;
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
    
    float distRemaining = type.speed;
    int radius = type.radius;
    while (distRemaining > 0) {
      if (distRemaining < radius)
        pos.add(new PVector(distRemaining, 0).rotate(angle));
      
      pos.add(new PVector(radius, 0).rotate(angle));
      distRemaining -= radius;
      checkForBloon();
    }
  }
  
  void drawProj() {
    if (!live) return;
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    image(sprite, 0, 0);
    popMatrix();
  }
  
  void dmg(Bloon b) {
    for (ProjComponent comp : components) {comp.onHit(b);}
  }
  
  void checkForBloon() {
    for (Bloon b : interactionQueue) {
      if (!live) return;
      if (alreadyHit.indexOf(b) == -1 && sq(pos.x - b.pos.x) + sq(pos.y - b.pos.y) < sq(type.radius + b.type.radius)) {
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
    if (!b.live) return;
    
    if (b.type.ID == 23 || b.type.ID == 44) {
      proj.live = false;
      return;
    }
    
    proj.alreadyHit.addAll(b.dmg(proj.type.damage));
    p--;
    if (p <= 0) proj.live = false;
  }
}

class Energy extends ProjComponent {
  void onHit(Bloon b) {
    if (!b.live) return;
    
    proj.alreadyHit.addAll(b.dmg(proj.type.damage));
  }
}
