module grid_rendering @local;

import cst;
import raylib5::rl;

import std::io;


struct Grid @public
{
    uint rows, columns, l_cells;
    MatrixG cells;
}

const Rectangle RECT = {
    cst::M_WTH, cst::M_HHT + cst::PADD_TOP,
    cst::CCZ, cst::CCZ // Largura e altura do retângulo
};


fn void drawGridLines(
    bool vertical, int start, int count,
    int fixedStart, int fixedLength, int cellSize, int adjust = 0
) @inline {
    //int limit = vertical ? count + (cst::M_WTH / count) * 12: count;
    int limit = vertical ? (cst::M_WTH + cellSize - 1) / cellSize : (cst::HHT + cellSize - 1) / cellSize;

    int startX = vertical ? 0 : fixedStart;
    int startY = vertical ? fixedStart - 2 : 0;

    int endX = vertical ? 0 : fixedStart + fixedLength;
    int endY = vertical ? fixedStart + fixedLength - adjust : 0;

    Color color_line = rl::fade(rl::BLACK, 0.5f);

    for (int lines = 0; lines <= limit; lines++) {
        int pos = start + lines * cellSize;

        rl::drawLine(
            vertical ? pos    : startX,
            vertical ? startY : pos,
            vertical ? pos    : endX,
            vertical ? endY   : pos,

            color_line
        );
    }
}

fn void Grid.drawGrid2D(Grid *self, int cellCount, int cellSize) @inline @public
{   // Calcula o tamanho total do grid
    int gridWidth  = cst::WTH;
    int gridHeight = cst::HHT * 2 - cst::PDG_TOP - 20;

    // Centraliza o grid na tela
    int startX = cst::PDG_LR - 6;
    int startY = cst::PADD_TOP +1;

    // Vertical
    drawGridLines(true, startX, cellCount, startY, gridHeight+100, cellSize, cst::HHT);

    // Horizontal
    drawGridLines(false, startY, cellCount, startX, gridWidth, cellSize);
}


fn void Grid.setValue(Grid* self, int x, int y, bool value) @inline @public => self.cells[x][y] = value;
fn bool Grid.getValue(Grid* self, int x, int y) @inline @public => self.cells[x][y];

macro uint Grid.getRows(Grid* self)    @public => self.rows;
macro uint Grid.getColumns(Grid* self) @public => self.columns;

// fn void Grid.setLivingCells(Grid* self) @public => self.l_cells++;

fn void Grid.fillRandomCells(Grid* self) @public {
    uint totalColumns = self.cells[0].len;
    uint totalCells = self.cells.len * totalColumns;

    bool* cellData = &self.cells[0][0];

    for (uint cells = 0; cells < totalCells; cells++) cellData[
        cells ] = (rl::getRandomValue(0, 4) == 4);

    self.l_cells = 1;
}

fn void Grid.clear(Grid *self) @public {
    if (self.l_cells == 0) return;

    self.l_cells = 0;

    foreach (&column: self.cells[..])
        *column = {};
}


// NOTE: Changes the way horizontal cell positions are rendered from the end, the screen to pos 0 onwards
// : idx_c <
fn void Grid.drawCells(Grid* self, double deltaTime) @inline @public {
    if (self.l_cells == 0) return;

    float cellSize = cst::CELL_SIZE;
    Color grd_cellLife = cst::GRD_CELL_LIFE;

    uint totalColumns = self.cells[0].len;
    uint totalCells = self.cells.len * totalColumns;

    float cellWthSize = totalColumns * cellSize;
    float cellHhtSize = ((float)totalCells / totalColumns + 1) * cellSize;

    for (uint rows = 0; rows < totalCells; rows++) {
        uint idx_r = rows / totalColumns;
        uint idx_c = rows % totalColumns;

        // Size screen width | Cell width size | Padding
        float paddLeftGrid   = cst::WTH   - cellWthSize + (6 + cellSize);
        float paddBottonGrid = cst::M_HHT - cellHhtSize + 2* cellSize -2;

        if (self.cells[idx_r][idx_c]) rl::
            drawRectanglePro(RECT, {
                // Pos | Space | Start Padding
                idx_c * cellSize + paddLeftGrid,   // X
                idx_r * cellSize + paddBottonGrid  // Y
            }, 0.0f, grd_cellLife);
    }
}
