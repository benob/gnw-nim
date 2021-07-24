import gnw

# simple example for running nim programs on the game an watch
# remember not to use dynamic allocations such as string contactenation or seqs

proc update() =
  let framebuffer = lcd_get_active_framebuffer()
  for i in 0 ..< 320 * 240:
    framebuffer[i] = 0'u16

  let names = ["left", "right", "up", "down", "A", "B", "time", "game", "pause", "power"]
  for i in 0 ..< names.len:
    if button_pressed(i.Button):
      lcd_draw_text_8x8(100, i.cint * 8, names[i].cstring, 0xfff)
  lcd_draw_text_8x8(20, 12 * 8, "Hello! press buttons", 0xf00)

proc app_main() {.exportc.} =
  lcd_backlight_set(255)

  while true:
    wdog_refresh()
    if button_pressed(Power):
      GW_EnterDeepSleep()
    update()
    lcd_swap()
    HAL_Delay(20)

