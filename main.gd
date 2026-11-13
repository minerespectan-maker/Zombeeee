extends Node2D

const WS = 4200.0
const DAY_LEN = 240.0
const CAP = 25.0
const GRID = 32.0

const ITEMS = {
    "fist": {"n": "Кулаки", "t": "melee", "d": 5.0, "r": 38.0, "cd": 0.45, "noise": 50.0, "dur": -1, "w": 0.0},
    "leg": {"n": "Ножка стула", "t": "melee", "d": 10.0, "r": 48.0, "cd": 0.45, "noise": 70.0, "dur": 40, "w": 0.8},
    "fork": {"n": "Вилка", "t": "melee", "d": 7.0, "r": 34.0, "cd": 0.3, "noise": 40.0, "dur": 25, "w": 0.1},
    "knife": {"n": "Нож", "t": "melee", "d": 13.0, "r": 40.0, "cd": 0.3, "noise": 45.0, "dur": 60, "w": 0.3},
    "bat": {"n": "Бита", "t": "melee", "d": 20.0, "r": 60.0, "cd": 0.6, "noise": 90.0, "dur": 80, "w": 1.5},
    "sword": {"n": "Меч", "t": "melee", "d": 30.0, "r": 68.0, "cd": 0.55, "noise": 80.0, "dur": 120, "w": 2.0},
    "katana": {"n": "Катана", "t": "melee", "d": 44.0, "r": 72.0, "cd": 0.4, "noise": 60.0, "dur": 150, "w": 1.5},
    "pistol": {"n": "Пистолет", "t": "gun", "d": 28.0, "r": 520.0, "cd": 0.4, "noise": 600.0, "w": 1.0},
    "ak": {"n": "Автомат", "t": "gun", "d": 22.0, "r": 640.0, "cd": 0.1, "noise": 900.0, "w": 3.5},
    "canned": {"n": "Консервы", "t": "food", "v": 35.0, "w": 0.5},
    "bread": {"n": "Хлеб", "t": "food", "v": 22.0, "w": 0.3},
    "apple": {"n": "Яблоко", "t": "food", "v": 12.0, "w": 0.2},
    "water": {"n": "Вода", "t": "drink", "v": 40.0, "w": 0.5},
    "soda": {"n": "Газировка", "t": "drink", "v": 25.0, "w": 0.4},
    "bandage": {"n": "Бинт", "t": "med", "v": 15.0, "w": 0.1},
    "medkit": {"n": "Аптечка", "t": "med", "v": 60.0, "w": 0.6},
    "pills": {"n": "Бодрящие таблетки", "t": "energy", "v": 40.0, "w": 0.1},
    "wood": {"n": "Доски", "t": "mat", "w": 1.0},
    "metal": {"n": "Металлолом", "t": "mat", "w": 1.0},
    "ammo": {"n": "Патроны", "t": "ammo", "w": 0.05},
}
const LOOT = {
    "fridge": [["canned", 3], ["bread", 3], ["apple", 3], ["water", 3], ["soda", 2]],
    "shelf": [["wood", 3], ["metal", 3], ["ammo", 2], ["canned", 1], ["knife", 1], ["leg", 1], ["bat", 1], ["fork", 2]],
    "cabinet": [["bandage", 3], ["medkit", 1], ["pills", 2], ["water", 1]],
    "wardrobe": [["fork", 2], ["knife", 1], ["sword", 1], ["katana", 0.5], ["pistol", 1], ["ak", 0.5], ["ammo", 2], ["bread", 1]],
}
const BUILD = {
    "wall": {"n": "Деревянная стена", "cost": {"wood": 3}, "hp": 220.0},
    "fire": {"n": "Костёр (свет и лечение)", "cost": {"wood": 4}, "hp": 120.0},
}

var ZT = [
    {"n": "Ходок", "hp": 40.0, "sp": 60.0, "dm": 8.0, "r": 11.0, "c": Color(0.42, 0.56, 0.35)},
    {"n": "Бегун", "hp": 25.0, "sp": 125.0, "dm": 6.0, "r": 10.0, "c": Color(0.7, 0.72, 0.3)},
    {"n": "Толстяк", "hp": 150.0, "sp": 48.0, "dm": 20.0, "r": 17.0, "c": Color(0.55, 0.3, 0.3)},
    {"n": "Бронированный", "hp": 95.0, "sp": 65.0, "dm": 14.0, "r": 12.0, "c": Color(0.36, 0.4, 0.48)},
]

class Zed:
    var pos = Vector2.ZERO
    var face = Vector2.RIGHT
    var tgt = Vector2.ZERO
    var hp = 40.0
    var k = 0
    var st = 0
    var t = 0.0
    var cd = 0.0
    var wa = -1.0
    var bl = 0.0
    var bd = 1.0
    var ht = 0.0
    var lost = 0.0
    var ph = 0.0

