extends Node2D

var g = null


func _process(_d):
    queue_redraw()


func bar(f, x, y, v, c, label):
    draw_rect(Rect2(x, y, 190, 20), Color(0, 0, 0, 0.55))
    draw_rect(Rect2(x + 2, y + 2, 186.0 * clampf(v, 0.0, 100.0) / 100.0, 16), c)
    draw_string(f, Vector2(x + 8, y + 15), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)


func btn(f, c, r, col, label):
    draw_circle(c, r, col)
    draw_arc(c, r, 0, TAU, 32, Color(1, 1, 1, 0.5), 3.0)
    draw_string(f, Vector2(c.x - 60, c.y + 6), label, HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Color.WHITE)


func _draw():
    if g == null:
        return
    var f = ThemeDB.fallback_font
    var vs = get_viewport_rect().size
    var x0 = 56.0
    var y0 = 18.0
    bar(f, x0, y0, g.hp, Color(0.85, 0.2, 0.2), "Здоровье")
    bar(f, x0, y0 + 26, g.hunger, Color(0.9, 0.6, 0.2), "Сытость")
    bar(f, x0, y0 + 52, g.thirst, Color(0.25, 0.6, 0.9), "Жажда")
    bar(f, x0, y0 + 78, 100.0 - g.fat, Color(0.6, 0.5, 0.85), "Бодрость")
    var p = fmod(g.clock, g.DAY_LEN) / g.DAY_LEN
    var hr = fmod(6.0 + p * 24.0, 24.0)
    draw_string(f, Vector2(x0, y0 + 118), "День %d/30   %02d:%02d" % [mini(30, int(g.clock / g.DAY_LEN) + 1), int(hr), int(fmod(hr, 1.0) * 60.0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
    var w = g.ITEMS[g.wp]
    var wt = w["n"]
    if w["t"] == "gun":
        wt += "  патроны: %d" % g.inv.get("ammo", 0)
    elif w["dur"] > 0:
        wt += "  прочность: %d" % g.dur.get(g.wp, 0)
    draw_string(f, Vector2(x0, y0 + 144), wt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 0.9, 0.6))
    var yy = y0 + 170
    if g.bleed:
        draw_string(f, Vector2(x0, yy), "Кровотечение!", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 0.3, 0.3))
        yy += 24
    if g.weight() > g.CAP:
        draw_string(f, Vector2(x0, yy), "Перегруз", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 0.7, 0.3))
        yy += 24
    if g.sleeping:
        draw_string(f, Vector2(0, vs.y * 0.4), "Сон...", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 40, Color(0.7, 0.8, 1))
    # messages
    var my = 40.0
    for m in g.msgs:
        draw_string(f, Vector2(0, my), m["s"], HORIZONTAL_ALIGNMENT_CENTER, vs.x, 22, Color(1, 1, 1, clampf(m["t"], 0.0, 1.0)))
        my += 28.0
    # search progress
    if g.searching != null:
        var c = Vector2(vs.x / 2, vs.y / 2 - 80)
        draw_rect(Rect2(c.x - 70, c.y, 140, 12), Color(0, 0, 0, 0.6))
        draw_rect(Rect2(c.x - 68, c.y + 2, 136.0 * g.search_t / 1.5, 8), Color(1, 0.85, 0.2))
    # damage flash
    if g.flash > 0:
        draw_rect(Rect2(Vector2.ZERO, vs), Color(0.8, 0, 0, g.flash * 0.6))
    # buttons
    var L = g.ui_layout()
    btn(f, L["atk"], 64, Color(0.65, 0.15, 0.15, 0.5), "УДАР")
    btn(f, L["act"], 48, Color(0.2, 0.2, 0.2, 0.55), g.act_label())
    btn(f, L["menu"], 44, Color(0.2, 0.2, 0.2, 0.55), "РЮКЗАК")
    if g.joy_idx != -1:
        draw_circle(g.joy_o, 60, Color(1, 1, 1, 0.1))
        draw_arc(g.joy_o, 60, 0, TAU, 32, Color(1, 1, 1, 0.4), 3.0)
        draw_circle(g.joy_p, 26, Color(1, 1, 1, 0.35))
    # minimap
    var s = 130.0 / g.WS
    var mp = Vector2(vs.x - 150, 18)
    draw_rect(Rect2(mp, Vector2(130, 130)), Color(0, 0, 0, 0.55))
    for tc in g.towns:
        draw_rect(Rect2(mp + (tc - Vector2(650, 420)) * s, Vector2(1300, 840) * s), Color(0.5, 0.5, 0.5, 0.6))
    draw_circle(mp + g.pos * s, 3.5, Color(0.3, 1, 0.5))
