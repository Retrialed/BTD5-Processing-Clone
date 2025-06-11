ProjType[] projTypes;

interface ComponentFactory {
  ProjComponent create(Object... args);
}

HashMap<String, ComponentFactory> projComponentRegistry = new HashMap<>() {{
  put("Piercing", args -> new Piercing(args));
  put("GivesSlow", args -> new GivesSlow(args));
  put("Sharp", args -> new Sharp());
  put("Universal", args -> new Universal());
  put("Crushing", args -> new Crushing());
  put("Homing", args -> new Homing());
  put("Explosive", args -> new Explosive(args));
  put("Fragmenting", args -> new Fragmenting(args));
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
    "star",
    "explosion",
    "bomb"
  };

  for (String str : projSpriteNames) {
    projSprites.put(str, loadImage("images/projs/" + str + ".png"));
  }

  projTypes = new ProjType[] {
    //img, damage, radius, speed, distance, components
    new ProjType(
      projSprites.get("basicDart"), 
      new int[]{1, 10, 20, 200}, Map.of(
        "Piercing", new Object[]{1},
        "Sharp", new Object[]{}
      )
    ), //0  
    
    new ProjType(
      projSprites.get("laserW"),
      new int[]{1, 8, 40, 500},
      Map.of(
        "Universal", new Object[]{}
      )
    ), //1

    new ProjType(
      projSprites.get("spikeBall"),
      new int[]{1, 14, 20, 800},
      Map.of(
        "Piercing", new Object[]{18},
        "Sharp", new Object[]{}
      )
    ), //2

    new ProjType(
      projSprites.get("fire"),
      new int[]{1, 15, 15, 150},
      Map.of(
        "Piercing", new Object[]{60},
        "Universal", new Object[]{}
      )
    ), //3

    new ProjType(
      projSprites.get("saw"),
      new int[]{1, 14, 15, 150},
      Map.of(
        "Sharp", new Object[]{},
        "Piercing", new Object[]{2}
      )
    ), //4

    new ProjType(
      projSprites.get("star"),
      new int[]{1, 10, 20, 250},
      Map.of(
        "Sharp", new Object[]{},
        "Piercing", new Object[]{2}
      )
    ), //5

    new ProjType(
      projSprites.get("bomb"),
      new int[]{1, 18, 20, 300},
      Map.of(
        "Explosive", new Object[]{250},
        "Piercing", new Object[]{1}
      )
    ), //6

    new ProjType(
      projSprites.get("bomb"),
      new int[]{1, 18, 20, 250},
      Map.of(
        "Explosive", new Object[]{150},
        "Piercing", new Object[]{1}
      )
    ), //7
    
    new ProjType(
      projSprites.get("basicDart"), 
      new int[]{1, 10, 20, 300}, Map.of(
        "Piercing", new Object[]{1},
        "Sharp", new Object[]{}
      )
      ), //8  
      
    new ProjType(
      projSprites.get("laserP"),
      new int[]{1, 8, 30, 300},
      Map.of(
        "Piercing", new Object[]{2},
        "Universal", new Object[]{}
      )
    ), //9
      
    new ProjType(
      projSprites.get("laserBL"),
      new int[]{1, 12, 30, 300},
      Map.of(
        "Piercing", new Object[]{2},
        "Universal", new Object[]{}
      )
    ), //10
      
    new ProjType(
      projSprites.get("laserR"),
      new int[]{1, 16, 40, 800},
      Map.of(
        "Universal", new Object[]{}
      )
    ), //11
    
    new ProjType(
      projSprites.get("basicDart"), 
      new int[]{1, 10, 2000, 2000}, Map.of(
        "Piercing", new Object[]{1},
        "Sharp", new Object[]{}
      )
    ), //12  
  };
}

Map<String, PImage> projSprites = new HashMap<>();

class ProjType {
  int damage, radius, speed, distance;
  PImage sprite;
  HashMap<String, Object[]> comps = new HashMap();

  ProjType(PImage sprite, int[] data, Map<String, Object[]> components) {
    damage = data[0];
    radius = data[1];
    speed = data[2];
    distance = data[3];
    this.sprite = sprite;
    comps = new HashMap<>(components);
  }

  ProjType(ProjType other) {
    damage = other.damage;
    radius = other.radius;
    speed = other.speed;
    distance = other.distance;
    sprite = other.sprite;
    comps = new HashMap<>(other.comps);
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
  boolean track = false;
}

class Explosive extends ProjComponent {
  int radius;