var rng = RandomNumberGenerator.new()
var houses = []
var towns = [Vector2(900, 900), Vector2(3300, 900), Vector2(900, 3300), Vector2(3300, 3300), Vector2(2100, 2000)]
var roads = []
var grass = PackedVector2Array()
var trees = PackedVector2Array()
var built = []
var zeds = []
var blood = []
var tracers = []
var msgs = []

var pos = Vector2(2100, 2700)
var face = Vector2.RIGHT
var hp = 100.0
var hunger = 80.0
var thirst = 80.0
var fat = 10.0
var bleed = false
var inv = {"canned": 2, "water": 2, "bandage": 1, "wood": 6, "leg": 1}
var dur = {"leg": 40}
var wp = "leg"
var clock = 0.0
var last_day = 1
var kills = 0
var over = false
var paused = false
var sleeping = false
var atk_cd = 0.0
var swing = 0.0
var swing_a = 0.0
var flash = 0.0
var searching = null
var search_t = 0.0
var joy_idx = -1
var joy_o = Vector2.ZERO
var joy_p = Vector2.ZERO
var joy_v = Vector2.ZERO
var atk_idx = -1
var attacking = false
var noise_t = 0.0
var spawn_t = 3.0
var dark = 0.0
var tm = 0.0
var cam
var cmod
var plight
var light_tex
var panel
var pbox


func _ready():
    rng.randomize()
    for tc in towns:
        for i in 3:
            for j in 2:
                var w = rng.randf_range(270, 320)
                var h = rng.randf_range(200, 250)
                make_house(tc.x - 570 + i * 380 + rng.randf_range(0, 30), tc.y - 330 + j * 330 + rng.randf_range(0, 30), w, h)
    for i in 4:
        roads.append([towns[i], towns[4]])
    roads.append([towns[4], Vector2(2100, 2800)])
    for i in 1800:
        grass.append(Vector2(rng.randf() * WS, rng.randf() * WS))
    for i in 280:
        var p = Vector2(rng.randf_range(40, WS - 40), rng.randf_range(40, WS - 40))
        if not near_town(p) and p.distance_to(pos) > 200 and not on_road(p):
            trees.append(p)
    # zombies: inside some houses and on the streets
    for h in houses:
        if rng.randf() < 0.35:
            var r = h["r"]
            for n in rng.randi_range(1, 3):
                spawn_z(Vector2(rng.randf_range(r.position.x + 30, r.end.x - 30), rng.randf_range(r.position.y + 30, r.end.y - 30)))
    for tc in towns:
        for i in 5:
            spawn_z(tc + Vector2(rng.randf_range(-600, 600), rng.randf_range(-380, 380)))
    cam = Camera2D.new()
    cam.position_smoothing_enabled = true
    cam.zoom = Vector2(1.1, 1.1)
    add_child(cam)
    cam.make_current()
    cmod = CanvasModulate.new()
    add_child(cmod)
    light_tex = make_light_tex()
    plight = PointLight2D.new()
    plight.texture = light_tex
    plight.texture_scale = 2.4
    plight.color = Color(1.0, 0.95, 0.8)
    add_child(plight)
    var hl = CanvasLayer.new()
    hl.layer = 5
    add_child(hl)
    var hud = Node2D.new()
    hud.set_script(load("res://hud.gd"))
    hud.set("g", self)
    hl.add_child(hud)
    var pl = CanvasLayer.new()
    pl.layer = 10
    add_child(pl)
    panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    var sb = StyleBoxFlat.new()
    sb.bg_color = Color(0.05, 0.07, 0.05, 0.95)
    sb.content_margin_left = 60
    sb.content_margin_right = 60
    sb.content_margin_top = 24
    sb.content_margin_bottom = 24
    panel.add_theme_stylebox_override("panel", sb)
    panel.visible = false
    pl.add_child(panel)
    var sc = ScrollContainer.new()
    panel.add_child(sc)
    pbox = VBoxContainer.new()
    pbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    sc.add_child(pbox)
    msg("Обыскивай дома, строй базу, продержись 30 дней!")


func make_light_tex():
    var g = Gradient.new()
    g.set_color(0, Color(1, 1, 1, 1))
    g.set_color(1, Color(1, 1, 1, 0))
    var t = GradientTexture2D.new()
    t.gradient = g
    t.fill = GradientTexture2D.FILL_RADIAL
    t.fill_from = Vector2(0.5, 0.5)
    t.fill_to = Vector2(1.0, 0.5)
    t.width = 256
    t.height = 256
    return t


func near_town(p):
    for tc in towns:
        if Rect2(tc - Vector2(650, 420), Vector2(1300, 840)).has_point(p):
            return true
    return false


func on_road(p):
    for r in roads:
        if Geometry2D.get_closest_point_to_segment(p, r[0], r[1]).distance_to(p) < 90:
            return true
    return false


