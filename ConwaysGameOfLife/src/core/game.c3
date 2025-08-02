module gofl_rylib5::system_rl5 @local;

import cst, simul;
import raylib5::rl;


macro bool @key_pressed($key) => rl::isKeyPressed($key);

/**
 * @require row >= 0, column >= 0
 **/
// macro Table @get_grid_rc(uint row, column) => { row / cst::GRD_CELL_SIZE, column / cst::GRD_CELL_SIZE };
macro float @subtract_float(double #a, double #b) => (float)(#a - #b);

macro void center_draw_text(Text_opt args, Color color, bool align = true) =>
    rl::drawText(args.state, align? cst::CENTER_TEXT + args.r : args.r, args.g, args.b, color);


const Color COLOR_TEXT = rl::LIGHTGRAY;

const Color[2] CL_TEXTS_AC    = { COLOR_TEXT, COLOR_TEXT };
const Color[3] CL_TEXTS_TITLE = { COLOR_TEXT, rl::GREEN, COLOR_TEXT };
const Color[2] CL_TEXTS_STATE = { rl::GREEN, rl::GRAY };


/*fn Table get_grid_mouse_pos() @inline {
    Vector2 mouse_position = rl::getMousePosition();

    return @get_grid_rc(
        (int)mouse_position.y - cst::PDG_TOP, (int)mouse_position.x
    );
}*/

macro void @keyboard_actions(Simulation* #game) {
    if (@key_pressed(rl::KEY_ENTER) || @key_pressed(rl::KEY_SPACE)) {
        if (!#game.run) {
            #game.start();

            return;
        }

        #game.stop();
    };
    // Table grid_hover_mouse = get_grid_mouse_pos();
    // game.toggleCell(grid_hover_mouse, rl::isMouseButtonPressed(MouseButton.LEFT)? true:false, 1);
    // game.toggleCell(grid_hover_mouse, rl::isMouseButtonPressed(MouseButton.RIGHT), 0);

    @key_pressed(rl::KEY_F)? #game.createRandomCellsState(16) : (@key_pressed(rl::KEY_G) ? #game.clearGrid() :(void)0);
}

macro void @whileWindowOpen($color_background; @body()) @local {
    while (!rl::windowShouldClose()) {
        rl::beginDrawing();
        rl::clearBackground(rl::getColor($color_background));

        @body();

        rl::endDrawing();
    }
}

fn void gofl_update(Simulation game) {
    double previousTime = rl::getTime();  // Previous time measure
    double currentTime  = 0f;             // Current time measure

    float deltaTime   = 0f;             // Frame time (Update + Draw + Wait time)
    float timeCounter = 0f;             // Accumulative time counter (seconds)
    float updateDrawTime = 0f;          // Update + Draw time

    @whileWindowOpen(0x101010FF) {
        game.grid.drawGrid2D(180, cst::CELL_SIZE);

        game.update(deltaTime);
        game.draw(deltaTime);

        game_ui(&game);
        @keyboard_actions(&game);

        do {  // Framerate could be variable
            currentTime = rl::getTime();
            updateDrawTime = @subtract_float(currentTime, previousTime);

            float targetFrameTime = 1.0f / 144;

            if (updateDrawTime < targetFrameTime) rl::
                waitTime(targetFrameTime - updateDrawTime);

            deltaTime = @subtract_float(rl::getTime(), previousTime);
            previousTime = currentTime;
        };
    };
}

fn void game_ui(Simulation* game) {
    uint width = rl::getScreenWidth() - cst::PDG_TOP - 30;

    rl::drawFPS(width, cst::PDG_LR);
    rl::drawText(rl::textFormat(
        "Screen Size: [%d, %d]", cst::WTH, cst::HHT), width-150, cst::PDG_TOP-24, 20, rl::GREEN);

    foreach (idx, ui: cst::GUI_TEXTS_TITLE) center_draw_text(ui, CL_TEXTS_TITLE[idx]);
    foreach (idx, ui: cst::GUI_TEXTS_AC) center_draw_text(ui, CL_TEXTS_AC[idx], false);

    center_draw_text({"Raylib 5 -> OpenGL", 112, cst::PDG_TOP-70, 16}, rl::ORANGE, false);
    rl::drawText(rl::textFormat("Elapsed Time: %02.02f ms", rl::getFrameTime()*1000), 10, 25, 19, rl::YELLOW);

    game.run?
        center_draw_text(cst::GUI_TEXTS_STATE[0], CL_TEXTS_STATE[0]):
        center_draw_text(cst::GUI_TEXTS_STATE[1], CL_TEXTS_STATE[1]);

    rl::drawText(rl::textFormat("%d", game.grid.countCells()), 122, cst::PDG_TOP-24, 21, rl::GREEN);
}


macro void init(String $title = "GAME", int $fps = 0) @public
{
    rl::setConfigFlags(rl::FLAG_WINDOW_UNDECORATED | rl::FLAG_VSYNC_HINT);

    rl::initWindow(cst::M_WTH, cst::M_HHT, $title);
    defer rl::closeWindow();

    rl::setTargetFPS($fps? $fps: cst::FPS);

    // Game State: run | Living cells: alives | Grid 0/Grid 2: grid
    gofl_update({ .grid = (Grid_game) {} });
}
