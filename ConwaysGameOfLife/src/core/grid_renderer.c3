module grid_rendering @public;

import std::collections::map;
import cst, raylib5::rl, std::io;


alias Hash2D @local = HashMap{int, Stack};
struct Hash2DGrid {
    inline HashMap{int, Stack} __hash;
    usz __cell_count;
}

macro void Hash2DGrid.clearCountCells(&self) => self.__cell_count = 0;
macro usz Hash2DGrid.countCells(&self) => self.__cell_count;

macro void Hash2DGrid.insert(&self, int x, int y)
{
    Stack* ?ref = self.get_ref(x);

    if (catch ref) {
        Stack inner;
        self.set(x, inner);
    }

    ref = self.get_ref(x);

    if (try ref) foreach (item: ref)
        if (item == y) return;
    (void)ref.set(y);

    ++ self.__cell_count;
}


struct Stack @compact
{
    int* __elements;
    usz capacity, __len;
}

macro void Stack.set(Stack* self, int y) {
    if (self.capacity == self.__len) {
        self.capacity = self.capacity ? self.capacity * 2 : 16;
        self.__elements = trealloc(self.__elements, int.sizeof * self.capacity);
    }

    self.__elements[self.__len++] = y;
}

macro usz Stack.count(Stack* arr) @operator(len) => arr.__len;
<*
 @require element < arr.__len : `Access out of bounds`
*>
macro int Stack.get(Stack* arr, usz element) @operator([]) => arr.__elements[element];


const Rectangle RECT @local = {
    cst::M_WTH, cst::M_HHT + cst::PADD_TOP,
    cst::CCZ, cst::CCZ
};

const int INIT_LEFT @local = cst::M_WTH - cst::TOTALWIDTH -6;
const int INIT_TOP  @local = cst::M_HHT - cst::TOTALHEIGHT - cst::PDG_LR;

macro void @forLinesGrid(int $init_pos; @body($pos_line)) @local {
    var $pos = 0;

    $for var $lines = 0; $lines <= cst::TOTALCELLS_WIDTH; $lines++:
        $pos = $init_pos + $lines * cst::CELL_SIZE;  // Adjust for padding/offset
        @body($pos);
    $endfor
}

macro void drawLineIn(int $start, int $init, int $end_x, int $end_y) @local =>
    rl::drawLine($start, $init, $end_x, $end_y, rl::fade(rl::BLACK, 0.5f));

macro void Grid.drawGrid2D(Grid *self, int cellCount, int cellSize)
{
    rl::drawRectanglePro({INIT_LEFT, INIT_TOP, cst::TOTALWIDTH, cst::TOTALHEIGHT}, { 0f, 0f }, 0f, cst::GRD_CELL_DEAD);

    @forLinesGrid(INIT_LEFT; $x) {
        drawLineIn($x, INIT_TOP, $x, INIT_TOP + cst::TOTALHEIGHT);
    };

    @forLinesGrid(INIT_TOP-1; $y) {
        drawLineIn(INIT_LEFT, $y, INIT_LEFT + cst::TOTALWIDTH, $y);
    };
}


struct Grid { inline Hash2DGrid __liveCells; }

fn void Grid.drawCells(&self, double deltaTime) @inline {
    if (self.is_empty()) return;

    float cellSizeF = cst::CELL_SIZE;

    int initialGridX = cst::CELL_SIZE + 6;
    int initialGridY = cst::PDG_TOP + cst::CELL_SIZE;

    foreach (entry: self.iter()) {
        int x = entry.key;

        foreach (y: entry.value) {
            // Size screen width | Cell width size | Padding

            rl::drawRectanglePro(RECT, {
                // Pos | Space | Start Padding
                y * cellSizeF + initialGridX,
                x * cellSizeF + initialGridY
            }, 0.0f, cst::GRD_CELL_LIFE);
        }
    }
}