func make_house(x, y, w, h):
    var t = 8.0
    var dx = x + rng.randf_range(50, w - 110)
    var walls = [Rect2(x, y, w, t), Rect2(x, y, t, h), Rect2(x + w - t, y, t, h), Rect2(x, y + h - t, dx - x, t), Rect2(dx + 52, y + h - t, x + w - dx - 52, t)]
    var px = x + w * 0.55
    var gy = y + h * 0.3 + rng.randf() * h * 0.25
    walls.append(Rect2(px - t / 2, y, t, gy - y))
    walls.append(Rect2(px - t / 2, gy + 52, t, y + h - (gy + 52)))
    var solid = walls.duplicate()
    var furn = []
    var kinds = ["bed", "fridge", "shelf", "cabinet", "wardrobe"]
    var tries = 0
    while furn.size() < 5 and tries < 80:
        tries += 1
        var p = Vector2(rng.randf_range(x + t + 26, x + w - t - 26), rng.randf_range(y + t + 22, y + h - t - 40))
        if absf(p.x - px) < 38:
            continue
        if p.y > y + h - 95 and absf(p.x - (dx + 26)) < 75:
            continue
        var ok = true
        for f in furn:
            if f["p"].distance_to(p) < 58:
                ok = false
        if not ok:
            continue
        furn.append({"p": p, "k": kinds[furn.size()], "done": false})
        solid.append(Rect2(p - Vector2(15, 11), Vector2(30, 22)))
    var roofs = [Color(0.45, 0.2, 0.18), Color(0.28, 0.33, 0.4), Color(0.35, 0.3, 0.22), Color(0.3, 0.36, 0.27)]
    var floors = [Color(0.5, 0.36, 0.22), Color(0.42, 0.33, 0.25), Color(0.55, 0.45, 0.3)]
    houses.append({"r": Rect2(x, y, w, h), "walls": walls, "solid": solid, "furn": furn, "roof": 1.0, "col": roofs[rng.randi() % roofs.size()], "fl": floors[rng.randi() % floors.size()]})


func house_idx(p):
    for i in houses.size():
        if houses[i]["r"].has_point(p):
            return i
    return -1


func push(p, rc, r):
    var c = Vector2(clampf(p.x, rc.position.x, rc.end.x), clampf(p.y, rc.position.y, rc.end.y))
    var d = p - c
    var l = d.length()
    if l < r:
        if l < 0.001:
            return p + Vector2(0, r)
        return c + d / l * r
    return p


func collide(p, r):
    for it in 2:
        for h in houses:
            if not h["r"].grow(r + 4).has_point(p):
                continue
            for s in h["solid"]:
                p = push(p, s, r)
        for b in built:
            p = push(p, b["rect"], r)
    return p


func spawn_z(p):
    var d = int(clock / DAY_LEN) + 1
    var r = rng.randf()
    var k = 0
    if d >= 12 and r < 0.1:
        k = 3
    elif d >= 8 and r < 0.22:
        k = 2
    elif d >= 4 and r < 0.45:
        k = 1
    var z = Zed.new()
    z.pos = p.clamp(Vector2(20, 20), Vector2(WS - 20, WS - 20))
    z.k = k
    z.hp = ZT[k]["hp"]
    z.ph = rng.randf() * 6.28
    z.wa = rng.randf() * TAU
    zeds.append(z)


func msg(s):
    msgs.append({"s": s, "t": 4.5})
    if msgs.size() > 5:
        msgs.pop_front()


func weight():
    var w = 0.0
    for id in inv:
        w += ITEMS[id]["w"] * inv[id]
    return w


func take(id, n = 1):
    inv[id] = inv.get(id, 0) - n
    if inv[id] <= 0:
        inv.erase(id)
        if wp == id:
            wp = "fist"


func near_fire():
    for b in built:
        if b["t"] == "fire" and b["rect"].get_center().distance_to(pos) < 150:
            return true
    return false


func ui_layout():
    var vs = get_viewport_rect().size
    return {"atk": Vector2(vs.x - 110, vs.y - 110), "act": Vector2(vs.x - 250, vs.y - 80), "menu": Vector2(vs.x - 110, vs.y - 260)}


func act_label():
    var f = find_furn()
    if f == null:
        return "ДЕЙСТВИЕ"
    if f["k"] == "bed":
        return "СПАТЬ"
    return "ПУСТО" if f["done"] else "ОБЫСК"


func _input(ev):
    if over or paused:
        return
    if ev is InputEventScreenTouch:
        var L = ui_layout()
        var vs = get_viewport_rect().size
        if ev.pressed:
            if ev.position.distance_to(L["atk"]) < 75:
                atk_idx = ev.index
                attacking = true
            elif ev.position.distance_to(L["act"]) < 55:
                do_action()
            elif ev.position.distance_to(L["menu"]) < 50:
                open_panel()
            elif ev.position.x < vs.x * 0.5 and joy_idx == -1:
                joy_idx = ev.index
                joy_o = ev.position
                joy_p = ev.position
                joy_v = Vector2.ZERO
        else:
            if ev.index == joy_idx:
                joy_idx = -1
                joy_v = Vector2.ZERO
            if ev.index == atk_idx:
                atk_idx = -1
                attacking = false
    elif ev is InputEventScreenDrag and ev.index == joy_idx:
        var d = ev.position - joy_o
        var l = d.length()
        joy_v = d / maxf(l, 1.0) * minf(1.0, l / 60.0)
        joy_p = joy_o + joy_v * 60.0
    elif ev is InputEventKey and ev.pressed and not ev.echo:
        if ev.keycode == KEY_E:
            do_action()
        elif ev.keycode == KEY_I:
            open_panel()


