MonkeyType[] MonkeyTypes;
void setupMonkeyTypes() {
  MonkeyTypes = new MonkeyType[] {
    //id, name, attackname, stats{range, delay, size, cost}
    new MonkeyType(0, "Dart Monkey", "Dart00", new int[]{160, 30, 20, 200}),
    new MonkeyType(1, "Ray Gun", "Cheat", new int[]{400, 5, 30, 0}),
  };
}

class MonkeyType {
  int ID;
  String name, atkName;
  Consumer<Monkey> attack;
  PImage sprite;
  
  int range, cooldown, size, cost;
  
  
  MonkeyType(int typeID, String mName, String attackName, int[] statArr) {
    ID = typeID;
    name = mName;
    range = statArr[0];
    cooldown = statArr[1];
    size = statArr[2];
    cost = statArr[3];

    attack = attacks.get(attackName);
    sprite = loadImage("images/monkeys/" + name + ".png");
  }
  
  MonkeyType(){}
  
  MonkeyType(MonkeyType other) {
    ID = other.ID;
    name = other.name;
    attack = other.attack;
    sprite = other.sprite;
    range = other.range;
    cooldown = other.cooldown;
    size = other.size;
    cost = other.cost;
  }
}
