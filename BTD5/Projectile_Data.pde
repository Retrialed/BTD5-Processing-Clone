ProjType[] ProjTypes;
void setupProjTypes() {
  ProjTypes = new ProjType[] {
    //dmgType, damage, radius, speed, lifespan, extra
    new ProjType(new int[]{0, 1, 10, 10, 25, 1}),
    new ProjType(new int[]{1, 1, 20, 32, 30, 10}),
  };
  
  String[] projSpriteNames = new String[] {
    "basicDart",
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
  
  //File dir = new File("images/projs");
  //File[] files = dir.listFiles();
  //println(dir.isHidden());
  
  //if (files != null) {
  //  for (File f : files) {
  //    if (f.isFile() && f.getName().toLowerCase().endsWith(".png")) {
  //      String name = f.getName().substring(0, f.getName().length() - 4);
  //      projSprites.put(name, loadImage(f.getAbsolutePath()));
  //    }
  //  }
  //} else {
  //  println("Projectile Data can't find Sprites directory.");
  //}
}

Map<String, PImage> projSprites = new HashMap<>();


Map<String, Consumer<Monkey>> attacks = new HashMap<>();
void setupAttacks() {
  attacks.put("Dart00", (m) -> {
    addProj(0, m.pos.copy(), m.angle, projSprites.get("basicDart"));
  });
  attacks.put("Cheat", (m) -> {
    String col = new String[]{"B", "BL", "P", "R", "G", "W"}[(int) random(6)];
    addProj(1, m.pos.copy().add(new PVector(5, -5).rotate(m.angle)), m.angle, projSprites.get("laser" + col));
  });
}

class ProjType {
  int dmgType, damage, radius, speed, lifespan, extra;

  ProjType(int[] data) {
    dmgType = data[0];
    damage = data[1];
    radius = data[2];
    speed = data[3];
    lifespan = data[4];
    extra = data[5];
  }
}