func _process(delta):
    tm = Time.get_ticks_msec() / 1000.0
    cam.position = pos
    plight.position = pos
    for m in msgs:
        m["t"] -= delta
    msgs = msgs.filter(func(m): return m["t"] > 0)
    if over or paused:
        queue_redraw()
        return
    var ts = 12.0 if sleeping else 1.0
    var dts = delta * ts
    clock += dts
    var day = int(clock / DAY_LEN) + 1
    if day > last_day:
        new_day(day)
    if clock >= 30.0 * DAY_LEN:
        end_game(true)
        return
    var p = fmod(clock, DAY_LEN) / DAY_LEN
    if p < 0.55:
        dark = 0.0
    elif p < 0.65:
        dark = (p - 0.55) * 10.0
    elif p < 0.9:
        dark = 1.0
    else:
        dark = (1.0 - p) * 10.0
    cmod.color = Color.WHITE.lerp(Color(0.1, 0.12, 0.26), dark)
    plight.energy = 0.15 + dark * 1.0
    # movement
    var d = joy_v
    var kd = Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        kd.x -= 1
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        kd.x += 1
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        kd.y -= 1
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        kd.y += 1
    if kd.length() > 0:
        d = kd.normalized()
    var moving = d.length() > 0.1
    var firing = attacking or Input.is_key_pressed(KEY_SPACE)
    if sleeping and (moving or firing):
        sleeping = false
        msg("Проснулся")
    if moving and not sleeping:
        face = d.normalized()
        var sp = 150.0 * (1.0 - 0.4 * clampf((fat - 60.0) / 40.0, 0.0, 1.0))
        if weight() > CAP:
            sp *= 0.65
        pos = collide(pos + d * sp * delta, 10.0)
        pos = pos.clamp(Vector2(20, 20), Vector2(WS - 20, WS - 20))
        if searching != null:
            searching = null
            msg("Поиск прерван")
    # needs
    hunger = maxf(0.0, hunger - 0.17 * dts)
    thirst = maxf(0.0, thirst - 0.25 * dts)
    if sleeping:
        fat = maxf(0.0, fat - 6.0 * delta)
        if fat <= 0.0 or bleed or hunger <= 0.0 or thirst <= 0.0:
            sleeping = false
            msg("Проснулся")
        for z in zeds:
            if z.pos.distance_to(pos) < 350:
                sleeping = false
                msg("Зомби рядом!")
                break
    else:
        fat = minf(100.0, fat + 0.12 * delta)
    if bleed:
        hp -= 0.8 * dts
    if hunger <= 0.0 or thirst <= 0.0 or fat >= 100.0:
        hp -= 1.2 * dts
    elif hunger > 40.0 and thirst > 40.0 and not bleed:
        hp = minf(100.0, hp + (1.8 if near_fire() else 0.15) * dts)
    if hp <= 0.0:
        end_game(false)
        return
    # search
    if searching != null:
        search_t += delta
        if search_t >= 1.5:
            finish_search()
    # attack
    atk_cd -= delta
    if firing and atk_cd <= 0.0 and not sleeping:
        do_attack()
    swing = maxf(0.0, swing - delta)
    flash = maxf(0.0, flash - delta)
    # noise
    noise_t -= delta
    if noise_t <= 0.0:
        noise_t = 0.4
        make_noise(pos, 80.0 if moving else 25.0)
    update_zeds(delta)
    # spawn
    spawn_t -= delta
    if spawn_t <= 0.0:
        var night = dark > 0.5
        spawn_t = (0.7 if day % 5 == 0 else 1.6) if night else 4.0
        var cap = minf(70.0, 25.0 + day * 1.6) + (15.0 if night else 0.0)
        if zeds.size() < cap:
            for tries in 10:
                var sp2 = pos + Vector2.RIGHT.rotated(rng.randf() * TAU) * rng.randf_range(550, 800)
                if sp2.x > 20 and sp2.y > 20 and sp2.x < WS - 20 and sp2.y < WS - 20 and house_idx(sp2) < 0:
                    spawn_z(sp2)
                    break
        elif zeds.size() > cap + 5:
            zeds = zeds.filter(func(z): return z.pos.distance_to(pos) < 1800)
    # structures
    var dead = false
    for b in built:
        if b["hp"] <= 0:
            dead = true
            if b["light"] != null:
                b["light"].queue_free()
    if dead:
        built = built.filter(func(b): return b["hp"] > 0)
    # roofs, fx
    var hi = house_idx(pos)
    for i in houses.size():
        houses[i]["roof"] = move_toward(houses[i]["roof"], 0.0 if i == hi else 1.0, delta * 4.0)
    for b in blood:
        b["t"] -= delta
    blood = blood.filter(func(b): return b["t"] > 0)
    for t in tracers:
        t["t"] -= delta
    tracers = tracers.filter(func(t): return t["t"] > 0)
    queue_redraw()


