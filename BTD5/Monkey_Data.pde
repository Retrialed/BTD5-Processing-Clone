Map<String, Consumer<Monkey>> attacks = new HashMap<>();
void setupAttacks() {
  attacks.put("Dart00", (m) -> {
    addProj(0, m.pos.copy(), m.angle);
  });
}

MonkeyType[] MonkeyTypes;
void setupMonkeyTypes() {
  MonkeyTypes = new MonkeyType[] {
    //id, name, attackname, stats{range, delay, size}
    new MonkeyType(0, "Dart", "Dart00", new int[]{120, 40, 25}),
  
  };
}

class MonkeyType {
  int ID, range, delay, size;
  String name, atkName;
  Consumer<Monkey> attack;
  PImage sprite;
  
  
  MonkeyType(int typeID, String mName, String attackName, int[] stats) {
    ID = typeID;
    name = mName;
    range = stats[0];
    delay = stats[1];
    size = stats[2];
    atkName = attackName;

    attack = attacks.get(attackName);
    sprite = loadImage("images/monkeys/" + name + ".png");
  }
}
