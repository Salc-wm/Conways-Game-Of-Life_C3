module simul;

import cst;
import grid_rendering;


alias Grid_game = Grid;

struct Simulation
{
    bool run;
    // uint cells_live;

    double timer;
    Grid_game grid;
}


fn bool Simulation.getValue(self, short x, short y) @inline =>
    self.isWithinBounds({x, y}) ? self.grid.getValue(x, y):false;

/**
 * @require grid.x >= 0, grid.y >= 0
 **/
macro bool Simulation.isWithinBounds(self, Table grid) @local =>
    grid.x < self.grid.rows && grid.y < self.grid.columns;


// macro uint[2] get_coordinates(int pos, int grid) @local =>
//    { (pos - 1 + grid) % grid, (pos + 1) % grid };

macro int[3] calculateNeighborCoordinates(int pos, int size) @local => {
    (size & (size - 1)) == 0 ?
        (pos - 1) & (size - 1) : (pos - 1 + size) % size,  // anterior
    pos,                                                   // atual
    (size & (size - 1)) == 0 ?
        (pos + 1) & (size - 1) : (pos + 1) % size          // próximo
};

macro uint Simulation.countLiveNeighbors(self, short x, short y, uint count = 0) @local {
    int rows = self.grid.getRows();
    int cols = self.grid.getColumns();

    int[3] x_coords = calculateNeighborCoordinates(x, rows);
    int[3] y_coords = calculateNeighborCoordinates(y, cols);

    bool[] row_prev = &self.grid.cells[x_coords[0]];
    bool[] row_curr = &self.grid.cells[x_coords[1]];
    bool[] row_next = &self.grid.cells[x_coords[2]];

    return (
        // Linha superior
        (uint)row_prev[y_coords[0]] + (uint)row_prev[y_coords[1]] + (uint)row_prev[y_coords[2]] +
        // Linha do meio (excluindo centro)
        (uint)row_curr[y_coords[0]] + (uint)row_curr[y_coords[2]] +
        // Linha inferior
        (uint)row_next[y_coords[0]] + (uint)row_next[y_coords[1]] + (uint)row_next[y_coords[2]]
    );
}

macro void Simulation.draw(self, double deltaTime) => self.grid.drawCells(deltaTime);
macro void Simulation.clearGrid(Simulation* self)  => self.grid.clear();

fn void Simulation.toggleCell(Simulation self, Table grid, bool action, bool v) =>
    //action && !self.@isRunning() && self.isWithinBounds(grid)? self.grid.toggleCell(&grid, v) : (void)0;
    action && self.isWithinBounds(grid)? self.grid.setValue(...grid, v) : (void)0;

// macro uint Simulation.getLivingCells(Simulation* self) => self.cells_live;

macro void Simulation.stop(Simulation* self)  => self.run = false;
macro void Simulation.start(Simulation* self) => self.run = true;

macro bool Simulation.@isRunning(self) => self.run;
macro void Simulation.createRandomState(Simulation* self) => self.grid.fillRandomCells();


fn void Simulation.processRow(Simulation* self, MatrixG* temp_grid, ushort y, ushort idx_r) @local @inline {
    for (ushort idx_c = 0; idx_c < y; idx_c++) {
        int live_neighbors = self.countLiveNeighbors(idx_r, idx_c);

        bool cell_value = self.getValue(idx_r, idx_c);
        bool will_live = (live_neighbors == 3) | (cell_value & (live_neighbors == 2));
        // if (live_neighbors != 3 || cell_value && (live_neighbors != 2)) continue; << degradation animation

        if (!will_live) continue;
        (*temp_grid)[idx_r][idx_c] = true;
    }
}

fn void Simulation.update(Simulation* self, double deltaTime) @inline {
    if (!self.@isRunning() || self.grid.l_cells == 0) return;
        // self.cells_live = self.grid.l_cells;
        //return;
    //}

    self.timer += deltaTime;
    if (self.timer < cst::UPDATE_INTERVAL) return;
    self.timer = 0.0f;

    MatrixG  matrix = cst::TMP_GRD;
    MatrixG* temp_grid = &matrix;

    ushort vetor_y = cst::TMP_GRD[0].len;

    for (ushort idx_r = 0; idx_r < cst::TMP_GRD.len; idx_r++) self
        .processRow(&(*temp_grid), vetor_y, idx_r);

    self.grid.cells = *temp_grid;
}
