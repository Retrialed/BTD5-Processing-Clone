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
    i++;
  }
}

void drawProjs() {
  for (Proj p : projs)
    p.drawProj();
}

class Proj {
  ProjType type;
  PVector pos;
  PImage sprite;
  int time;
  float angle;
  boolean live = true;
  WeakHashMap<Bloon, Boolean> alreadyHit = new WeakHashMap<>();
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
      if (distRemaining < radius) {
        pos.add(new PVector(distRemaining, 0).rotate(angle));
        break;
      }
      
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
    if (!live) return;
    
    HashSet<WeakHashMap<Bloon, Boolean>>[] tiles = getTilesInRange(pos.x, pos.y, type.radius);
    
    //Full Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[0]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        dmg(b);
      }
    }
    
    //Partial Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[1]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        if (sq(pos.x - b.pos.x) + sq(pos.y - b.pos.y) < sq(type.radius + b.type.radius) && alreadyHit.get(b) == null) {
          dmg(b);
        }
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
    
    if (b.type.ID == 23 || b.type.ID >= 44) {
      proj.live = false;
      return;
    }
    
    ArrayList<Bloon> hit = b.dmg(proj.type.damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
    p--;
    if (p <= 0) proj.live = false;
  }
}

class Energy extends ProjComponent {
  void onHit(Bloon b) {
    if (!b.live) return;
    
    ArrayList<Bloon> hit = b.dmg(proj.type.damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
  }
}
