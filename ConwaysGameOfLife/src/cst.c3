import raylib5::rl;


const char FPS = 165;
const float UPDATE_INTERVAL = 0.09f;

const char CELL_SIZE = 2;

const char PDG_TOP = 80;
const char PDG_LR = 10;

const uint HHT = 950;
const uint WTH = 1400;


const uint M_HHT = HHT + PDG_TOP;  // Height - Altura
const uint M_WTH = WTH + PDG_LR;   // Width - largura

const short SZ_GRID_HHT @if(CELL_SIZE > 1) = HHT / CELL_SIZE +1;
const short SZ_GRID_WTH @if(CELL_SIZE > 1) = WTH / CELL_SIZE +1;

const short SZ_GRID_HHT @if(CELL_SIZE == 1) = HHT / 2+1;
const short SZ_GRID_WTH @if(CELL_SIZE == 1) = WTH / 2+1;

const ushort CENTER_TEXT = WTH/ 2 - PDG_TOP;


const Color GRD_CELL_LIFE = {255, 255, 255, 255};
const Color GRD_CELL_DEAD = {65, 65, 65, 255};

const float CCZ @if(CELL_SIZE == 1) = 0.509;
const float CCZ @if(CELL_SIZE > 1) = CELL_SIZE -0.5;

$assert(CCZ > 0);


const ushort PADD_TOP = cst::PDG_TOP - cst::PDG_LR;

const int TOTALWIDTH = TOTALCELLS_WIDTH * CELL_SIZE;
const int TOTALHEIGHT = TOTALCELLS_HEIGHT * CELL_SIZE;

const int TOTALCELLS_WIDTH = SZ_GRID_WTH -1;
const int TOTALCELLS_HEIGHT = SZ_GRID_HHT -1;


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
