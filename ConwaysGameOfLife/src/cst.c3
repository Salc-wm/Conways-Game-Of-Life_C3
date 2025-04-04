// N leave less than 3, crash
const int GRD_CELL_SIZE = 3;

const char PDG_TOP = 80;
const char PDG_LR = 10;

const uint HHT = 950;
const uint WTH = 950;

const uint M_HHT = HHT + PDG_TOP;  // Height - Altura
const uint M_WTH = WTH + PDG_LR;   // Width - largura

const SZ_CLS_GRID = HHT / cst::GRD_CELL_SIZE;

const ichar PADD_COUNTER_BOX = 4;
const ushort CENTER_TEXT = WTH/ 2 - PDG_TOP;

const int[<3>] BORDER = {
    PDG_TOP - 3,

    M_WTH - PDG_LR,
    M_HHT - PDG_TOP
};


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
