import raylib5::rl;
import grid_size;


const ushort FPS = 165;
const float UPDATE_INTERVAL = 0.09f;

// No leave less than 2, crash -> below 5 performance issues
// problem Grid, if you directly change the CCZ of the grid file, any size is valid
const char CELL_SIZE = 8;

const char PDG_TOP = 80;
const char PDG_LR = 10;

const uint HHT = 800;
const uint WTH = 1700;

const uint M_HHT = HHT + PDG_TOP;  // Height - Altura
const uint M_WTH = WTH + PDG_LR;   // Width - largura

const short SZ_GRID_HHT = HHT / CELL_SIZE +1;
const short SZ_GRID_WTH = WTH / CELL_SIZE +1;

const ichar PADD_COUNTER_BOX = 4;
const ushort CENTER_TEXT = WTH/ 2 - PDG_TOP;


const Color GRD_CELL_LIFE = {0, 25, 0, 255};
const Color GRD_CELL_DEAD = {65, 65, 65, 255};

const ushort CCZ = cst::CELL_SIZE -1;
const ushort PADD_TOP = cst::PDG_TOP - cst::PDG_LR;

const Rectangle RECT_GA  = {4, PADD_TOP+2, cst::WTH, cst::HHT};
const Vector2   RECT_POS = { 0.0f, 0.0f };


const int[<3>] BORDER = {
    PDG_TOP - 3,

    M_WTH - PDG_LR,
    M_HHT - PDG_TOP
};

typedef Table = uint[<2>];

alias MatrixG = Size_grid{cst::SZ_GRID_WTH -1, cst::SZ_GRID_HHT -1};
const MatrixG TMP_GRD = {};


struct Text_opt {
    ZString state;
    short r, g, b;
}

const Text_opt[2] GUI_TEXTS_AC = {
    {"Living cells:", 22, cst::PDG_TOP-24, 19},
    {"Graphic API:",  10, cst::PDG_TOP-70, 17},
};

const Text_opt[3] GUI_TEXTS_TITLE = {
    {"The Game Of", -5, 18, 20},
    {"LIFE!", 133, 18, 20},

    {"Game:", 40, 55, 24}
};

const Text_opt[2] GUI_TEXTS_STATE = {
    {"On",  110, 55, 24},
    {"Off", 110, 55, 24}
};
