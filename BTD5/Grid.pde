WeakHashMap<Bloon, Boolean>[][] grid;

void setupGrid() {
  int rows = (int) ((height - GRIDSIZE / 2) / GRIDSIZE + 1);
  int cols = (int) ((width - GRIDSIZE / 2) / GRIDSIZE + 1);
  grid = (WeakHashMap<Bloon, Boolean>[][]) new WeakHashMap<?, ?>[rows][cols];
  for (int r = 0; r < grid.length; r++) {
    for (int c = 0; c < grid[r].length; c++) {
      grid[r][c] = new WeakHashMap<Bloon, Boolean>();
    }
  }
}

int gridRow(float y) {
  return (int) (y / GRIDSIZE);
}

float rowToY(int row) {
  return (row + 0.5) * GRIDSIZE;
}

int gridCol(float x) {
  return (int) (x / GRIDSIZE);
}

float colToX(int col) {
  return (col + 0.5) * GRIDSIZE;
}

ArrayList<WeakHashMap<Bloon, Boolean>>[] getTilesInRange(float x, float y, float r) {
  ArrayList<WeakHashMap<Bloon, Boolean>>[] mapLists = (ArrayList<WeakHashMap<Bloon, Boolean>>[]) new ArrayList<?>[2];
  
  mapLists[0] = new ArrayList<WeakHashMap<Bloon, Boolean>>();
  mapLists[1] = new ArrayList<WeakHashMap<Bloon, Boolean>>();
  
  float minX = Math.max(0, x - r - GRIDSIZE * sqrt(.5));
  float minY = Math.max(0, y - r - GRIDSIZE * sqrt(.5));
  float maxCol = Math.min(gridCol(width) -1, gridCol(x + r + GRIDSIZE * sqrt(.5)));
  float maxRow = Math.min(gridRow(height) - 1, gridRow(y + r + GRIDSIZE * sqrt(.5)));
  
  float fullCoverRadius = sq(Math.max(0, r - GRIDSIZE * sqrt(.5)));
  float partialCoverRadius = sq(r + GRIDSIZE * sqrt(.5));
  
  for (int col = gridCol(minX); col <= maxCol; col += 1) {
    for (int row = gridCol(minY); row <= maxRow; row += 1) {
      float yVal = rowToY(row);
      float xVal = colToX(col);
      float dist = sq(xVal - x) + sq(yVal - y);
      
      if (dist < fullCoverRadius) {
        mapLists[0].add(grid[row][col]);
        if (!HALP) continue;
        fill(0, 255, 0, 100);
        circle(col * GRIDSIZE + GRIDSIZE / 2, row * GRIDSIZE + GRIDSIZE / 2, GRIDSIZE / 2);
      } else if (dist < partialCoverRadius) {
        mapLists[1].add(grid[row][col]);
        if (!HALP) continue;
        fill(255, 0, 0, 100);
        circle(col * GRIDSIZE + GRIDSIZE / 2, row * GRIDSIZE + GRIDSIZE / 2, GRIDSIZE / 2);
      }
    }
  }
  
  return mapLists;
}
