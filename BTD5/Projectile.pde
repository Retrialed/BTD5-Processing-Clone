ArrayList<Proj> projs = new ArrayList<Proj>();

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
  HashMap<String, ArrayList<ProjComponent>> components = (HashMap<String, ArrayList<ProjComponent>>) new HashMap();
  
  Proj(ProjType type, PVector position, float spawnAngle) {
    super(type);
    distanceRemaining = distance;
    pos = position;
    angle = spawnAngle;
    try {
      for (String className : comps) {
        Supplier<ProjComponent> factory = projComponentRegistry.get(className);
        if (factory != null) addComponent(factory.get());
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  void addComponent(ProjComponent comp) {
    comp.proj = this;
    components.computeIfAbsent(comp.eventName, k -> new ArrayList<ProjComponent>()).add(comp);
  }
  
  void activateComponents(String eventName, Object... args) {
    ArrayList<ProjComponent> comps = components.get(eventName);
    if (comps != null)
      for (ProjComponent comp : comps)
        comp.activate(args);
  }
  
  void move() {
    activateComponents("Moving");
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
    activateComponents("HitBloon", b);
  }
  
  void end() {
    live = false;
  }
  
  void checkForBloon() {
    for (Bloon b : bloonsInRange(getTilesInRange(pos.x, pos.y, radius), pos, radius)) {
      if (!live) break;
      dmg(b);
    }
  }
}
