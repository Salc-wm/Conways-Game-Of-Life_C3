module simul;

import cst, std::io;
import grid_rendering;


alias Grid_game = Grid;
struct Simulation @packed
{
    bool run;
    double timer;

    Allocator mem;
    Grid_game grid;
}


macro bool Simulation.getValue(self, int x, int y) @local => self.grid.getValue(x, y);
    // self.grid.getValue(x, y);

/**
 * @require grid.x >= 0, grid.y >= 0
 **/
macro bool Simulation.isWithinBounds(self, Table grid) @local =>
    grid.x < self.grid.rows && grid.y < self.grid.columns;


macro void Simulation.draw(self, double deltaTime) => self.grid.drawCells(deltaTime);
macro void Simulation.clearGrid(Simulation* self)  => self.grid.clear();

macro void Simulation.stop(Simulation* self)  @used => self.run = false;
macro void Simulation.start(Simulation* self) @used => self.run = true;

macro void Simulation.createRandomState(Simulation* self) => self.grid.fillRandomCells();

macro int getGridPos(pos, $neighbor, line) => (pos + $neighbor + line) % line;
macro void setGrid(MatrixG *grid, int x, int y, bool mode) => (*grid)[x][y] = mode;


const int COLS @local = cst::HHT / cst::CELL_SIZE;
const int ROWS @local = cst::WTH / cst::CELL_SIZE;

macro int @countNeighbors(MatrixG grid, int #x, int y) {
    var sum = 0;
    var x_cols = 0;

    $for var $x_coord = -1; $x_coord < 2; $x_coord++:
        x_cols = getGridPos(#x, $x_coord, COLS);

        $for var $y_coord = -1; $y_coord < 2; $y_coord++:
            sum += (char) grid[x_cols]
                [getGridPos(y, $y_coord, ROWS)
            ];
        $endfor
    $endfor

    return sum - (char) grid[#x][y];
}

fn void Simulation.update(Simulation* self, double deltaTime) {
    if (!self.run || self.grid.l_cells == 0) return;
        // self.cells_live = self.grid.l_cells;
        //return;
    //}

    self.timer += deltaTime;
    if (self.timer < cst::UPDATE_INTERVAL) return;
    self.timer = 0.0f;

    MatrixG temp_grid = self.grid.cells;
    defer self.grid.cells = temp_grid;

    self.grid.cells_l.init(self.mem);

    foreach (int x, &col : temp_grid) foreach (int y, _n : col) {
        int neighbors = @countNeighbors(self.grid.cells, x, y);

        bool state = self.getValue(x, y);
        bool new_state = (state & (neighbors == 2 || neighbors == 3)) | (!state && neighbors == 3);

        if (new_state != state) setGrid(&temp_grid, x, y, new_state);
        if (new_state) self.grid.cells_l.push({x, y});
    }
}
