ArrayList<Proj> projs = new ArrayList<Proj>();
HashMap<String, Supplier<ProjComponent>> componentRegistry = new HashMap<>() {{
  put("Piercing", Piercing::new);
  put("Sharp", Sharp::new);
  put("Universal", Universal::new);
  put("Crushing", Crushing::new);
}};

Proj addProj(ProjType type, PVector position, float angle) {
  Proj proj = new Proj(type, position, angle);
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
    i++;
  }
}

void drawProjs() {
  for (Proj p : projs)
    p.drawProj();
}

class Proj extends ProjType{
  PVector pos;
  float distanceRemaining;
  float angle;
  boolean live = true;
  WeakHashMap<Bloon, Boolean> alreadyHit = new WeakHashMap<>();
  ArrayList<ProjComponent> components = new ArrayList<>();
  
  Proj(ProjType type, PVector position, float spawnAngle) {
    super(type);
    distanceRemaining = distance;
    pos = position;
    angle = spawnAngle;
    try {
      for (String className : comps) {
        Supplier<ProjComponent> factory = componentRegistry.get(className);
        if (factory != null) addComponent(factory.get());
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  void addComponent(ProjComponent comp) {
    comp.proj = this;
    components.add(comp);
  }
  
  void move() {
    float distRemaining = speed;
    while (distRemaining > 0) {
      if (distanceRemaining < 0 || !live) {
        live = false;
        return;
      }
      
      if (distRemaining < radius) {
        pos.add(new PVector(distRemaining, 0).rotate(angle));
        distance -= distRemaining;
        checkForBloon();
        break;
      }
      
      pos.add(new PVector(radius, 0).rotate(angle));
      distRemaining -= radius;
      distanceRemaining -= radius;
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
    for (ProjComponent comp : components) {
      comp.activate("HitBloon", b);
    }
  }
  
  void end() {
    live = false;
  }
  
  void checkForBloon() {
    if (!live) return;
    
    ArrayList<WeakHashMap<Bloon, Boolean>>[] tiles = getTilesInRange(pos.x, pos.y, radius);
    
    //Full Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[0]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        if (!b.live) continue;
        if (!live) return;
        dmg(b);
      }
    }
    
    //Partial Coverage
    for (WeakHashMap<Bloon, Boolean> map : tiles[1]) {
      Set<Bloon> bloonSet = map.keySet();
      for (Bloon b : bloonSet) {
        if (sq(pos.x - b.pos.x) + sq(pos.y - b.pos.y) < sq(radius + b.type.radius) && alreadyHit.get(b) == null && b.live && live) {
          dmg(b);
        }
      }
    }
  }
}
