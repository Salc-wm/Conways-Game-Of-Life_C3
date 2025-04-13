module grid_cells{POS_X, POS_Y} @local;

import cst;
import raylib5::rl;

import std::io;
import std::math;

/* 
 Type of vector arrays directly affects the lifetime and interaction
 int: will last longer than > short: will last longer than char.
 but it could also be just crazy on my part, I didn't do a lot of tests to be sure */
typedef Size_grid @public = bool[POS_X][POS_Y];

struct Grid @public
{
    uint rows, columns, l_cells;
    Size_grid cells;
}

const Rectangle RECT = {
    cst::M_WTH, cst::M_HHT + cst::PADD_TOP,
    cst::CCZ, cst::CCZ // Largura e altura do retângulo
};


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

fn void Grid.drawGrid2D(Grid *self, int cellCount, int cellSize) @public
{   // Calcula o tamanho total do grid
    int gridWidth  = cst::WTH;
    int gridHeight = cst::HHT * 2 - cst::PDG_TOP - 20;

    // Centraliza o grid na tela
    int startX = cst::PDG_LR - 6;
    int startY = cst::PADD_TOP +1;

    // Vertical
    drawGridLines(true, startX, cellCount, startY, gridHeight+100, cellSize, cst::HHT);

    // Horizontal
    drawGridLines(false, startY, cellCount, startX, gridWidth, cellSize, cst::PDG_TOP);
}


fn void Grid.setValue(Grid* self, int x, int y, bool value) @public => self.cells[x][y] = value;
fn bool Grid.getValue(Grid* self, int x, int y) @public => self.cells[x][y];

macro uint Grid.getRows(Grid* self)    @public => self.rows;
macro uint Grid.getColumns(Grid* self) @public => self.columns;

// fn void Grid.setLivingCells(Grid* self) @public => self.l_cells++;

fn void Grid.fillRandomCells(Grid* self) @public {
    foreach (&row: self.cells) foreach (&column: row)
        *column = (rl::getRandomValue(0, 4) == 4)? true:false;

    self.l_cells = 1;
}

fn void Grid.clear(Grid *self) @public {
    if (self.l_cells == 0) return;

    self.l_cells = 0;

    foreach (&column: self.cells[..])
        *column = {};
}


fn void Grid.drawCells(Grid* self, double deltaTime) @public {
    ushort ac = cst::AC;
    ushort padd = cst::PADD;

    ushort cellSize = cst::CELL_SIZE;
    Color grd_cellLife = cst::GRD_CELL_LIFE;

    foreach (ushort idx_r, &row: self.cells) {
        uint gridColumn = idx_r * cellSize + ac;

        foreach (ushort idx_c, column: *row)
            if (column) rl::
                drawRectanglePro(RECT, {(float)idx_c * cellSize + padd, gridColumn}, 0.0f, grd_cellLife );
    }
}
