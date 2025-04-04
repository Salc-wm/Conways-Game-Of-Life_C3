module gofl_simul;

import std::io;

import cst;
import grid_game;


alias M_grid = Grid {cst::SZ_CLS_GRID};
alias M_table = Table {cst::SZ_CLS_GRID};

struct Simulation
{
    bool run;
    uint cells_live;

    M_grid grid;
}


fn int Simulation.getValue(Simulation* self, M_table grid) @inline =>
    self.isWithinBounds(grid) ? self.grid.getValue(grid):0;

/**
 * @require grid.x >= 0, grid.y >= 0
 **/
macro bool Simulation.isWithinBounds(Simulation* self, M_table grid) @local =>
    grid.x < self.grid.rows && grid.y < self.grid.columns;

fn uint Simulation.countLiveNeighbors(Simulation* self, M_table *grid) @local {
    uint live_neighbors = 0;

    uint rows = self.grid.getRows();
    uint cols = self.grid.getColumns();

    // Calcula as coordenadas com wrap-around diretamente, evitando o array de offsets
    int x = grid.x;
    int y = grid.y;

    // Cálculo das coordenadas com mod otimizado usando operações inline
    int x_minus = (x - 1 + rows) % rows;
    int x_plus  = (x + 1) % rows;

    int y_minus = (y - 1 + cols) % cols;
    int y_plus  = (y + 1) % cols;

    // Verificação direta dos 8 vizinhos, eliminando o loop foreach
    live_neighbors += self.getValue({x_minus, y_minus});  // Superior esquerdo
    live_neighbors += self.getValue({x_minus, y});        // Esquerdo
    live_neighbors += self.getValue({x_minus, y_plus});   // Inferior esquerdo
    live_neighbors += self.getValue({x, y_minus});        // Superior
    live_neighbors += self.getValue({x, y_plus});         // Inferior
    live_neighbors += self.getValue({x_plus, y_minus});   // Superior direito
    live_neighbors += self.getValue({x_plus, y});         // Direito
    live_neighbors += self.getValue({x_plus, y_plus});    // Inferior direito

    return live_neighbors;
}

macro void Simulation.draw(Simulation* self) => self.grid.draw();
macro void Simulation.clearGrid(Simulation* self) => self.grid.clear();

fn void Simulation.toggleCell(Simulation* self, M_table grid, bool action, ushort v) =>
    action && !self.@isRunning() && self.isWithinBounds(grid)? self.grid.toggleCell(&grid, v) : (void)0;

macro uint Simulation.getLivingCells(Simulation* self) => self.cells_live;

macro void Simulation.stop(Simulation* self)  => self.run = false;
macro void Simulation.start(Simulation* self) => self.run = true;

macro bool Simulation.@isRunning(Simulation* self) => self.run;
macro void Simulation.createRandomState(Simulation* self) => self.grid.fillRandom();

fn void Simulation.update(Simulation* self) {
    if (!self.@isRunning() || self.grid.l_cells == 0) {
        self.cells_live = self.grid.l_cells;
        return;
    }

    M_grid temp_grid = self.grid;
    foreach (ushort idxr, &row: temp_grid.cells) foreach (ushort idxc, &_n: *row) {
        M_table pos = { idxr, idxc };

        int live_neighbors = self.countLiveNeighbors(&pos);
        int cell_value = self.getValue(pos);

        bool will_live = (live_neighbors == 3) || (cell_value && (live_neighbors == 2));
        if (will_live) self.grid.setLivingCells();

        temp_grid.toggleCell(&pos, (char)will_live);
    }

    self.cells_live = self.grid.l_cells;
    self.grid = temp_grid;
}
