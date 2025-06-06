MonkeyType[] MonkeyTypes;
void setupMonkeyTypes() {
  MonkeyTypes = new MonkeyType[] {
    //id, name, attackname, stats{range, delay, size, cost}
    new MonkeyType(0, "Dart", "Dart00", new int[]{120, 40, 27, 200}),
    new MonkeyType(1, "RayGun", "Cheat", new int[]{400, 4, 40, 0}),
  };
}

class MonkeyType {
  int ID;
  String name, atkName;
  Consumer<Monkey> attack;
  PImage sprite;
  
  HashMap<String, Integer> stats = new HashMap(4);
  
  
  MonkeyType(int typeID, String mName, String attackName, int[] statArr) {
    ID = typeID;
    name = mName;
    stats.put("range", statArr[0]);
    stats.put("delay", statArr[1]);
    stats.put("size", statArr[2]);
    stats.put("cost", statArr[3]);

    attack = attacks.get(attackName);
    sprite = loadImage("images/monkeys/" + name + ".png");
  }
  
  MonkeyType(){}
  
  void editStat(String stat, int inc) {
    stats.put(stat, stats.get(stat) + inc);
  }
  
  int getStat(String stat) {
    return stats.get(stat);
  }
  
  MonkeyType clone() {
    MonkeyType clone = new MonkeyType();
    
    clone.ID = ID;
    clone.name = name;
    clone.attack = attack;
    clone.sprite = sprite;
    //clone.stats = stats.clone();
    
    return clone;
  }
}
