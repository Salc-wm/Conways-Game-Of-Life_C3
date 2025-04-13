module simul;

import cst;
import grid_cells;


alias Grid_game = Grid {cst::SZ_GRID_WTH, cst::SZ_GRID_HHT};

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


macro uint[2] get_coordinates(int pos, int grid) @local =>
    { (pos - 1 + grid) % grid, (pos + 1) % grid };

macro void Simulation.neighbor_check(self, int *cells, int pos, coor_x, coor_y, char mp) {
    int mp_coord = coor_x[mp];

    *cells += (char)self.grid.cells[mp_coord][coor_y[0]];  // Superior Esquerdo | Direito
    *cells += (char)self.grid.cells[mp_coord][pos];        // Esquerdo | Direito
    *cells += (char)self.grid.cells[mp_coord][coor_y[1]];  // Inferior Esquerdo | Direito
}

fn uint Simulation.countLiveNeighbors(self, short x, short y, int live_neighbors = 0) @local {
    int rows = self.grid.getRows();
    int cols = self.grid.getColumns();

    // int minus = (x - 1 + rows) % rows;
    // int plus  = (x + 1) % rows;
    int[2] x_mp_coor = get_coordinates(x, rows);
    int[2] y_mp_coor = get_coordinates(y, cols);

    // Verificação direta dos 8 vizinhos, eliminando o loop foreach
    self.neighbor_check(&live_neighbors, y, x_mp_coor, y_mp_coor, 0);

    live_neighbors += (char)self.getValue(x, (short)y_mp_coor[0]);  // Superior
    live_neighbors += (char)self.getValue(x, (short)y_mp_coor[1]);  // Inferior

    self.neighbor_check(&live_neighbors, y, x_mp_coor, y_mp_coor, 1);
    return live_neighbors;
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


fn void Simulation.processRow(Simulation* self, MatrixG* temp_grid, ushort y, ushort idx_r) @local {
    for (ushort idx_c = 0; idx_c < y; idx_c++) {
        int live_neighbors = self.countLiveNeighbors(idx_r, idx_c);

        bool cell_value = self.getValue(idx_r, idx_c);
        bool will_live = live_neighbors == 3 || cell_value && (live_neighbors == 2);
        // if (live_neighbors != 3 || cell_value && (live_neighbors != 2)) continue; << degradation animation

        if (!will_live) continue;
        (*temp_grid)[idx_r][idx_c] = true;
    }
}

fn void Simulation.update(Simulation* self, double deltaTime) {
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
