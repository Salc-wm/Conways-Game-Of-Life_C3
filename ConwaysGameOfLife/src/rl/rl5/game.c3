module gofl_rylib5::system_rl5 @local;

import grid_game;
import gofl_simul;

import raylib5::rl;

import cst;

typedef Table = uint[<2>];
macro bool key_pressed($key) => rl::isKeyPressed($key);

/**
 * @require row >= 0, column >= 0
 **/
macro Table @get_grid_rc(uint row, column) => { row / cst::GRD_CELL_SIZE, column / cst::GRD_CELL_SIZE };
macro Color background_color() => rl::getColor(0x101010FF);

macro void center_draw_text(Text_opt args, Color color, bool align = true) =>
    rl::drawText(args.state, align? cst::CENTER_TEXT + args.r : args.r, args.g, args.b, color);


const Color COLOR_TEXT = rl::LIGHTGRAY;

const Color[2] CL_TEXTS_AC    = { COLOR_TEXT, COLOR_TEXT };
const Color[3] CL_TEXTS_TITLE = { COLOR_TEXT, rl::GREEN, COLOR_TEXT };
const Color[2] CL_TEXTS_STATE = { rl::GREEN, rl::GRAY };


fn Table get_grid_mouse_pos() @inline {
    Vector2 mouse_position = rl::getMousePosition();

    return @get_grid_rc(
        (int)mouse_position.y - cst::PDG_TOP, (int)mouse_position.x
    );
}

fn void keyboard_actions(Simulation* game) {
    if (key_pressed(rl::KEY_ENTER) || key_pressed(rl::KEY_SPACE)) {
        if (!game.run) {
            game.start();

            return;
        }

        game.stop();
    };

    Table grid_hover_mouse = get_grid_mouse_pos();
    // game.toggleCell(grid_hover_mouse, rl::isMouseButtonPressed(MouseButton.LEFT)? true:false, 1);
    // game.toggleCell(grid_hover_mouse, rl::isMouseButtonPressed(MouseButton.RIGHT), 0);

    key_pressed(rl::KEY_F)? game.createRandomState() : (rl::isKeyPressed(rl::KEY_G) ? game.clearGrid() :(void)0);
}

fn void gofl_update(Simulation game) {
    while (!rl::windowShouldClose())
    {
        game.update();

        rl::beginDrawing();
            rl::clearBackground(background_color());
            rl::drawRectangleLines(cst::PADD_COUNTER_BOX + 1, cst::BORDER.x, cst::BORDER.y, cst::BORDER.z, rl::BLACK);

            game.draw();
            game_ui(&game);

        rl::endDrawing();
        keyboard_actions(&game);
    }
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

    game.@isRunning()?
        center_draw_text(cst::GUI_TEXTS_STATE[0], CL_TEXTS_STATE[0]):center_draw_text(cst::GUI_TEXTS_STATE[1], CL_TEXTS_STATE[1]);

    rl::drawText(rl::textFormat("%d", game.getLivingCells()), 120, cst::PDG_TOP-24, 21, rl::GREEN);
}

fn void init(String title) @public
{
    rl::initWindow(cst::M_WTH, cst::M_HHT, title);
    defer rl::closeWindow();

    rl::setTargetFPS(0);


    // Game State: run | Living cells: l_cells | Grid 1/Grid 2: grid
    Grid {cst::SZ_CLS_GRID} game_grid = {
        (cst::M_HHT - cst::PDG_TOP) / cst::GRD_CELL_SIZE,
        cst::M_WTH / cst::GRD_CELL_SIZE, 0,

        grid_game::D_GRID {cst::SZ_CLS_GRID}
    };

    Simulation simulation = { .grid = game_grid };
    gofl_update(simulation);
}
