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
    new MonkeyType(3, "Ninja Monkey", new int[]{250, 20, 500}, true, new String[]{"Rotating"}),
    new MonkeyType(4, "Bomb Tower", new int[]{200, 30, 650}, false, new String[]{"Rotating"}),
    new MonkeyType(5, "Super Monkey", new int[]{250, 40, 3000}, false, new String[]{"Rotating"}),
    new MonkeyType(6, "Sniper Monkey", new int[]{2500, 25, 350}, false, new String[]{"Rotating"}),
  };

  MonkeyTypes[0].attacks.add(new Shot(54, 0));
  MonkeyTypes[1].attacks.add(new Shot(1, 1));
  MonkeyTypes[2].attacks.add(new MultiShot(100, 0, 8, 315));
  MonkeyTypes[3].attacks.add(new Shot(36, 5));
  MonkeyTypes[4].attacks.add(new Shot(38, 7));
  MonkeyTypes[5].attacks.add(new Shot(3, 8));
  MonkeyTypes[6].attacks.add(new Shot(132, 12));
  
  MonkeyTypes[6].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(350, "Full Metal Jacket: Shots can pop through 4 layers of bloon - and can pop lead bloons.", (m) -> {
        m.attacks.get(0).projectile.comps.remove("Sharp");
        m.attacks.get(0).projectile.comps.put("Universal", new Object[]{});
        m.attacks.get(0).projectile.damage = 4;
      }),
      new Upgrade(2200, "Point Five Oh: Shots can pop through 7 layers of bloon!", (m) -> {
        m.attacks.get(0).projectile.damage = 7;
      }),
      new Upgrade(4000, "Extreme accuracy and muzzle velocity cause up to 18 layers of bloon to be popped per shot - enough to destroy an entire Ceramic Bloon!", (m) -> {
        m.attacks.get(0).projectile.damage = 18;
      }),
      new Upgrade(10000, "Bullets from this tower temporarily take out the engines of MOAB class bloons, disabling them for a short period of time.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("GivesSlow", new Object[]{60, 0f, 1f, true});
        });
      }),
    },
    {
      new Upgrade(400, "Allows Sniper to shoot faster.", (m) -> {
        m.attacks.get(0).delay *= .6;
      }),
      new Upgrade(300, "Allows Sniper to shoot camo bloons.", (m) -> {
        m.camoVision = true;
      }),
      new Upgrade(3500, "Semi-Automic Rifle: Allows Sniper to take multiple shots and attack 3x as fast.", (m) -> {
        m.attacks.get(0).delay = 30;
      }),
      new Upgrade(5000, "Insurance: Firing gives extra money.", (m) -> {
        m.addProjUpgrade((p) -> {
          money += 5;
        });
      }),
    
    }
  };
  
  MonkeyTypes[5].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(3500, "Shoots super-powerful lasers instead of throwing darts.", (m) -> {
        m.attacks.remove(0);
        m.attacks.add(new MultiShot(3, 9, 2, 5));
      }),
      new Upgrade(4000, "Plasma vaporizes everything it touches!", (m) -> {
        m.attacks.remove(0);
        m.attacks.add(new MultiShot(3, 10, 3, 6));
      }),
      new Upgrade(10000, "Sun God", (m) -> {
        m.attacks.remove(0);
        m.range *= 1.5;
        m.refreshTiles();
        m.attacks.add(new MultiShot(3, 11, 3, 6));
      }),
      new Upgrade(12000, "Beam", (m) -> {
        m.attacks.remove(0);
        m.range *= 1.5;
        m.refreshTiles();
        m.attacks.add(new MultiShot(3, 11, 8, 10));
      }),
    },
    
    {
      new Upgrade(1000, "Super range! Super Monkey can now attack camo bloons.", (m) -> {
        m.camoVision = true;
        m.range *= 1.25;
        m.refreshTiles();
      }),
      new Upgrade(1500, "Epic Range!", (m) -> {
        m.range *= 1.15;
        m.refreshTiles();
      }),
      new Upgrade(9000, "Projectiles are now explosive", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("Explosive", new Object[]{200});
          Piercing pierce = (Piercing) p.componentMap.get("Piercing");
          pierce.pierce = 1;
        });
      }),
      new Upgrade(20000, "Bombs away", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("Fragmenting", new Object[]{7});
        });
      }),
    }
  };
  
  MonkeyTypes[4].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(200, "Extra Range.", (m) -> {
        m.range *= 1.2;
        m.refreshTiles();
      }),
      new Upgrade(300, "Each explosion throws out 8 sharp fragments that pop even more bloons.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("Fragmenting", new Object[]{0});
        });
      }),
      new Upgrade(800, "Throws out secondary bombs instead of frags- causing widespread explosive poppage.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("Fragmenting", new Object[]{7});
        });
      }),
      new Upgrade(4000, "Impacts from this tower become so violent, bloons become stunned for a short time when they are hit.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("GivesSlow", new Object[]{30, 0f, 1f, false});
        });
      }),
    
    },
    {
      new Upgrade(400, "Bombs hit a larger area.", (m) -> {
        m.addProjUpgrade((p) -> {
          Explosive explosive = (Explosive) p.componentMap.get("Explosive");
          explosive.radius *= 1.5;
        });
      }),
      new Upgrade(400, "Bombs fly faster and further, popping more bloons and have higher velocity.", (m) -> {
        m.range *= 1.2;
        Attack atk = m.attacks.get(0);
        atk.delay *= 0.75;
        atk.projectile.speed *= 1.25;
        atk.projectile.damage = 3;
      }),
      new Upgrade(1250, "Air Defense: Bombs can now slow blimps.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("GivesSlow", new Object[]{30, .5f, .25f, true});
        });
      }),
      new Upgrade(2500, "Assassin: Bombs can now blow back blimpss.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("GivesSlow", new Object[]{30, -1f, .25f, true});
        });
      }),
    
    }
  };
  
  MonkeyTypes[3].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(300, "Ninja Discipline: Increases attack range and attack speed.", (m) -> {
        m.attacks.get(0).delay *= .75;
        m.range *= 1.15;
        m.refreshTiles();
      }),
      new Upgrade(350, "Shurikens can pop 4 bloons each.", (m) -> {
        m.attacks.get(0).projectile.comps.put("Piercing", new Object[]{4});
      }),
      new Upgrade(850, "Double Shot: Extreme Ninja skill enables him to throw 2 shurikens at once.", (m) -> {
        m.attacks.add(new MultiShot(m.attacks.get(0).delay, 5, 2, 15));
        m.attacks.remove(0);
      }),
      new Upgrade(2750, "Bloonjitsu: The art of bloonjitsu allows Ninjas to throw 5 deadly shurikens at once!", (m) -> {
        m.attacks.add(new MultiShot(m.attacks.get(0).delay, 5, 5, 40));
        m.attacks.remove(0);
      }),
    },
    {
      new Upgrade(250, "Seeking Shuriken: Infuses bloon hatred into the weapons themselves - they will seek out and pop bloons automatically.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("Homing");
        });
      }),
      new Upgrade(350, "Distraction: Some bloons struck by the Ninja's weapons will become distracted and move the wrong way temporarily.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("GivesSlow", new Object[]{20, -1f, .3f, false});
        });
      }),
      new Upgrade(2000, "Distraction: Some bloons struck by the Ninja's weapons will become distracted and move the wrong way temporarily.", (m) -> {
        Attack newAttack = new Shot(240, 6);
        newAttack.projectile.comps.put("GivesSlow", new Object[]{120, 0f, 1f, false});
        m.attacks.add(newAttack);
      }),
      new Upgrade(2750, "Saboteur: Distraction now works on blimps.", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("GivesSlow", new Object[]{20, -1f, .3f, true});
        });
      }),
    }
  };
  
  MonkeyTypes[2].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(210, "Shoots tacks faster.", (m) -> {
        m.attacks.get(0).delay *= .666;
      }),
      new Upgrade(300, "Shoots tacks even faster.", (m) -> {
        m.attacks.get(0).delay *= .555;
      }),
      new Upgrade(500, "Sprays out 16 tacks per volley instead of the usual 8.", (m) -> {
        m.attacks.add(new MultiShot(m.attacks.get(0).delay, 0, 16, 337.5));
        m.attacks.remove(0);
      }),
      new Upgrade(2500, "Shoots a deadly ring of flame instead of tacks.", (m) -> {
        m.attacks.add(new MultiShot((int) (m.attacks.get(0).delay * .666), 3, 16, 337.5));
        m.attacks.remove(0);
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
        m.attacks.get(0).delay *= 0.9;
        m.attacks.add(new MultiShot(m.attacks.get(0).delay, 4, 16, 337.5));
        m.attacks.remove(0);
      }),
      new Upgrade(1200, "The razor blades become homing", (m) -> {
        m.attacks.get(0).projectile.comps.put("Homing", new Object[]{});
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
        m.attacks.remove(0);
        m.attacks.add(new Shot(92, 2));
      }),
      new Upgrade(1500, "Juggernaut: Hurls a giant unstoppable killer spiked ball that can pop lead bloons and excels at crushing ceramic bloons.", (m) -> {
        m.attacks.get(0).delay = 84;
        m.range += 40;
        m.refreshTiles();
        m.attacks.get(0).projectile.comps.remove("Sharp");
        m.attacks.get(0).projectile.comps.put("Crushing", new Object[]{});
        m.addProjUpgrade((p) -> {
          p.radius += 10;
        });
        m.addProjUpgrade((p) -> {
          Piercing pierce = (Piercing) p.componentMap.get("Piercing");
          pierce.pierce += 88;
        });
      })
    },
    {
      new Upgrade(140, "Sharp Shots: +1 pierce", (m) -> {
        m.addProjUpgrade((p) -> {
          Piercing pierce = (Piercing) p.componentMap.get("Piercing");
          pierce.pierce += 1;
        });
      }),
      new Upgrade(170, "Razor Sharp Shots: +2 pierce", (m) -> {
        m.addProjUpgrade((p) -> {
          Piercing pierce = (Piercing) p.componentMap.get("Piercing");
          pierce.pierce += 2;
        });
      }),
      new Upgrade(330, "Triple Darts: Throws 3 darts at a time instead of 1.", (m) -> {
        m.attacks.remove(0);
        m.attacks.add(new MultiShot(54, 0, 3, 25));
      }),
      new Upgrade(600, "Faster Throwing: Doubles throwing speed", (m) -> {
        m.attacks.get(0).delay = 27;
      })
    }
  };

  MonkeyTypes[1].upgradeTree = new Upgrade[][] {
    {
      new Upgrade(0, "Double attack speed", (m) -> {
        m.attacks.get(0).delay = 0;
      }),
      new Upgrade(0, "Double attack damage", (m) -> {
        m.addProjUpgrade((p) -> {
          p.damage *= 2;
        });
      }),
      new Upgrade(0, "Double Projectiles", (m) -> {
        m.attacks.remove(0);
        m.attacks.add(new MultiShot(0, 1, 2, 10));
      }),
      new Upgrade(0, "Quintuple Projectiles", (m) -> {
        m.attacks.remove(0);
        m.attacks.add(new MultiShot(0, 1, 10, 10));
      })
    },
    {
      new Upgrade(0, "Add Camo Vision", (m) -> {
        m.camoVision = true;
      }),
      new Upgrade(0, "Add Homing", (m) -> {
        m.addProjUpgrade((p) -> {
          p.addComponent("Homing");
        });
      }),
      new Upgrade(0, "Spray Projectiles", (m) -> {
        m.attacks.remove(0);
        m.attacks.add(new MultiShot(0, 1, 9, 360));
      }),
      new Upgrade(0, "Spray More Projectiles", (m) -> {
        m.attacks.remove(0);
        m.attacks.add(new MultiShot(0, 1, 100, 360));
      })
    }
  };
}

class MonkeyType {
  int ID;
  String name, atkName;
  ArrayList<Attack> attacks = new ArrayList();
  PImage sprite;
  boolean camoVision;
  Upgrade[][] upgradeTree;
  HashSet<String> comps = new HashSet();

  int range, size, cost;


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
    attacks = new ArrayList<Attack>();
    for (Attack a : other.attacks)
      attacks.add(a.copy());
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
