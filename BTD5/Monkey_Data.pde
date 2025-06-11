MonkeyType[] MonkeyTypes;

HashMap<String, Supplier<MonkeyComponent>> monkeyComponentRegistry = new HashMap<>() {
  {
    put("Rotating", Rotating::new);
  }
};

abstract class MonkeyComponent extends Component {
  Monkey monkey;
}

class Rotating extends MonkeyComponent {
  Rotating() {
    eventName = "Targeting";
  }

  void activate(Object... args) {

    Bloon b = (Bloon) args[0];
    monkey.angle = atan2(b.pos.y - monkey.pos.y, b.pos.x - monkey.pos.x);
  }
}

void setupMonkeyTypes() {
  MonkeyTypes = new MonkeyType[] {
    // id, name, attackname, stats{range, size, cost}
    new MonkeyType(0, "Dart Monkey", new int[]{160, 20, 200}, false, new String[]{"Rotating"}),
    new MonkeyType(1, "Ray Gun", new int[]{400, 30, 0}, false, new String[]{"Rotating"}),
    new MonkeyType(2, "Tack Shooter", new int[]{120, 30, 360}, false, new String[]{}),
    new MonkeyType(3, "Ninja Monkey", new int[]{250, 20, 500}, false, new String[]{"Rotating"}),
  };

  MonkeyTypes[0].attack = new Shot(54, 0);
  MonkeyTypes[1].attack = new Shot(1, 1);
  MonkeyTypes[2].attack = new MultiShot(100, 0, 8, 315);
  MonkeyTypes[3].attack = new Shot(36, 5);
  
  MonkeyTypes[3].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(300, "Ninja Discipline: Increases attack range and attack speed.", (m) -> {
        m.attack.delay *= .75;
        m.range *= 1.15;
      }),
      new Upgrade(350, "Shurikens can pop 4 bloons each.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.extra.put("pierce", 4.0);
        });
      }),
      new Upgrade(850, "Double Shot: Extreme Ninja skill enables him to throw 2 shurikens at once.", (m) -> {
        boolean e = false;
        if (m.attack.projectile.comps.contains("Homing"))
          e = true;
        m.attack = new MultiShot(m.attack.delay, 5, 2, 15);
        if (e)
          m.attack.projectile.comps.add("Homing");
      }),
      new Upgrade(2750, "Bloonjitsu: The art of bloonjitsu allows Ninjas to throw 5 deadly shurikens at once!", (m) -> {
        boolean e = false;
        if (m.attack.projectile.comps.contains("Homing"))
          e = true;
        m.attack = new MultiShot(m.attack.delay, 5, 5, 40);
        if (e)
          m.attack.projectile.comps.add("Homing");
      }),
    },
    {
      new Upgrade(250, "Seeking Shuriken: Infuses bloon hatred into the weapons themselves - they will seek out and pop bloons automatically.", (m) -> {
        m.attack.projectile.comps.add("Homing");
        m.addProjUpgrade((p) -> {
          p.distanceRemaining += 250;
        });
      }),
    }
  };
  
  MonkeyTypes[2].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(210, "Shoots tacks faster.", (m) -> {
        m.attack.delay *= .666;
      }),
      new Upgrade(300, "Shoots tacks even faster.", (m) -> {
        m.attack.delay *= .555;
      }),
      new Upgrade(500, "Sprays out 16 tacks per volley instead of the usual 8.", (m) -> {
        m.attack = new MultiShot(m.attack.delay, 0, 16, 337.5);
      }),
      new Upgrade(2500, "Shoots a deadly ring of flame instead of tacks.", (m) -> {
        m.attack = new MultiShot((int) (m.attack.delay * .666), 3, 16, 337.5);
      }),
    },
    {
      new Upgrade(100, "Longer Range", (m) -> {
        m.range += 40;
        m.refreshTiles();
        m.addProjUpgrade((p) -> {
          p.distanceRemaining += 40;
        });
      }),
      new Upgrade(225, "Even Longer Range", (m) -> {
        m.range += 40;
        m.refreshTiles();
        m.addProjUpgrade((p) -> {
          p.distanceRemaining += 40;
        });
      }),
      new Upgrade(680, "Converts the tower into a blade shooter that shoots out razor sharp blades that are harder for bloons to avoid.", (m) -> {
        m.attack.delay *= 0.9;
        m.attack = new MultiShot(m.attack.delay, 4, 16, 337.5);
      }),
      new Upgrade(1500, "The razor blades become homing", (m) -> {
        m.addProjUpgrade((p) -> {
          p.distanceRemaining += 200;
        });
        m.attack.projectile.comps.add("Homing");
      }),
    }
  };

  MonkeyTypes[0].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(90, "Longer Range: Makes the dart monkey shoot further than normal.", (m) -> {
        m.range += 40;
        m.refreshTiles();
        m.addProjUpgrade((p) -> {
          p.distanceRemaining += 40;
        });
      }),
      new Upgrade(120, "Enhanced Eyesight: Further increases attack range and allows Dart Monkey to see Camo Bloons.", (m) -> {
        m.range += 40;
        m.refreshTiles();
        m.camoVision = true;
        m.addProjUpgrade((p) -> {
          p.distanceRemaining += 40;
        });
      }),
      new Upgrade(500, "Spike-O-Pult: Converts the Dart Monkey into a Spike-O-Pult, a powerful tower that hurls a large spiked ball instead of darts. Good range, but slower attack speed. Each ball can pop 18 bloons.", (m) -> {
        m.attack = new Shot(92, 2);
      }),
      new Upgrade(500, "Juggernaut: Hurls a giant unstoppable killer spiked ball that can pop lead bloons and excels at crushing ceramic bloons.", (m) -> {
        m.attack.delay = 84;
        m.range += 40;
        m.refreshTiles();
        m.attack.projectile.comps.remove("Sharp");
        m.attack.projectile.comps.add("Crushing");
        m.addProjUpgrade((p) -> {
          p.radius += 10;
        });
        m.addProjUpgrade((p) -> {
          p.extra.put("pierce", p.extra.get("pierce") + 82);
        });
      })
    },
    {
      new Upgrade(140, "Sharp Shots: +1 pierce", (m) -> {
        m.addProjUpgrade((p) -> {
          p.extra.put("pierce", p.extra.get("pierce") + 1);
        });
      }),
      new Upgrade(170, "Razor Sharp Shots: +2 pierce", (m) -> {
        m.addProjUpgrade((p) -> {
          p.extra.put("pierce", p.extra.get("pierce") + 2);
        });
      }),
      new Upgrade(330, "Triple Darts: Throws 3 darts at a time instead of 1.", (m) -> {
        m.attack = new MultiShot(54, 0, 3, 25);
      }),
      new Upgrade(600, "Faster Throwing: Doubles throwing speed", (m) -> {
        m.attack.delay = 27;
      })
    }
  };

  MonkeyTypes[1].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(0, "Double attack speed", (m) -> {
        m.attack.delay = 0;
      }),
      new Upgrade(0, "Double attack damage", (m) -> {
        m.addProjUpgrade((p) -> {
          p.damage *= 2;
        });
      }),
      new Upgrade(0, "Double Projectiles", (m) -> {
        m.attack = new MultiShot(0, 1, 2, 10);
      }),
      new Upgrade(0, "Quintuple Projectiles", (m) -> {
        m.attack = new MultiShot(0, 1, 10, 10);
      })
    },
    {
      new Upgrade(0, "Add Camo Vision", (m) -> {
        m.camoVision = true;
      }),
      new Upgrade(0, "Double projectile speed", (m) -> {
        m.addProjUpgrade((p) -> {
          p.speed *= 2;
        });
      }),
      new Upgrade(0, "Spray Projectiles", (m) -> {
        m.attack = new MultiShot(0, 1, 9, 360);
      }),
      new Upgrade(0, "Spray More Projectiles", (m) -> {
        m.attack = new MultiShot(0, 1, 100, 360);
      })
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
  HashSet<String> comps = new HashSet();

  int range, size, cost;
  Attack attack;


  MonkeyType(int typeID, String mName, int[] statArr, boolean camoVision, String[] components) {
    ID = typeID;
    name = mName;
    range = statArr[0];
    size = statArr[1];
    cost = statArr[2];
    this.camoVision = camoVision;
    for (String s : components)
      comps.add(s);

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
    comps = (HashSet<String>) other.comps.clone();
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
