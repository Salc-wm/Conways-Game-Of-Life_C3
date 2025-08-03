module simul;


import std::collections::map;

import cst, raylib5::rl;
import grid_rendering, std::io;


typedef Vec = ichar[<2>];
alias Vec2 = int[<2>];

alias Grid_game = Grid;
alias HashVec = HashMap{Vec2, bool};

struct Simulation
{
    Grid_game grid;

    bool run;
    double timer;
}


macro void Simulation.draw(self, double deltaTime) => self.grid.drawCells(deltaTime);
fn void Simulation.clearGrid(Simulation* self) {
    if (self.grid.is_empty()) return;

    self.grid.clear();
    self.grid.clearCountCells();
}

macro void Simulation.stop(Simulation* self)  @used => self.run = false;
macro void Simulation.start(Simulation* self) @used => self.run = true;

fn void Simulation.createRandomCellsState(Simulation* self, uint density) {
    self.clearGrid();

    if (density > 100) density = 100;
    if (density == 0) return;

    for (int y = 0; y < cst::TOTALCELLS_WIDTH; y++) for (int x = 0; x < cst::TOTALCELLS_HEIGHT; x++) {
        if (rl::getRandomValue(0, 99) < density) self.grid.insert(x, y);
    }
}


macro uint getGridPos(int pos, ichar neighbor, ushort line) @local => (pos + neighbor + line) % line;

const int COLS @local = cst::HHT / cst::CELL_SIZE;
const int ROWS @local = cst::WTH / cst::CELL_SIZE;

const Vec[8] NEIGHBOR_OFFSETS @local = {
    {-1, -1}, {0, -1}, {1, -1},
    {-1,  0},          {1,  0},
    {-1,  1}, {0,  1}, {1,  1}
};


macro void @offsetLoops(; @body($neighbor)) @local {
    Vec $offset;

    $for var $neighbor = 0; $neighbor < NEIGHBOR_OFFSETS.len; ++$neighbor:
        $offset = NEIGHBOR_OFFSETS[$neighbor];
        @body($offset);
    $endfor
}

macro char? @countNeighbors(Hash2DGrid *grid, Vec2 #cell) @local {
    char sum;
    Stack? array;

    @offsetLoops(; $offset) {
        array = grid.get(getGridPos(#cell.x, $offset.x, COLS));

        if (try array) foreach (y: &array)
            if (y == getGridPos(#cell.y, $offset.y, ROWS)) sum ++;
    };

    return sum;
}


fn void Simulation.update(Simulation* self, double deltaTime) {
    if (!self.run || self.grid.is_empty()) return;

    self.timer += deltaTime;
    if (self.timer < cst::UPDATE_INTERVAL) return;
    self.timer = 0.0f;


    Hash2DGrid *liveCells = &self.grid;

    Hash2DGrid nextLiveCells;
    defer *liveCells = nextLiveCells;

    liveCells.@each(; x, stack) {
        foreach (int y: stack) {
            applyRulesLife(&nextLiveCells, liveCells, {x, y});

            foreach (b, Vec offset: NEIGHBOR_OFFSETS) {
                Vec2 neighbor = {getGridPos(x, offset.x, COLS), getGridPos(y, offset.y, ROWS)};

                if (try char neighbors = @countNeighbors(liveCells, neighbor)) {
                    if (neighbors == 3) nextLiveCells.insert(...neighbor);
                }
            }
        }
    };
}

macro void applyRulesLife(Hash2DGrid *grid, Hash2DGrid *generation, Vec2 cell) @local {
    if (try char neighbors = @countNeighbors(generation, cell)) {
        // (neighbors == 3 || state && (neighbors == 2 ||  neighbors == 3)) grid.insert(...cell);
        if ((neighbors == 2 || neighbors == 3)) grid.insert(...cell);
    }
}

