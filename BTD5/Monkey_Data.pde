MonkeyType[] MonkeyTypes;
void setupMonkeyTypes() {
  MonkeyTypes = new MonkeyType[] {
    //id, name, attackname, stats{range, delay, size, cost}
    new MonkeyType(0, "Dart Monkey", new int[]{160, 20, 200}, false),
    new MonkeyType(1, "Ray Gun", new int[]{400, 30, 0}, false),
  };
  
  MonkeyTypes[0].attack = new Shot(54, new int[]{0});
  MonkeyTypes[1].attack = new Shot(1, new int[]{1});
  
  MonkeyTypes[0].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(90, "Longer Range: Makes the dart monkey shoot further than normal.", (m) -> {
        m.range += 40;
        m.refreshTiles();
        m.addProjUpgrade((p) -> {p.distanceRemaining += 40;});
      }), 
      new Upgrade(120, "Enhanced Eyesight: Further increases attack range and allows Dart Monkey to see Camo Bloons.", (m) -> {
        m.range += 40;
        m.refreshTiles();
        m.camoVision = true;
        m.addProjUpgrade((p) -> {p.distanceRemaining += 40;});
      }),
      new Upgrade(500, "Spike-O-Pult: Converts the Dart Monkey into a Spike-O-Pult, a powerful tower that hurls a large spiked ball instead of darts. Good range, but slower attack speed. Each ball can pop 18 bloons.", (m) -> {
        m.attack = new Shot(92, new int[]{2});
      }), 
      new Upgrade(500, "Juggernaut: Hurls a giant unstoppable killer spiked ball that can pop lead bloons and excels at crushing ceramic bloons.", (m) -> {
        m.attack.delay = 84;
        m.range += 40;
        m.refreshTiles();
        m.attack.projectiles[0].comps.remove("Sharp");
        m.attack.projectiles[0].comps.add("Crushing");
        m.addProjUpgrade((p) -> {p.radius += 10;});
        m.addProjUpgrade((p) -> {p.extra.put("pierce", p.extra.get("pierce") + 82);});
      }), 
      
    },
    {
      new Upgrade(140, "Sharp Shots: +1 pierce", (m) -> {
        m.addProjUpgrade((p) -> {p.extra.put("pierce", p.extra.get("pierce") + 1);});
      }), 
      new Upgrade(170, "Razor Sharp Shots: +2 pierce", (m) -> {
        m.addProjUpgrade((p) -> {p.extra.put("pierce", p.extra.get("pierce") + 2);});
      }), 
      new Upgrade(330, "Triple Darts: Throws 3 darts at a time instead of 1.", (m) -> {
        m.attack = new MultiShot(54, new int[]{0, 0, 0}, 25);
      }), 
      new Upgrade(600, "Faster Throwing: Doubles throwing speed", (m) -> {
        m.attack.delay = 27;
      }), 
    }
  };
  
  MonkeyTypes[1].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(0, "Double attack speed", (m) -> {
        m.attack.delay = 0;
      }), 
      new Upgrade(0, "Double attack damage", (m) -> {
        m.addProjUpgrade((p) -> {p.damage *= 2;});
      }), 
      new Upgrade(0, "Double Projectiles", (m) -> {
        m.attack = new MultiShot(0, new int[]{1, 1}, 10);
      }), 
      new Upgrade(0, "Quintuple Projectiles", (m) -> {
        m.attack = new MultiShot(0, new int[]{1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, 10);
      }), 
    },
    {
      new Upgrade(0, "Add Camo Vision", (m) -> {
        m.camoVision = true;
      }), 
      new Upgrade(0, "Double projectile speed", (m) -> {
        m.addProjUpgrade((p) -> {p.speed *= 2;});
      }), 
      new Upgrade(0, "Spray Projectiles", (m) -> {
        m.attack = new MultiShot(0, new int[]{1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, 360);
      }), 
      new Upgrade(0, "Spray More Projectiles", (m) -> {
        m.attack = new MultiShot(0, new int[]{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, 360);
      }), 
    }
  };
}

class MonkeyType {
  int ID;
  String name, atkName;
  ArrayList<Attack> attacks;
  PImage sprite;
  boolean camoVision;
  Upgrade[][] upgradeTree;
  
  int range, size, cost;
  Attack attack;
  
  
  MonkeyType(int typeID, String mName, int[] statArr, boolean camoVision) {
    ID = typeID;
    name = mName;
    range = statArr[0];
    size = statArr[1];
    cost = statArr[2];
    this.camoVision = camoVision;

    sprite = loadImage("images/monkeys/" + name + ".png");
  }
  
  MonkeyType(MonkeyType other) {
    ID = other.ID;
    name = other.name;
    sprite = other.sprite;
    range = other.range;
    size = other.size;
    cost = other.cost;
    attack = other.attack.copy();
    upgradeTree = other.upgradeTree;
    camoVision = other.camoVision;
  }
}

abstract class Attack {
  int delay, cooldown;
  ProjType[] projectiles;
  
  Attack(int delay, int[] projIDs) {
    this.delay = delay;
    projectiles = new ProjType[projIDs.length];
    for (int i = 0; i < projIDs.length; i++) {
      projectiles[i] = projTypes[projIDs[i]];
    }
  }
  
  Attack(Attack other) {
    delay = other.delay;
    projectiles = new ProjType[other.projectiles.length];
    for (int i = 0; i < other.projectiles.length; i++) {
      projectiles[i] = other.projectiles[i];
    }
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
  Shot(int delay, int[] projIDs) {
    super(delay, projIDs);
  }
  
  Shot(Shot other) {
    super(other);
  }
  
  Shot copy() {
    return new Shot(this);
  }
  
  void attack(Monkey m) {
    for (ProjType p : projectiles) {
      fire(m, p);
    }
  }
}

class MultiShot extends Shot {
  float spread;
  MultiShot(int delay, int[] projIDs, float spread) {
    super(delay, projIDs);
    this.spread = radians(spread);
  }
  
  MultiShot(MultiShot other) {
    super(other);
    this.spread = other.spread;
  }
  
  MultiShot copy() {
    return new MultiShot(this);
  }
  
  void attack(Monkey m) {
    for (int i = 0; i < projectiles.length; i++) {
      float j = (projectiles.length == 1) ? 0 : (float) i / (projectiles.length - 1);
      float angle = m.angle - spread / 2 + spread * j;
      fire(m, projectiles[i], angle);
    }
  }
  
  void fire(Monkey m, ProjType type, float angle) {
    Proj p = addProj(type, m.pos.copy(), angle);
    for (Consumer<Proj> upgrade : m.projUpgrades) {
      upgrade.accept(p);
    }
  }
}

class Upgrade {
  String desc;
  int cost;
  Consumer<Monkey> action;
  
  Upgrade(int cost, String desc, Consumer<Monkey> action) {
    this.desc = desc;
    this.cost = cost;
    this.action = action;
  }
  
  void apply(Monkey m) {
    m.cost += cost;
    action.accept(m);
  }
}
