/// Feather ignore all
    
draw_set_alpha(1);

var _strLen = string_length(str);

textboxHeight = 100;

// get textbox coordinates
var _textboxX1 = x;
var _textboxY1 = y;
var _textboxX2 = _textboxX1 + textboxWidth;
var _textboxY2 = _textboxY1 + textboxHeight;
var _textboxYCenter = mean(_textboxY1, _textboxY2);
var _mouseoverTextbox = point_in_rectangle(mouse_x, mouse_y, _textboxX1, _textboxY1, _textboxX2, _textboxY2);

if (mouse_check_button_pressed(mb_left)) {
    // click in textbox to focus it 
    if (!textboxFocused && _mouseoverTextbox) textboxFocused = true;
    // click out of textbox to unfocus it
    else if (textboxFocused && !_mouseoverTextbox) textboxFocused = false;
}

// draw textbox BG
draw_set_color(color_bg);
draw_rectangle(_textboxX1, _textboxY1, _textboxX2, _textboxY2, false);

// set gpu scissor to clip out anything drawn outside of textbox
var _scissor = gpu_get_scissor();
gpu_set_scissor(_textboxX1, _textboxY1, textboxWidth, textboxHeight);

// draw text
var _textXPadding = 4;
var _textTags = $"[fa_left][fa_middle][scale,2][fnt_textbox][d#{color_text}]";
var _textX = _textboxX1 + xOffset + _textXPadding;
var _textY = _textboxYCenter;
text = scribble($"{_textTags}{str}");
text.draw(_textX, _textboxYCenter);

// moving cursor with mouse click
if (mouse_check_button(mb_left) && textboxFocused) {
    
    // find character nearest to mouse
    var _posNearestToMouse = 0;
    var _minDistToMouse = 999999999;
    for (var i = 0; i <= _strLen; i++) {
        var _subStr = string_copy(str, 1, i);
        var _subText = scribble($"{_textTags}{_subStr}");
        var _subStrX = _textX + _subText.get_width();
        var distToMouse = point_distance(mouse_x, mouse_y, _subStrX, _textY);
        if (distToMouse < _minDistToMouse) {
            _minDistToMouse = distToMouse;
            _posNearestToMouse = i;
        }
    }
    
    // check to move cursor/highlight index
    if (mouse_check_button_pressed(mb_left)) {
        validDrag = _mouseoverTextbox;
        if (validDrag) highlightPos = _posNearestToMouse;
    }
    if (validDrag) cursorPos = _posNearestToMouse;
        
    acPercent_cursorAlpha = 1;
}

if (mouse_check_button_released(mb_left) && _mouseoverTextbox) {
    validDrag = true;
    
    // check for double click
    rapidClickCount++;
    time_source_reset(rapidClickCountTimer);
    time_source_start(rapidClickCountTimer);
    if (rapidClickCount == 2) {
        while (IsCharLetter(string_char_at(str, cursorPos)) && cursorPos < _strLen) cursorPos++;
        while (IsCharLetter(string_char_at(str, highlightPos)) && highlightPos > 0) highlightPos--;
        if (cursorPos < _strLen || !IsCharLetter(string_char_at(str, cursorPos))) cursorPos--;
    }
}

// determine cursor coordinates
var _strToCursor = string_copy(str, 1, cursorPos);
var _textCursor = scribble($"{_textTags}{_strToCursor}");
var _cursorX = _textX + _textCursor.get_width();

// keep cursor in view at all times
if (_cursorX + _textXPadding > _textboxX2) xOffset -= abs((_cursorX + _textXPadding) - _textboxX2);
else if (_cursorX - _textXPadding < _textboxX1) xOffset += abs((_cursorX - _textXPadding) - _textboxX1);
    
// possibly need to readjust after backspacing
if (backspaceReadjust) {
    var _readjustThresholdWidth = textboxWidth * 0.9;
    if (_cursorX < _textboxX1 + _readjustThresholdWidth && text.get_width() > _readjustThresholdWidth) {
        backspaceReadjust = false;
        xOffset += abs(_cursorX - (_textboxX1 + _readjustThresholdWidth));
    }
}

// get cursor alpha
var _acChannel_cursorAlpha = animcurve_get_channel(ac_cursorAlpha, 0);
var _cursorAlpha = animcurve_channel_evaluate(_acChannel_cursorAlpha, acPercent_cursorAlpha);
    
// draw cursor
var _cursorPadding = 6;
var _cursorY1 = _textboxY1 + _cursorPadding;
var _cursorY2 = _textboxY2 - _cursorPadding;
if (textboxFocused) {
    draw_set_alpha(_cursorAlpha >= 0.9 ? 1 : 0);
    draw_set_color(color_cursor);
    draw_line_width(_cursorX, _cursorY1, _cursorX, _cursorY2, 3);
    draw_set_alpha(1);
}

// determine highlight coordinates
var _strToHighlight = "";
var _textHighlight = undefined;
var _highlightX = 0;
if (cursorPos == highlightPos) {
    _strToHighlight = _strToCursor;
    _textHighlight = _textCursor;
    _highlightX = _cursorX;
}
else {
    _strToHighlight = string_copy(str, 1, highlightPos);
    _textHighlight = scribble($"{_textTags}{_strToHighlight}");
    _highlightX = _textX + _textHighlight.get_width();
}

// draw highlight rect
if (cursorPos != highlightPos) {
    var _highlightRectX1 = min(_cursorX, _highlightX);
    var _highlightRectY1 = _cursorY1;
    var _highlightRectX2 = max(_cursorX, _highlightX);
    var _highlightRectY2 = _cursorY2;
    draw_set_color(color_highlight);
    draw_set_alpha(0.6);
    draw_rectangle(_highlightRectX1, _highlightRectY1, _highlightRectX2, _highlightRectY2, false);
    draw_set_alpha(1);
}

// reset scissor so we can draw anywhere again
gpu_set_scissor(_scissor);

// draw textbox border
draw_set_color(color_border);
draw_rectangle(_textboxX1, _textboxY1, _textboxX2, _textboxY2, true);
if (textboxFocused) draw_rectangle(_textboxX1 - 1, _textboxY1 - 1, _textboxX2 + 1, _textboxY2 + 1, true);
