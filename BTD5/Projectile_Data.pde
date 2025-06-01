ProjType[] ProjTypes;
void setupProjTypes() {
  ProjTypes = new ProjType[] {
    new ProjType("Dart00", "BasicDart", new int[]{0, 1, 10, 5, 25, 2}),
  };
}

class ProjType {
  int dmgType, damage, radius, speed, lifespan, extra;
  PImage sprite;

  ProjType(String name, String spriteName, int[] data) {
    dmgType = data[0];
    damage = data[1];
    radius = data[2];
    speed = data[3];
    lifespan = data[4];
    extra = data[5];
    sprite = loadImage("images/projs/" + spriteName + ".png");
  }
}