func update_zeds(delta):
    var pi = house_idx(pos)
    var sight = 300.0 - 140.0 * dark
    for z in zeds:
        var T = ZT[z.k]
        z.cd -= delta
        z.ht -= delta
        z.bl -= delta
        var dd = z.pos.distance_to(pos)
        var s = sight
        if house_idx(z.pos) != pi:
            s *= 0.45
        if dd < s:
            z.st = 2
            z.lost = 0.0
        elif z.st == 2:
            z.lost += delta
            if z.lost > 5.0:
                z.st = 0
        var dir = Vector2.ZERO
        var spd = T["sp"]
        if z.st == 2:
            dir = (pos - z.pos).normalized()
        elif z.st == 1:
            if z.pos.distance_to(z.tgt) < 25:
                z.st = 0
            else:
                dir = (z.tgt - z.pos).normalized()
                spd *= 0.7
        else:
            z.t -= delta
            if z.t <= 0:
                z.t = rng.randf_range(1, 4)
                z.wa = rng.randf() * TAU if rng.randf() < 0.6 else -1.0
            if z.wa >= 0:
                dir = Vector2.RIGHT.rotated(z.wa)
                spd *= 0.3
        if dir != Vector2.ZERO:
            if z.bl > 0:
                dir = dir.rotated(z.bd)
            var np = z.pos + dir * spd * delta
            var cp = collide(np, T["r"])
            if cp.distance_to(np) > spd * delta * 0.5 and z.bl <= 0:
                z.bl = 0.7
                z.bd = 1.4 if rng.randf() < 0.5 else -1.4
            z.pos = cp
            z.face = dir
        for b in built:
            if b["rect"].grow(T["r"] + 3).has_point(z.pos):
                b["hp"] -= T["dm"] * delta * 1.5
        if dd < T["r"] + 14 and z.cd <= 0:
            z.cd = 1.1
            hp -= T["dm"]
            flash = 0.35
            if sleeping:
                sleeping = false
            if not bleed and rng.randf() < 0.3:
                bleed = true
                msg("Кровотечение! Нужен бинт")
    for i in zeds.size():
        for j in range(i + 1, zeds.size()):
            var a = zeds[i]
            var b = zeds[j]
            var dv = b.pos - a.pos
            var l = dv.length()
            if l < 20 and l > 0.01:
                var f = (20 - l) / 2.0 / l
                a.pos -= dv * f
                b.pos += dv * f


func make_noise(p, r):
    for z in zeds:
        if z.st != 2 and z.pos.distance_to(p) < r:
            z.st = 1
            z.tgt = p


func hurt(z, d):
    if z.k == 3:
        d *= 0.6
    z.hp -= d
    z.ht = 0.1
    z.st = 2
    z.lost = 0.0
    z.pos += (z.pos - pos).normalized() * (3.0 if z.k == 2 else 10.0)
    for i in 2:
        blood.append({"p": z.pos + Vector2(rng.randf_range(-9, 9), rng.randf_range(-9, 9)), "t": 25.0, "r": rng.randf_range(2, 5)})
    if blood.size() > 160:
        blood.pop_front()
    if z.hp <= 0:
        zeds.erase(z)
        kills += 1
        blood.append({"p": z.pos, "t": 40.0, "r": 12.0})


func do_attack():
    var w = ITEMS[wp]
    atk_cd = w["cd"]
    var best = null
    var bd = 99999.0
    var reach = w["r"] + (70.0 if w["t"] == "melee" else 0.0)
    for z in zeds:
        var d = z.pos.distance_to(pos)
        if d < bd and d < reach:
            bd = d
            best = z
    if best != null:
        face = (best.pos - pos).normalized()
    if w["t"] == "gun":
        if best == null:
            atk_cd = 0.15
            return
        if inv.get("ammo", 0) <= 0:
            msg("Нет патронов")
            atk_cd = 0.6
            return
        take("ammo")
        tracers.append({"a": pos + face * 16, "b": best.pos, "t": 0.07})
        make_noise(pos, w["noise"])
        hurt(best, w["d"])
        return
    swing = 0.18
    swing_a = face.angle()
    make_noise(pos, w["noise"])
    for z in zeds.duplicate():
        var dv = z.pos - pos
        if dv.length() < w["r"] + ZT[z.k]["r"] and absf(angle_difference(face.angle(), dv.angle())) < 1.1:
            hurt(z, w["d"])
    if w["dur"] > 0:
        dur[wp] = dur.get(wp, w["dur"]) - 1
        if dur[wp] <= 0:
            msg(w["n"] + " сломалась")
            dur.erase(wp)
            take(wp)
            wp = "fist"


