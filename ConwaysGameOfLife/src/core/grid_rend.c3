module grid_rendering @public;
import std::collections::list;

import cst, std::io;
import raylib5::rl;


typedef CellPos = int[<2>];
alias ListCellPos = List {CellPos};

struct Grid
{
    uint rows, columns, l_cells;
    MatrixG cells;

    ListCellPos cells_l;
}

const Rectangle RECT @local = {
    cst::M_WTH, cst::M_HHT + cst::PADD_TOP,
    cst::CCZ, cst::CCZ // Largura e altura do retângulo
};


macro void drawLineIn(int start, int init, int end_x, int end_y) @local =>
    rl::drawLine(start, init, end_x, end_y, rl::fade(rl::BLACK, 0.5f));

fn void Grid.drawGrid2D(Grid *self, int cellCount, int cellSize) @inline
{
    int gridWidth  = cst::WTH +6;
    int gridHeight = cst::HHT * 2 - cst::PDG_TOP - 20;

    int gridDrawStartX = 3;
    int gridDrawStartY = 71;

    int gridDrawEndX = gridWidth - 1;
    int gridDrawEndY = gridHeight - 4;

    int gridDrawEndYBelow = cst::HHT + 71;
    int gridDrawEndYInit = 4;

    // Vertical
    for (int x = gridDrawEndYInit; x <= gridDrawEndX; x += cellSize
    ) drawLineIn(x, gridDrawStartY, x, gridDrawEndYBelow);

    // Horizontal
    for (int y = gridDrawStartY; y <= gridDrawEndY; y += cellSize
    ) drawLineIn(gridDrawStartX, y, gridDrawEndX, y);
}



fn void Grid.setValue(Grid* self, int x, int y, bool value) @inline => self.cells[x][y] = value;
fn bool Grid.getValue(Grid* self, int x, int y) @inline => self.cells[x][y];

macro uint Grid.getRows(Grid* self)    => self.rows;
macro uint Grid.getColumns(Grid* self) => self.columns;

// fn void Grid.setLivingCells(Grid* self) @public => self.l_cells++;

fn void Grid.fillRandomCells(Grid* self) {
    uint totalColumns = self.cells[0].len;
    uint totalCells = self.cells.len * totalColumns;

    bool* cellData = &self.cells[0][0];

    for (uint cells = 0; cells < totalCells; cells++) cellData
        [ cells ] = rl::getRandomValue(0, 8) == 3;

    self.l_cells = 1;
}

macro void Grid.clear(Grid *self) {
    if (self.l_cells == 0) return;

    self.l_cells = 0;

    foreach (&column: self.cells[..])
        *column = {};
}


fn void Grid.drawCells(Grid* self, double deltaTime) @inline {
    if (self.l_cells == 0) return;
    defer self.cells_l.free();

    float cellSize = cst::CELL_SIZE;
    Color grd_cellLife = cst::GRD_CELL_LIFE;

    if (self.cells_l.len() == 0) return;
    foreach (cell: self.cells_l)
        // Size screen width | Cell width size | Padding

        rl::drawRectanglePro(RECT, {
            // Pos | Space | Start Padding
            cell.y * cellSize + (6 + cellSize),  // X
            cell.x * cellSize + cst::PDG_TOP + cellSize -2 // Y
        }, 0.0f, grd_cellLife);
}
