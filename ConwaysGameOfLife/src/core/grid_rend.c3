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


const int INIT_LEFT @local = cst::M_WTH - cst::TOTALWIDTH -6;
const int INIT_TOP  @local = cst::M_HHT - cst::TOTALHEIGHT - cst::PDG_LR;

macro void drawLineIn(int $start, int $init, int $end_x, int $end_y) @local =>
    rl::drawLine($start, $init, $end_x, $end_y, rl::fade(rl::BLACK, 0.5f));

macro void Grid.drawGrid2D(Grid *self, int cellCount, int cellSize)
{
    rl::drawRectanglePro({INIT_LEFT, INIT_TOP, cst::TOTALWIDTH, cst::TOTALHEIGHT}, { 0f, 0f }, 0f, cst::GRD_CELL_DEAD);

    var $x = 0;
    $for var $cls_wdt = 0; $cls_wdt <= cst::TOTALCELLS_WIDTH; $cls_wdt++:  // Vertical
        $x = INIT_LEFT + $cls_wdt * cst::CELL_SIZE;  // Adjust for padding/offset
        drawLineIn($x, INIT_TOP, $x, INIT_TOP + cst::TOTALHEIGHT);
    $endfor

    var $y = 0;
    $for var $cls_hht = 0; $cls_hht <= cst::TOTALCELLS_HEIGHT; $cls_hht++:  // Horizontal
        $y = INIT_TOP-1 + $cls_hht * cst::CELL_SIZE;
        drawLineIn(INIT_LEFT, $y, INIT_LEFT + cst::TOTALWIDTH, $y);
    $endfor
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