func find_furn():
    for h in houses:
        if not h["r"].grow(10).has_point(pos):
            continue
        for f in h["furn"]:
            if f["p"].distance_to(pos) < 46:
                return f
    return null


func do_action():
    if paused or over:
        return
    var f = find_furn()
    if f != null:
        if f["k"] == "bed":
            if sleeping:
                sleeping = false
                return
            if fat < 25.0:
                msg("Не хочется спать")
                return
            for z in zeds:
                if z.pos.distance_to(pos) < 450:
                    msg("Рядом зомби — не уснуть")
                    return
            sleeping = true
            msg("Сон...")
            return
        if f["done"]:
            msg("Здесь пусто")
            return
        searching = f
        search_t = 0.0
        make_noise(pos, 110)
        msg("Обыск...")
        return
    for b in built:
        if b["t"] == "wall" and b["hp"] < b["m"] and b["rect"].get_center().distance_to(pos) < 65 and inv.get("wood", 0) > 0:
            take("wood")
            b["hp"] = minf(b["m"], b["hp"] + 80.0)
            msg("Стена починена")
            return
    msg("Рядом ничего нет")


func wpick(list):
    var s = 0.0
    for a in list:
        s += a[1]
    var r = rng.randf() * s
    for a in list:
        r -= a[1]
        if r <= 0:
            return a[0]
    return list[0][0]


func finish_search():
    var f = searching
    searching = null
    f["done"] = true
    var got = []
    for i in rng.randi_range(1, 3):
        var id = wpick(LOOT[f["k"]])
        var it = ITEMS[id]
        if id == "ammo":
            var n = rng.randi_range(6, 12)
            inv["ammo"] = inv.get("ammo", 0) + n
            got.append("Патроны x%d" % n)
            continue
        if it["t"] == "gun" and not inv.has(id):
            inv["ammo"] = inv.get("ammo", 0) + 10
        inv[id] = inv.get(id, 0) + 1
        if it.has("dur") and it["dur"] > 0 and not dur.has(id):
            dur[id] = it["dur"]
        got.append(it["n"])
    msg("Найдено: " + ", ".join(got))


func new_day(day):
    last_day = day
    for h in houses:
        for f in h["furn"]:
            if f["done"] and f["k"] != "bed" and rng.randf() < 0.3:
                f["done"] = false
    msg("День %d" % day + (" — ночью будет орда!" if day % 5 == 0 else ""))


func build(kind):
    var c = BUILD[kind]["cost"]
    for k in c:
        if inv.get(k, 0) < c[k]:
            msg("Не хватает: " + ITEMS[k]["n"])
            return
    var bp = Vector2(floor((pos.x + face.x * 48.0) / GRID), floor((pos.y + face.y * 48.0) / GRID)) * GRID
    var rc = Rect2(bp, Vector2(GRID, GRID))
    for h in houses:
        for s in h["solid"]:
            if s.intersects(rc):
                msg("Тут нельзя строить")
                return
    for b in built:
        if b["rect"].intersects(rc):
            msg("Тут уже занято")
            return
    if Rect2(pos - Vector2(12, 12), Vector2(24, 24)).intersects(rc):
        msg("Отойдите немного")
        return
    for k in c:
        take(k, c[k])
    var hpv = BUILD[kind]["hp"]
    var e = {"rect": rc, "t": kind, "hp": hpv, "m": hpv, "light": null}
    if kind == "fire":
        var L = PointLight2D.new()
        L.texture = light_tex
        L.texture_scale = 1.8
        L.color = Color(1.0, 0.65, 0.3)
        L.energy = 1.3
        L.position = rc.get_center()
        add_child(L)
        e["light"] = L
    built.append(e)
    make_noise(pos, 160)
    close_panel()
    msg(BUILD[kind]["n"] + " построено")


func end_game(win):
    over = true
    searching = null
    panel.visible = true
    clear_panel()
    add_lbl("Вы выжили 30 дней!" if win else "Вы погибли")
    add_lbl("День %d, убито зомби: %d" % [mini(30, int(clock / DAY_LEN) + 1), kills])
    add_btn("Играть заново", func(): get_tree().reload_current_scene())


func open_panel():
    if over:
        return
    paused = true
    attacking = false
    joy_idx = -1
    joy_v = Vector2.ZERO
    panel.visible = true
    refresh_panel()


func close_panel():
    paused = false
    panel.visible = false


func clear_panel():
    for c in pbox.get_children():
        pbox.remove_child(c)
        c.queue_free()


func add_btn(txt, cb, on = false):
    var b = Button.new()
    b.text = ("> " if on else "") + txt
    b.add_theme_font_size_override("font_size", 26)
    b.custom_minimum_size = Vector2(0, 62)
    b.pressed.connect(cb)
    pbox.add_child(b)


func add_lbl(txt):
    var l = Label.new()
    l.text = txt
    l.add_theme_font_size_override("font_size", 30)
    l.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
    pbox.add_child(l)


