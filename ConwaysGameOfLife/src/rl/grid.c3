module grid_game{SIZE};

import cst;
import raylib5::rl;

import std::math;

/* 
 Type of vector arrays directly affects the lifetime and interaction
 int: will last longer than > short: will last longer than char.
 but it could also be just crazy on my part, I didn't do a lot of tests to be sure */
typedef Size_grid = uint[SIZE][SIZE];

const Color GRD_CELL_DEAD  @local = {65, 65, 65, 255};
const Color GRD_CELL_LIFE  @local = {0, 25, 0, 255};


struct Grid
{
    uint rows, columns, l_cells;
    Size_grid cells;
}

macro void Grid.setValue(Grid* self, Table *grid, int value) @private => self.cells[grid.x][grid.y] = value;
macro int Grid.getValue(Grid* self, Table grid) => self.cells[grid.x][grid.y];

macro uint Grid.getRows(Grid* self) => self.rows;
macro uint Grid.getColumns(Grid* self) => self.columns;

macro void Grid.setLivingCells(Grid* self) => self.l_cells++;

fn void Grid.fillRandom(Grid* self) {
    foreach (&row: self.cells) foreach (&column: row)
        *column = (rl::getRandomValue(0, 4) == 4)? 1:0;

    self.l_cells = 1;
}

fn void Grid.clear(Grid *self) {
    if (self.l_cells == 0) return;

    self.l_cells = 0;

    foreach (&column: self.cells[..])
        *column = {};
}

macro void Grid.toggleCell(Grid* self, Table *grid, ushort v = 1) => self.setValue(grid, v);

const ushort AC   @local = cst::PDG_TOP - 2;
const ushort CCZ  @local = cst::GRD_CELL_SIZE - 1;
const ushort PADD @local = cst::PADD_COUNTER_BOX + 2;

const Rectangle RECT @local = {
    cst::M_WTH - 2, cst::M_HHT + cst::PDG_TOP - cst::PDG_LR,
    CCZ, CCZ // Largura e altura do retângulo
};

fn void Grid.draw(Grid* self, double deltaTime) {
    foreach (ushort idxr, &row: self.cells) {
        ushort grid_column = idxr * cst::GRD_CELL_SIZE + AC;

        foreach (ushort idxc, column: *row)
            //if (column) continue;
            rl::drawRectanglePro(RECT, {
                (float)idxc * cst::GRD_CELL_SIZE + PADD, grid_column },
                0.0f, column ? GRD_CELL_LIFE : GRD_CELL_DEAD);
    }
}
