ProjType[] projTypes;

HashMap<String, Supplier<ProjComponent>> projComponentRegistry = new HashMap<>() {{
  put("Piercing", Piercing::new);
  put("Sharp", Sharp::new);
  put("Universal", Universal::new);
  put("Crushing", Crushing::new);
  put("Homing", Homing::new);
}};

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
    "fire",
    "saw",
    "star"
  };

  for (String str : projSpriteNames) {
    projSprites.put(str, loadImage("images/projs/" + str + ".png"));
  }

  projTypes = new ProjType[] {
    //img,                                        damage, radius, speed, distance, components
    new ProjType(projSprites.get("basicDart"), new int[]{1, 10, 20, 200}, new String[]{"Piercing", "Sharp"}), //0
    new ProjType(projSprites.get("laserW"), new int[]{1, 8, 40, 500}, new String[]{"Universal"}), //1
    new ProjType(projSprites.get("spikeBall"), new int[]{1, 14, 20, 800}, new String[]{"Piercing", "Sharp"}), //2
    new ProjType(projSprites.get("fire"), new int[]{1, 15, 15, 150}, new String[]{"Piercing", "Universal"}), //3
    new ProjType(projSprites.get("saw"), new int[]{1, 14, 15, 150}, new String[]{"Piercing", "Sharp"}), //4
    new ProjType(projSprites.get("star"), new int[]{1, 10, 20, 250}, new String[]{"Piercing", "Sharp"}), //5
  };

  projTypes[0].extra.put("pierce", (float) 1);
  projTypes[2].extra.put("pierce", (float) 18);
  projTypes[3].extra.put("pierce", (float) 60);
  projTypes[4].extra.put("pierce", (float) 2);
  projTypes[5].extra.put("pierce", (float) 2);
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

abstract class Attack {
  int delay, cooldown;
  ProjType projectile;

  Attack(int delay, int projID) {
    this.delay = delay;
    projectile = projTypes[projID];
  }

  Attack(Attack other) {
    delay = other.delay;
    projectile = other.projectile;
  }

  abstract Attack copy();

  boolean cooldown() {
    if (cooldown > 0) {
      cooldown--;
      return false;
    }

    return true;
  }

  void fire(Monkey m, ProjType type) {
    Proj p = addProj(type, m.pos.copy(), m.angle);
    for (Consumer<Proj> upgrade : m.projUpgrades) {
      upgrade.accept(p);
    }
  }

  void activate(Monkey m) {
    if (cooldown > 0) return;

    cooldown = delay;
    attack(m);
  };

  abstract void attack(Monkey m);
}

class Shot extends Attack {
  Shot(int delay, int projID) {
    super(delay, projID);
  }

  Shot(Shot other) {
    super(other);
  }

  Shot copy() {
    return new Shot(this);
  }

  void attack(Monkey m) {
    fire(m, projectile);
  }
}

class MultiShot extends Shot {
  float spread;
  int count;
  
  MultiShot(int delay, int projID, int count, float spread) {
    super(delay, projID);
    this.count = count;
    this.spread = radians(spread);
  }

  MultiShot(MultiShot other) {
    super(other);
    this.spread = other.spread;
    this.count = other.count;
  }

  MultiShot copy() {
    return new MultiShot(this);
  }

  void attack(Monkey m) {
    for (int i = 0; i < count; i++) {
      float angle = (count == 1)
          ? m.angle
          : m.angle - spread / 2 + spread * ((float) i / (count - 1));
      fire(m, projectile, angle);
    }
  }

  void fire(Monkey m, ProjType type, float angle) {
    Proj p = addProj(type, m.pos.copy(), angle);
    for (Consumer<Proj> upgrade : m.projUpgrades) {
      upgrade.accept(p);
    }
  }
}



abstract class ProjComponent extends Component {
  Proj proj;
}

class Homing extends ProjComponent {
  Homing() {
    eventName = "Moving";
  }

  void activate(Object... args) {
    Bloon bloon = null;
        
    for (Bloon b : bloonsInRange(getTilesInRange(proj.pos.x, proj.pos.y, 200), proj.pos, 200)) {
      if (bloon == null || PVector.sub(proj.pos, b.pos).magSq() < PVector.sub(proj.pos, bloon.pos).magSq())
        bloon = b;
    }
    
    if (bloon != null) {
      float targetAngle = atan2(bloon.pos.y - proj.pos.y, bloon.pos.x - proj.pos.x);
      float angleDiff = targetAngle - proj.angle;
      float turnSpeed = .2;
      proj.angle += constrain(angleDiff, -turnSpeed, turnSpeed);
    }
  }
}

class Piercing extends ProjComponent {
  Piercing() {
    eventName = "HitBloon";
  }

  void activate(Object... args) {

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

  void activate(Object... args) {

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

  void activate(Object... args) {
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

  void activate(Object... args) {
    Bloon b = (Bloon) args[0];

    ArrayList<Bloon> hit = b.dmg(proj.damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
  }
}