func refresh_panel():
    clear_panel()
    add_btn("Закрыть", close_panel)
    add_lbl("Рюкзак  %.1f / %.0f кг" % [weight(), CAP])
    add_btn("Кулаки — в руки", equip.bind("fist"), wp == "fist")
    for id in inv:
        var it = ITEMS[id]
        var n = inv[id]
        match it["t"]:
            "food", "drink", "med", "energy":
                add_btn("%s x%d — использовать" % [it["n"], n], use_item.bind(id))
            "melee", "gun":
                var extra = (" (прочн. %d)" % dur.get(id, 0)) if it["t"] == "melee" else ""
                add_btn("%s x%d%s — в руки" % [it["n"], n, extra], equip.bind(id), wp == id)
            _:
                add_btn("%s x%d" % [it["n"], n], refresh_panel)
    add_lbl("Построить (перед собой)")
    for k in BUILD:
        var cs = []
        for i in BUILD[k]["cost"]:
            cs.append("%s %d" % [ITEMS[i]["n"], BUILD[k]["cost"][i]])
        add_btn("%s — %s" % [BUILD[k]["n"], ", ".join(cs)], build.bind(k))


func equip(id):
    wp = id
    refresh_panel()


func use_item(id):
    var it = ITEMS[id]
    match it["t"]:
        "food":
            hunger = minf(100.0, hunger + it["v"])
        "drink":
            thirst = minf(100.0, thirst + it["v"])
        "med":
            hp = minf(100.0, hp + it["v"])
            if id == "bandage" or id == "medkit":
                bleed = false
        "energy":
            fat = maxf(0.0, fat - it["v"])
    take(id)
    refresh_panel()


# ---------------------------------------------------------------- drawing

func shadow(p, r):
    draw_set_transform(p + Vector2(0, r * 0.5), 0.0, Vector2(1.0, 0.5))
    draw_circle(Vector2.ZERO, r * 1.1, Color(0, 0, 0, 0.3))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw():
    var vs = get_viewport_rect().size / cam.zoom.x
    var vr = Rect2(pos - vs / 2 - Vector2(140, 140), vs + Vector2(280, 280))
    draw_rect(Rect2(0, 0, WS, WS), Color(0.2, 0.33, 0.17))
    for g in grass:
        if vr.has_point(g):
            draw_line(g, g + Vector2(2, -6), Color(0.27, 0.42, 0.22), 2.0)
    for r in roads:
        draw_line(r[0], r[1], Color(0.16, 0.17, 0.18), 90.0)
        draw_dashed_line(r[0], r[1], Color(0.75, 0.7, 0.3, 0.6), 3.0, 18.0)
    for tc in towns:
        draw_rect(Rect2(tc - Vector2(650, 420), Vector2(1300, 840)), Color(0.23, 0.24, 0.25))
    for tp in trees:
        if vr.has_point(tp):
            shadow(tp + Vector2(6, 8), 26)
            draw_circle(tp, 28, Color(0.1, 0.25, 0.1))
            draw_circle(tp + Vector2(-5, -5), 20, Color(0.15, 0.34, 0.14))
            draw_circle(tp + Vector2(-8, -9), 9, Color(0.2, 0.42, 0.18))
    for b in blood:
        if vr.has_point(b["p"]):
            draw_circle(b["p"], b["r"], Color(0.4, 0.0, 0.0, clampf(b["t"] / 10.0, 0.0, 0.7)))
    for h in houses:
        var r = h["r"]
        if not vr.intersects(r):
            continue
        draw_rect(r, h["fl"])
        var yy = r.position.y + 22
        while yy < r.end.y:
            draw_line(Vector2(r.position.x, yy), Vector2(r.end.x, yy), h["fl"].darkened(0.25), 1.0)
            yy += 22
        for f in h["furn"]:
            draw_furn(f)
        for w in h["walls"]:
            draw_rect(w, Color(0.17, 0.12, 0.09))
            draw_rect(w, Color(0.36, 0.27, 0.2), false, 1.5)
    for b in built:
        var rc = b["rect"]
        if not vr.intersects(rc):
            continue
        if b["t"] == "wall":
            var c = Color(0.5, 0.33, 0.17).lerp(Color(0.2, 0.1, 0.05), 1.0 - b["hp"] / b["m"])
            draw_rect(rc, c)
            draw_rect(rc, Color(0.15, 0.08, 0.04), false, 2.0)
            draw_line(rc.position + Vector2(0, 16), rc.position + Vector2(32, 16), Color(0.15, 0.08, 0.04), 1.5)
        else:
            var ce = rc.get_center()
            draw_circle(ce, 11, Color(0.2, 0.12, 0.08))
            draw_circle(ce + Vector2(0, -2), 6 + sin(tm * 12.0) * 1.5, Color(1.0, 0.55, 0.1))
            draw_circle(ce + Vector2(0, -3), 3 + sin(tm * 17.0), Color(1.0, 0.9, 0.4))
    for z in zeds:
        if vr.has_point(z.pos):
            draw_zed(z)
    draw_player()
    for t in tracers:
        draw_line(t["a"], t["b"], Color(1.0, 0.9, 0.5), 2.5)
    for h in houses:
        if h["roof"] > 0.02 and vr.intersects(h["r"]):
            var r = h["r"].grow(6)
            var a = h["roof"]
            draw_rect(Rect2(r.position + Vector2(4, 6), r.size), Color(0, 0, 0, 0.3 * a))
            draw_rect(r, Color(h["col"], a))
            var x = r.position.x + 18
            while x < r.end.x:
                draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color(0, 0, 0, 0.18 * a), 2.0)
                x += 18
            draw_rect(r, Color(h["col"].darkened(0.5), a), false, 3.0)


