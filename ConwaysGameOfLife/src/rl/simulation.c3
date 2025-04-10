module gofl_simul;

import cst;
import grid_cells;

import std::time;
import std::thread;


alias Grid_game = Grid {cst::SZ_GRID_WTH, cst::SZ_GRID_HHT};

struct Simulation
{
    bool run;
    uint cells_live;

    double timer;
    Grid_game grid;
}


fn int Simulation.getValue(Simulation* self, Table grid) @inline =>
    self.isWithinBounds(grid) ? self.grid.getValue(grid):0;

/**
 * @require grid.x >= 0, grid.y >= 0
 **/
macro bool Simulation.isWithinBounds(Simulation* self, Table grid) @local =>
    grid.x < self.grid.rows && grid.y < self.grid.columns;


macro uint[2] get_coordinates(int pos, int grid) @local =>
    { (pos - 1 + grid) % grid, (pos + 1) % grid };

macro void Simulation.neighbor_check(self, uint *cells, int pos, coor_x, coor_y, char mp) {
    *cells += self.getValue({coor_x[mp], coor_y[0]});  // Superior Esquerdo | Direito
    *cells += self.getValue({coor_x[mp], pos});        // Esquerdo | Direito
    *cells += self.getValue({coor_x[mp], coor_y[1]});  // Inferior Esquerdo | Direito
}

fn uint Simulation.countLiveNeighbors(Simulation* self, Table *grid, uint live_neighbors = 0) @local {
    uint rows = self.grid.getRows();
    uint cols = self.grid.getColumns();

    // Calcula as coordenadas com wrap-around diretamente, evitando o array de offsets
    int x = grid.x;
    int y = grid.y;

    // int minus = (x - 1 + rows) % rows;
    // int plus  = (x + 1) % rows;
    uint[2] x_mp_coor = get_coordinates(x, rows);
    uint[2] y_mp_coor = get_coordinates(y, cols);

    // Verificação direta dos 8 vizinhos, eliminando o loop foreach
    self.neighbor_check(&live_neighbors, y, x_mp_coor, y_mp_coor, 0);

    live_neighbors += self.getValue({x, y_mp_coor[0]});  // Superior
    live_neighbors += self.getValue({x, y_mp_coor[1]});  // Inferior

    self.neighbor_check(&live_neighbors, y, x_mp_coor, y_mp_coor, 1);

    return live_neighbors;
}

macro void Simulation.draw(Simulation* self, double deltaTime) =>
    self.grid.drawCells(deltaTime);
macro void Simulation.clearGrid(Simulation* self) => self.grid.clear();

fn void Simulation.toggleCell(Simulation* self, Table grid, bool action, ushort v) =>
    action && !self.@isRunning() && self.isWithinBounds(grid)? self.grid.toggleCell(&grid, v) : (void)0;

macro uint Simulation.getLivingCells(Simulation* self) => self.cells_live;

macro void Simulation.stop(Simulation* self)  => self.run = false;
macro void Simulation.start(Simulation* self) => self.run = true;

macro bool Simulation.@isRunning(Simulation* self) => self.run;
macro void Simulation.createRandomState(Simulation* self) => self.grid.fillRandomCells();


fn void Simulation.update(Simulation* self, double deltaTime) {
    if (!self.@isRunning()) return;

    if (self.grid.l_cells == 0) {
        self.cells_live = self.grid.l_cells;
        return;
    }

    self.timer += deltaTime;
    if (self.timer < cst::UPDATE_INTERVAL) return;
    self.timer = 0.0f;

    Grid_game temp_grid = self.grid;
    foreach (ushort idxr, &row: temp_grid.cells) foreach (ushort idxc, &_n: *row) {
        Table pos = { idxr, idxc };

        int live_neighbors = self.countLiveNeighbors(&pos);
        int cell_value = self.getValue(pos);

        bool will_live = (live_neighbors == 3) || (cell_value && (live_neighbors == 2));
        if (will_live) self.grid.setLivingCells();

        temp_grid.toggleCell(&pos, (char)will_live);
    }

    self.cells_live = self.grid.l_cells;
    self.grid = temp_grid;
}
