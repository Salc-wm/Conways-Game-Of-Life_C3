const ushort FPS = 120;
const float UPDATE_INTERVAL = 0.09f;

// No leave less than 4, crash -> below 9 performance issues
// problem Grid, if you directly change the CCZ of the grid file, any size is valid
const char GRD_CELL_SIZE = 10;

const char PDG_TOP = 80;
const char PDG_LR = 10;

const uint HHT = 900;
const uint WTH = 1800;

const uint M_HHT = HHT + PDG_TOP;  // Height - Altura
const uint M_WTH = WTH + PDG_LR;   // Width - largura

const ushort SZ_GRID_HHT = HHT / cst::GRD_CELL_SIZE +1;
const ushort SZ_GRID_WTH = WTH / cst::GRD_CELL_SIZE +1;

const ichar PADD_COUNTER_BOX = 4;
const ushort CENTER_TEXT = WTH/ 2 - PDG_TOP;

const int[<3>] BORDER = {
    PDG_TOP - 3,

    M_WTH - PDG_LR,
    M_HHT - PDG_TOP
};

typedef Table = uint[<2>];

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