func draw_furn(f):
    var p = f["p"]
    var r = Rect2(p - Vector2(15, 11), Vector2(30, 22))
    var c = Color(0.6, 0.45, 0.3)
    match f["k"]:
        "fridge":
            c = Color(0.85, 0.88, 0.9)
        "shelf":
            c = Color(0.5, 0.35, 0.2)
        "cabinet":
            c = Color(0.9, 0.9, 0.85)
        "wardrobe":
            c = Color(0.4, 0.28, 0.18)
        "bed":
            c = Color(0.3, 0.45, 0.7)
            r = Rect2(p - Vector2(20, 14), Vector2(40, 28))
    draw_rect(Rect2(r.position + Vector2(2, 3), r.size), Color(0, 0, 0, 0.3))
    draw_rect(r, c)
    draw_rect(r, c.darkened(0.5), false, 2.0)
    if f["k"] == "bed":
        draw_rect(Rect2(r.position + Vector2(3, 4), Vector2(10, 20)), Color(0.92, 0.92, 0.96))
    elif not f["done"]:
        draw_circle(p, 3.0 + sin(tm * 5.0), Color(1.0, 0.85, 0.2, 0.95))


func draw_zed(z):
    var T = ZT[z.k]
    var r = T["r"]
    var c = T["c"]
    if z.ht > 0:
        c = Color.WHITE
    var sw = sin(tm * (4.0 + z.k) + z.ph) * 0.25
    var a = z.face.angle()
    shadow(z.pos, r)
    draw_set_transform(z.pos, a, Vector2.ONE)
    var ac = c.darkened(0.2)
    draw_line(Vector2(2, -r * 0.6), Vector2(r + 10, -r * 0.45 + sw * 8), ac, 4.0)
    draw_line(Vector2(2, r * 0.6), Vector2(r + 10, r * 0.45 - sw * 8), ac, 4.0)
    draw_set_transform(z.pos, a, Vector2(0.8, 1.0))
    draw_circle(Vector2.ZERO, r, c.darkened(0.15))
    draw_set_transform(z.pos, a, Vector2.ONE)
    draw_circle(Vector2(3, 0), r * 0.6, c)
    draw_circle(Vector2(r * 0.5, -3), 1.6, Color(1.0, 0.1, 0.1))
    draw_circle(Vector2(r * 0.5, 3), 1.6, Color(1.0, 0.1, 0.1))
    if z.k == 3:
        draw_arc(Vector2.ZERO, r * 0.9, -1.3, 1.3, 12, Color(0.75, 0.8, 0.9), 3.0)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if z.hp < T["hp"]:
        draw_rect(Rect2(z.pos.x - 12, z.pos.y - r - 9, 24, 4), Color(0, 0, 0, 0.6))
        draw_rect(Rect2(z.pos.x - 12, z.pos.y - r - 9, 24.0 * z.hp / T["hp"], 4), Color(0.9, 0.2, 0.2))


func draw_player():
    var w = ITEMS[wp]
    var a = face.angle()
    shadow(pos, 11)
    var sa = a
    if swing > 0:
        sa = a + (swing / 0.18 - 0.5) * 1.6
    var tip = Vector2.RIGHT.rotated(sa)
    if w["t"] == "gun":
        draw_line(pos + tip * 8, pos + tip * 26, Color(0.1, 0.1, 0.1), 5.0)
    else:
        var l = 10.0 + w["r"] * 0.45
        if wp == "fist":
            l = 14.0
        draw_line(pos + tip * 8, pos + tip * l, Color(0.75, 0.78, 0.85) if w["d"] > 12 else Color(0.5, 0.35, 0.2), 4.0)
    if swing > 0 and wp != "fist":
        draw_arc(pos, w["r"] * 0.8, swing_a - 1.0, swing_a + 1.0, 12, Color(1, 1, 1, swing / 0.18 * 0.5), 4.0)
    draw_set_transform(pos, a, Vector2(0.75, 1.0))
    draw_circle(Vector2.ZERO, 12, Color(0.2, 0.35, 0.6))
    draw_set_transform(pos, a, Vector2.ONE)
    draw_circle(Vector2(2, 0), 7, Color(0.88, 0.7, 0.55))
    draw_arc(Vector2(2, 0), 6, 1.4, 4.9, 10, Color(0.2, 0.12, 0.08), 5.0)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
