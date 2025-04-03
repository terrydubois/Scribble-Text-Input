color_text = c_white;
color_bg = c_dkgray;
color_border = c_white;
color_cursor = c_ltgray;
color_highlight = make_color_rgb(74, 145, 240);
    
// focus-specific behaviors
if (textboxFocused) {
    
    // only focus one textbox at a time
    var _self = self;
    with (obj_textbox) {
        if (self != _self) textboxFocused = false;
    }
    
    // progress cursor alpha animation
    acPercent_cursorAlpha += delta_time / 1_000_000;
    acPercent_cursorAlpha = acPercent_cursorAlpha % 1;
    
    // make sure we don't gelt multiple keys inputting at once
    if (string_length(keyboard_string) > 1) {
        keyboard_string = string_char_at(keyboard_string, 1);
    }
    
    // input characters
    var _input = "";
    if (string_length(keyboard_string) > 0) {
        _input = keyboard_string;
        keyboard_string = "";
    }
    if (string_length(_input) >= 1) {
        
        // delete highlighted text if there is any
        if (cursorPos != highlightPos) {
            
            // delete between cursorPos and highlightPos
            var _deletePosL = min(cursorPos, highlightPos);
            var _deletePosR = max(cursorPos, highlightPos);
            var _deleteLen = _deletePosR - _deletePosL;
            str = string_delete(str, _deletePosL + 1, _deleteLen);
            
            if (cursorPos < highlightPos) {
                highlightPos = cursorPos;
            }
            else {
                cursorPos = highlightPos;
            }
        }
        
        // move cursor forward and add new character
        cursorPos += string_length(_input);
        str = string_insert(_input, str, cursorPos);
        highlightPos = cursorPos;
    }
    
    // backspace
    if (keyboard_check(vk_backspace) && canBackspace) {
        
        // delete between cursorPos and highlightPos
        var _deletePosL = min(cursorPos, highlightPos);
        var _deletePosR = max(cursorPos, highlightPos);
        var _deleteLen = _deletePosR - _deletePosL;
        
        str = string_delete(str, _deletePosL + 1, _deleteLen);
        cursorPos = _deletePosL;
        highlightPos = cursorPos;
        
        // deleting single character
        if (_deleteLen == 0 && cursorPos >= 1) {
            str = string_delete(str, cursorPos, 1);
            cursorPos--;
            highlightPos--;
        }
        
        // start backspace timer
        canBackspace = false;
        var _canBackspaceTimer = time_source_create(time_source_game, canBackspaceTimerPeriod, time_source_units_seconds, ResetCanBackspace);
        time_source_start(_canBackspaceTimer);
        
        backspaceReadjust = true;
    }
        
    // move cursor left
    if (keyboard_check(vk_left) && canMoveCursorL) {
        cursorPos--;
        if (!keyboard_check(vk_shift)) highlightPos = cursorPos;
            
        acPercent_cursorAlpha = 1;
        
        // start move cursor left timer
        canMoveCursorL = false;
        var _canMoveCursorLTimer = time_source_create(time_source_game, canMoveCursorLTimerPeriod, time_source_units_seconds, ResetCanMoveCursorL);
        time_source_start(_canMoveCursorLTimer);
    }
    // move cursor right
    else if (keyboard_check(vk_right) && canMoveCursorR) {
        cursorPos++;
        if (!keyboard_check(vk_shift)) highlightPos = cursorPos;
            
        acPercent_cursorAlpha = 1;
        
        // start move cursor right timer
        canMoveCursorR = false;
        var _canMoveCursorRTimer = time_source_create(time_source_game, canMoveCursorRTimerPeriod, time_source_units_seconds, ResetCanMoveCursorR);
        time_source_start(_canMoveCursorRTimer);
    }
    
    // if not holding down a key with a timer, we can effectively skip the timer
    if (!keyboard_check(vk_left)) {
        canMoveCursorL = true;
        canMoveCursorLTimerPeriod = HOLDDOWNKEYTIMER1;
    }
    if (!keyboard_check(vk_right)) {
        canMoveCursorR = true;
        canMoveCursorRTimerPeriod = HOLDDOWNKEYTIMER1;
    }
    if (!keyboard_check(vk_backspace)) {
        canBackspace = true;
        canBackspaceTimerPeriod = HOLDDOWNKEYTIMER1;
    }
    
    // CTRL+A (select all)
    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("A"))) {
        cursorPos = 0;
        highlightPos = string_length(str);
    }
    // HOME (move cursor to start of text)
    if (keyboard_check_pressed(vk_home)) {
        cursorPos = 0;
        if (!keyboard_check(vk_shift)) highlightPos = cursorPos;
    }
    // END (move cursor to end of text)
    if (keyboard_check_pressed(vk_end)) {
        cursorPos = string_length(str);
        if (!keyboard_check(vk_shift)) highlightPos = cursorPos;
    }
    
    // enforce clamping
    xOffset = min(xOffset, 0);
    cursorPos = clamp(cursorPos, 0, string_length(str));
    highlightPos = clamp(highlightPos, 0, string_length(str));
}
    
// restart
if (keyboard_check(vk_control) && keyboard_check_released(ord("R"))) room_restart();