  Explosive(Object... args) {
    eventName = "Death";
    radius = (int) args[0];
    track = true;
  }

  void activate(Object... args) {
    PVector c = proj.pos;
    int dmg = proj.damage;
    
    image(projSprites.get("explosion"), c.x, c.y);

    for (Bloon b : bloonsInRange(getTilesInRange(c.x, c.y, radius), c, radius)) {
      if (!isBlack(b)) {
        proj.activateComponents("HitBloon", b);
        b.dmg(dmg);
      }
    }

  }
}

class Fragmenting extends ProjComponent {
  int typeID;
  
  void fire(ProjType type, float angle) {
    addProj(type, proj.pos.copy(), angle);
    track = true;
  }
  
  Fragmenting(Object... args) {
    eventName = "Death";
    typeID = (int) args[0];
  }
  void activate(Object... args) {
    float angle = 0;
    while (angle < radians(360)) {
      fire(projTypes[typeID], angle);
      angle += radians(45);
    }
  }
}

class Homing extends ProjComponent {
  Homing() {
    eventName = "Moving";
  }

  void activate(Object... args) {
    Bloon bloon = null;
        
    for (Bloon b : bloonsInRange(getTilesInRange(proj.pos.x, proj.pos.y, 150), proj.pos, 150)) {
      if (bloon == null || PVector.sub(proj.pos, b.pos).magSq() < PVector.sub(proj.pos, bloon.pos).magSq())
        bloon = b;
    }
    
    if (bloon != null) {
      float targetAngle = atan2(bloon.pos.y - proj.pos.y, bloon.pos.x - proj.pos.x);
      float angleDiff = targetAngle - proj.angle;
      float turnSpeed = .2;
      proj.angle += constrain(angleDiff, -turnSpeed, turnSpeed);
      proj.distanceRemaining += 10;
    }
  }
}

class GivesSlow extends ProjComponent {
  float mult, probability;
  int timer;
  boolean affectsMOAB;
  
  GivesSlow(Object... args) {
    eventName = "HitBloon";
    timer = (int) args[0];
    mult = (float) args[1];
    probability = (float) args[2];
    affectsMOAB = (boolean) args[3];
  }
  
  void activate(Object... args) {
    Bloon b = (Bloon) args[0];
    if (Math.random() < probability && (affectsMOAB == isMoab(b))) {
      
      b.addEffect(new SpeedMult(timer, mult));
    }
  }
}

class Piercing extends ProjComponent {
  int pierce;
  
  Piercing(Object... args) {
    eventName = "HitBloon";
    track = true;
    pierce = args.length > 0? (int) args[0] : 1;
  }

  void activate(Object... args) {

    pierce--;

    if (pierce == 0) {
      proj.end();
    }
  }
}

class Sharp extends ProjComponent {
  Sharp() {
    eventName = "Damage";
  }

  void activate(Object... args) {

    Bloon b = (Bloon) args[0];
    if (isLead(b)) {
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
    eventName = "Damage";
  }

  void activate(Object... args) {
    int damage = proj.damage;

    Bloon b = (Bloon) args[0];
    if (isCeramic(b))
      damage += 4;

    ArrayList<Bloon> hit = b.dmg(damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
  }
}

class Universal extends ProjComponent {
  Universal() {
    eventName = "Damage";
  }

  void activate(Object... args) {
    Bloon b = (Bloon) args[0];

    ArrayList<Bloon> hit = b.dmg(proj.damage);
    for (Bloon bloon : hit) {
      proj.alreadyHit.put(bloon, true);
    }
  }
}

boolean isMoab(Bloon b) {
  return 10 <= b.type.ID && b.type.ID <= 12;
}

boolean isCeramic(Bloon b) {
  int id = b.type.ID;
  return id == 9 || id == 22 || id == 33 || id == 43;
}

boolean isLead(Bloon b) {
  int id = b.type.ID;
  return id == 23 || id == 44 || id == 45 || id == 46;
}

boolean isBlack(Bloon b) {
  int id = b.type.ID;
  return id == 5 || id == 7 || id == 18 || id == 20 || id == 29 || id == 31 || id == 39 || id == 41;
}

boolean isIceImmune(Bloon b) {
  int id = b.type.ID;
  return id == 6 || id == 7 || id == 19 || id == 20 || id == 30 || id == 31 || id == 40 || id == 41;
}
