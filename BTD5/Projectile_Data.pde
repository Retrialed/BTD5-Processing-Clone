ProjType[] projTypes;
void setupProjTypes() {
  String[] projSpriteNames = new String[] {
    "basicDart",
    "spikeBall",
    "laserBL",
    "laserB",
    "laserG",
    "laserP",
    "laserR",
    "laserW",
  };
  
  for (String str : projSpriteNames) {
    projSprites.put(str, loadImage("images/projs/" + str + ".png"));
  }
  
  projTypes = new ProjType[] {
    //img,                                        damage, radius, speed, distance, components
    new ProjType(projSprites.get("basicDart"), new int[]{1, 10, 20, 200}, new String[]{"Piercing", "Sharp"}),
    new ProjType(projSprites.get("laserW"), new int[]{1, 8, 40, 500}, new String[]{"Universal"}),
    new ProjType(projSprites.get("spikeBall"), new int[]{1, 14, 20, 800}, new String[]{"Piercing", "Sharp"}),
  };
  
  projTypes[0].extra.put("pierce", (float) 1);
  projTypes[2].extra.put("pierce", (float) 18);
}

Map<String, PImage> projSprites = new HashMap<>();

class ProjType {
  int damage, radius, speed, distance;
  HashMap<String, Float> extra = new HashMap();
  PImage sprite;
  HashSet<String> comps = new HashSet();

  ProjType(PImage sprite, int[] data, String[] components) {
    damage = data[0];
    radius = data[1];
    speed = data[2];
    distance = data[3];
    this.sprite = sprite;
    for (String s : components)
      comps.add(s);
  }
  
  ProjType(ProjType other) {
    damage = other.damage;
    radius = other.radius;
    speed = other.speed;
    distance = other.distance;
    sprite = other.sprite;
    extra.putAll(other.extra);
    comps = (HashSet<String>) other.comps.clone();
  }
}

abstract class ProjComponent {
  Proj proj;
  String eventName;
  
  boolean shouldActivate(String event) {
    return eventName.equals(event);
  }
  
  abstract void activate(String event, Object... args);
}

class Piercing extends ProjComponent {
  Piercing() {
    eventName = "HitBloon";
  }
  
  void activate(String event, Object... args) {
    if (!shouldActivate(event)) return;
    
    proj.extra.put("pierce", proj.extra.get("pierce") - 1);
    
    if (proj.extra.get("pierce") <= 0) {
      proj.end();
    }
  }
}

class Sharp extends ProjComponent {
  Sharp() {
    eventName = "HitBloon";
  }
  
  void activate(String event, Object... args) {
    if (!shouldActivate(event)) return;
    
    Bloon b = (Bloon) args[0];
    if (b.type.ID == 23 || b.type.ID >= 44) {
      proj.end();
      return;
    }
    
    ArrayList<Bloon> hit = b.dmg(proj.damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
  }
}

class Crushing extends ProjComponent {
  Crushing() {
    eventName = "HitBloon";
  }
  
  void activate(String event, Object... args) {
    if (!shouldActivate(event)) return;
    
    int damage = proj.damage;
    
    Bloon b = (Bloon) args[0];
    if (b.type.ID == 9 || b.type.ID == 22 || b.type.ID == 33 || b.type.ID == 43) 
      damage += 4;
      
    ArrayList<Bloon> hit = b.dmg(damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
  }
}

class Universal extends ProjComponent {
  Universal() {
    eventName = "HitBloon";
  }
  
  void activate(String event, Object... args) {
    if (!shouldActivate(event)) return;
    
    Bloon b = (Bloon) args[0];
    
    ArrayList<Bloon> hit = b.dmg(proj.damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
  }
}
