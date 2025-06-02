MonkeyType[] MonkeyTypes;
void setupMonkeyTypes() {
  MonkeyTypes = new MonkeyType[] {
    //id, name, attackname, stats{range, delay, size, cost}
    new MonkeyType(0, "Dart", "Dart00", new int[]{120, 40, 27, 200}),
    new MonkeyType(1, "RayGun", "Cheat", new int[]{400, 0, 40, 0}),
  };
}

class MonkeyType {
  int ID, range, delay, size, cost;
  String name, atkName;
  Consumer<Monkey> attack;
  PImage sprite;
  
  
  MonkeyType(int typeID, String mName, String attackName, int[] stats) {
    ID = typeID;
    name = mName;
    range = stats[0];
    delay = stats[1];
    size = stats[2];
    cost = stats[3];
    atkName = attackName;

    attack = attacks.get(attackName);
    sprite = loadImage("images/monkeys/" + name + ".png");
  }
}
