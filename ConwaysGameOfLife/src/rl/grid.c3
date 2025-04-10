module grid_cells{SIZE_X, SIZE_Y} @local;

import cst;
import raylib5::rl;

import std::math;

/* 
 Type of vector arrays directly affects the lifetime and interaction
 int: will last longer than > short: will last longer than char.
 but it could also be just crazy on my part, I didn't do a lot of tests to be sure */
typedef Size_grid @public = uint[SIZE_X][SIZE_Y];

struct Grid @compact @public
{
    uint rows, columns, l_cells;
    Size_grid cells;
}

const Color GRD_CELL_DEAD = {65, 65, 65, 255};
const Color GRD_CELL_LIFE = {0, 25, 0, 255};

const ushort AC  = cst::PDG_TOP - 2;
const ushort CCZ = cst::GRD_CELL_SIZE -1;

const ushort PADD = cst::PADD_COUNTER_BOX + 2;
const ushort PADD_TOP = cst::PDG_TOP - cst::PDG_LR;

const Rectangle RECT = {
    cst::M_WTH, cst::M_HHT + PADD_TOP,
    CCZ, CCZ // Largura e altura do retângulo
};

const Rectangle RECT_GA  = {4, PADD_TOP, cst::WTH, cst::HHT};
const Vector2   RECT_POS = { 0.0f, 0.0f };

fn void drawGridLines(
    bool vertical, int start, int count,
    int fixedStart, int fixedLength, int cellSize, int adjust = 0
) {
    int limit = vertical ? count : count - adjust;

    int startX = vertical ? 0 : fixedStart;
    int startY = vertical ? fixedStart - 2 : 0;

    int endX = vertical ? 0 : fixedStart + fixedLength;
    int endY = vertical ? fixedStart + fixedLength - adjust : 0;

    Color color_line = rl::fade(rl::BLACK, 0.7f);

    for (int i = 0; i <= limit; i++) {
        int pos = start + i * cellSize;

        rl::drawLine(
            vertical ? pos : startX,
            vertical ? startY : pos,
            vertical ? pos : endX,
            vertical ? endY : pos,

            color_line
        );
    }
}

fn void drawGrid2D(int cellCount, int cellSize) @local
{   // Calcula o tamanho total do grid
    int gridWidth  = cst::WTH;
    int gridHeight = cst::WTH;

    // Centraliza o grid na tela
    int startX = cst::PDG_LR - 6;
    int startY = PADD_TOP +1;

    // Vertical
    drawGridLines(true, startX, cellCount, startY, gridHeight, cellSize, cst::HHT);

    // Horizontal
    drawGridLines(false, startY, cellCount, startX, gridWidth, cellSize, cst::PDG_TOP);
}


macro void Grid.setValue(Grid* self, Table *grid, int value) => self.cells[grid.x][grid.y] = value;
macro int Grid.getValue(Grid* self, Table grid) @public => self.cells[grid.x][grid.y];

macro uint Grid.getRows(Grid* self)    @public => self.rows;
macro uint Grid.getColumns(Grid* self) @public => self.columns;

macro void Grid.setLivingCells(Grid* self) @public => self.l_cells++;

fn void Grid.fillRandomCells(Grid* self) @public {
    foreach (&row: self.cells) foreach (&column: row)
        *column = (rl::getRandomValue(0, 4) == 4)? 1:0;

    self.l_cells = 1;
}

fn void Grid.clear(Grid *self) @public {
    if (self.l_cells == 0) return;

    self.l_cells = 0;

    foreach (&column: self.cells[..])
        *column = {};
}

macro void Grid.toggleCell(Grid* self, Table *grid, ushort v = 1) @public =>
    self.setValue(grid, v);


fn void Grid.drawCells(Grid* self, double deltaTime) @public {
    rl::drawRectanglePro(RECT_GA, RECT_POS, 0.0f, GRD_CELL_DEAD);
    drawGrid2D(180, cst::GRD_CELL_SIZE);

    foreach (ushort idxr, &row: self.cells) {
        uint grid_column = idxr * cst::GRD_CELL_SIZE + AC;

        foreach (ushort idxc, column: *row)
            if (column) rl::drawRectanglePro(
                RECT, { (float)idxc * cst::GRD_CELL_SIZE + PADD, grid_column },
                0.0f, column ? GRD_CELL_LIFE : GRD_CELL_DEAD
            );
    }
}
