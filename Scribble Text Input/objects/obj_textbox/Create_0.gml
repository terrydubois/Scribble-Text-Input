/// Feather ignore all
    
// time durations for holding down keys
#macro HOLDDOWNKEYTIMER1 0.4
#macro HOLDDOWNKEYTIMER2 0.02

// effects (to add effects, use effectsTags variable, currently set as Creation Code in Room editor)
scribble_anim_shake(5, 0.5);

// dimensions and coordinates
textboxWidth = 300;
textboxHeight = 40;
xOffset = 0;

// positions
cursorPos = 0;
highlightPos = 0;

// misc variables
acPercent_cursorAlpha = 0;
textboxFocused = true;
validDrag = false;
backspaceReadjust = false;

// default text
str = "";
text = scribble($"[fa_left][fa_middle][c_white][fnt_textbox]{str}");

// assign colors
color_text = c_white;
color_bg = c_dkgray;
color_border = c_white;
color_cursor = c_ltgray;
color_highlight = make_color_rgb(74, 145, 240);

// vars and timer for moving cursor left
canMoveCursorL = true;
canMoveCursorLTimerPeriod = HOLDDOWNKEYTIMER1;
ResetCanMoveCursorL = function() {
    canMoveCursorL = true;
    if (keyboard_check(vk_left)) canMoveCursorLTimerPeriod = HOLDDOWNKEYTIMER2;
}

// vars and timer for moving cursor right
canMoveCursorR = true;
canMoveCursorRTimerPeriod = HOLDDOWNKEYTIMER1;
ResetCanMoveCursorR = function() {
    canMoveCursorR = true;
    if (keyboard_check(vk_right)) canMoveCursorRTimerPeriod = HOLDDOWNKEYTIMER2;
}

// vars and timer for backspace
canBackspace = true;
canBackspaceTimerPeriod = HOLDDOWNKEYTIMER1;
ResetCanBackspace = function() {
    canBackspace = true;
    if (keyboard_check(vk_backspace)) canBackspaceTimerPeriod = HOLDDOWNKEYTIMER2;
}

rapidClickCount = 0;
var _ResetRapidClickCount = function() {
    rapidClickCount = 0;
}
rapidClickCountTimer = time_source_create(time_source_game, 0.4, time_source_units_seconds, _ResetRapidClickCount);