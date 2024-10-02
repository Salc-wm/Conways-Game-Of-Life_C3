module conwaysgameoflife;

import gofl_rylib5::system_rl5;
import gofl_rylib::system_rl;

import gofl_sdl2::system_sdl2;
import gofl_sdl3::system_sdl;

import gofl_opengl::system_glfw;


def Sys_api = fn void(String title, char *api);

const String TTBN = "C3 | Game Of Life";

const Sys_api[5] APIS_GAME = {
    &system_rl::init,
    &system_rl5::init,

    &system_sdl::init,
    &system_sdl2::init,

    &system_glfw::init
};


fn void sys_change_api(char *api_s = &&(char)1) {
    foreach (start_game: APIS_GAME) start_game(TTBN, api_s);
}

fn void main() {
    sys_change_api();
}
