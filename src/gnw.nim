var
  framebuffer1 {.importc.}: array[320 * 240, cushort]
  framebuffer2 {.importc.}: array[320 * 240, cushort]
  active_framebuffer {.importc.}: cuint

proc lcd_backlight_set*(value: uint8) {.importc.}
proc lcd_backlight_on*() {.importc.}
proc lcd_backlight_off*() {.importc.}
proc lcd_swap*() {.importc.}
proc lcd_sync*() {.importc.}
proc lcd_get_active_framebuffer*(): ptr array[320 * 240, cushort] = 
  if active_framebuffer == 0: addr framebuffer1 else: addr framebuffer2
proc lcd_get_inactive_framebuffer*(): ptr array[320 * 240, cushort] = 
  if active_framebuffer != 0: addr framebuffer1 else: addr framebuffer2
proc lcd_reset_active_buffer*() {.importc.}

proc lcd_draw_text_8x8*(x, y: cint, text: cstring, color: uint16) {.importc.}
proc lcd_draw_text_6x6*(x, y: cint, text: cstring, color: uint16) {.importc.}

type
  Button* = enum
    Left, Up, Right, Down, A, B, Time, Game, Pause, Power

proc buttons_get(): cuint {.importc.}
proc button_pressed*(b: Button): bool =
  return (buttons_get() and (1 shl b.int).uint32) != 0'u32

proc GW_EnterDeepSleep*() {.importc.}
proc HAL_Delay*(d: uint32) {.importc.}
proc wdog_refresh*() {.importc.}

