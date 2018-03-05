pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- gravity war
-- by ace + 15

function _init()
	cls()
	played = false
	playing = 0
	players = {}
	planets = {}
	shots = {}
	gen_map(2, 3)
end

function can_reset()
	return not played or
		#players <= 1
end

function control()
	move_player(players[playing])

	if btnp"4" then
		playing += 1
		sfx(7)
	end

	if btnp"5" and can_reset() then
		_init()
	end

	--local mars = planets[1]
	--if (btnp(2,1)) mars.mass += 4
	--if (btnp(3,1)) mars.mass -= 4
end

function _update()
	if playing < 1 then
		move_shots()
		if #shots < 1 then
			playing = 1
		end
		return
	end

	control()

	if playing > #players then
		for a in all(players) do
			add(shots, shoot(a))
		end
		playing = -1
		played = true
	end
end

function _draw()
	maybe_clear()
	draw_shots()
	draw_planets()
	draw_players()
	draw_power(players[playing])
end

function maybe_clear()
	if playing < 0 then
		playing = 0
		cls()
	end
end

function draw_power(a)
	if (not a) return
	local x=a.power*(128/max_power)
	rectfill(0, 0, 128, 3, a.col)
	rectfill(x, 0, 128, 3, 0)
end

function gen_map(n_players, n_planets)
	local n = n_players + n_planets
	local r, k = 25, 10

	local points = distribute_points(r, k)

	for i=1, n_players do
		local p = points[flr(rnd(#points)) + 1]
		if(not p)return _init()
		add(players, player(p.x, p.y,player_colors[i]))
		del(points, p)
	end

	for i=1, n_planets do
		local p = points[flr(rnd(#points)) + 1]
		if(not p)return _init()
		local size = flr(p_min_size + rnd(r/2-p_min_size))
		local mass = flr(p_min_mass + rnd(p_max_mass - p_min_mass))
		if (rnd(15) < 1) mass = -mass
		add(planets, planet(p.x, p.y, size, mass))
		del(points, p)
	end

	for p in all(points) do
		circfill(p.x, p.y, 1, 11)
	end
end

function distribute_points(r, k)
	-- Poisson disc distribution algo
	local points = {}
	local active = {}
	local x0, y0 = flr(rnd(128)), flr(rnd(128))
	add(points, {x=x0, y=y0})
	add(active, {x=x0, y=y0})

	while (#active > 0) do
		local a = active[flr(rnd(#active)) + 1]

		for i=1, k do
			local x,y = random_point_around(a.x, a.y, r, 2*r)
			local valid = true

			if (outside({x=x,y=y},8)) valid = false

			for p in all(points) do
				if (not valid) break
				if collides(p, {x=x, y=y, r=r}) then
					valid = false
				end
			end

			if (valid) then
				add(points, {x=x, y=y})
				add(active, {x=x, y=y})
				break
			end

			if (i == k) then
				del(active, a)
			end
		end
	end

	return points
end

function random_point_around(x, y, r, r2)
	local dist = r + rnd(r2-r)
	local rot = rnd(1)
	return x + dist * cos(rot), y + dist * sin(rot)
end
-->8
------------------- player ----

player_colors = {8, 12}

aim_sens = 0.005
power_sens = 0.03
min_power = 0.5
max_power = 2.5

player_radius = 3
gun_length = 9

function aim_center(x, y)
	return atan2(64-x, 64-y, x, y)
end

function player(x, y, col)
	local d = aim_center(x, y)

	return {
		x = x,
		y = y,
		col = col,
		d = d,
		old = d,
		r = player_radius,
		power = max_power / 2,
	}
end

function move_player(a)
	if (not a) return

	a.old = a.d
	if (btn"0") a.d+=aim_sens
	if (btn"1") a.d-=aim_sens
	if a.old != a.d then
		sfx(2)
	end

	local pwr = a.power
	if (btn"2") pwr += power_sens
	if (btn"3") pwr -= power_sens
	pwr = min(max(pwr,min_power),max_power)
	if pwr != a.power then
		sfx(1, 3, pwr * 2, 1)
		a.power = pwr
	end
end

function draw_players()
	for i, a in pairs(players) do
		draw_gun(a.x, a.y, a.old, 0)
		draw_gun(a.x,a.y,a.d,a.col)

		circfill(a.x,a.y,a.r,a.col)

		if i == playing then
			circfill(a.x, a.y, 1, 0)
		end
	end
end

function draw_gun(x, y, d, col)
	line(
			x, y,
			x + cos(d) * gun_length,
			y + sin(d) * gun_length,
			col)
end
-->8
------------------- planet ----

rylander_dither = {
	0x0000, 0x8000, 0x8020, 0xa020,
	0xa0a0, 0xa8a0, 0xa8a2, 0xaaa2,
	0xaaaa, 0xeaaa, 0xeaba, 0xfaba,
	0xfafa, 0xfefa, 0xfefb, 0xfffb,
}

planet_colors = {15, 14, 4, 2, 5}

p_min_size = 5
p_min_mass = 50
p_max_mass = 250

function planet(x, y, r, mass)
	return {
		x = x,
		y = y,
		r = r,
		mass = mass,
	}
end

function draw_planets()
	for a in all(planets) do
		if a.mass < 1 then
			local col = dither(-a.mass)
			fillp(0)
			circ(a.x, a.y, a.r, col)
			print(a.mass,a.x-8,a.y-2,7)
			return
		end

		local col = dither(a.mass)
		circfill(a.x, a.y, a.r, col)
		draw_label(a)
	end
	fillp(0)
end

function planet_color(i)
	i = min(i, #planet_colors)
	return planet_colors[i]
end

function dither(mass)
		local i = flr(mass/4/16+1)
		local j = flr(mass/4%16+1)
		local col1 = planet_color(i)
		local col2 = planet_color(i+1)

		fillp(rylander_dither[j])
		return col1 + (col2 * 0x10)
end

function draw_label(a)
	print(
			a.mass,
			a.x - 5, a.y - 2,
			a.mass < 100 and 0 or 7)
end
-->8
--------------------- shot ----

expl_radius = 15

function shoot(pl)
	return shot(
		pl.x + cos(pl.d) * gun_length,
		pl.y + sin(pl.d) * gun_length,
		pl.d,
		pl.power * 2,
		pl.col)
end

function shot(x, y, d, v, col)
	return {
		x = x,
		y = y,
		ox = x,
		oy = y,
		dx = cos(d) * v,
		dy = sin(d) * v,
		col = col,
		expl = 0,
		dotted = 0,
	}
end

function move_shots()
	for a in all(shots) do
		if a.expl > 0 then
			a.expl += 0.02
			if (a.expl>1) del(shots,a)
			return
		end

		a.ox = a.x
		a.oy = a.y
		a.x += a.dx
		a.y += a.dy

		collide_players(a)
		follow_planets(a)
		if (outside(a)) del(shots, a)
	end
end

function sqr(x) return x*x end

function collides(a, b)
	local ax, ay = a.x, a.y
	local bx, by, r = b.x, b.y, b.r
	if (r < 1) r = -r
	return r > sqrt(
		sqr(ax - bx) + sqr(ay - by))
end

function collide_players(a)
	for b in all(players) do
		if collides(a, b) then
			a.expl = 0.01
			a.x = b.x
			a.y = b.y
			a.dx = 0
			a.dy = 0
			del(players, b)
			sfx(6)
		end
	end
end

function follow_planets(a)
	for b in all(planets) do
		local d = atan2(
			b.x-a.x,b.y-a.y,
			a.x,a.y)

		local grav = b.mass /
			abs(sqr(b.x-a.x)+sqr(b.y-a.y))

		a.dx += grav * cos(d)
		a.dy += grav * sin(d)

		if collides(a,b) then
			del(shots,a)
			sfx(5)
		end
	end
end

function outside(a, margin)
	if (not margin) margin=0
	return
		a.x < margin or
		a.x > 128-margin or
		a.y < margin or
		a.y > 128-margin
end

function draw_shots()
	for i, a in pairs(shots) do
		local x, y = a.x, a.y

		if a.expl == 0 then
			a.dotted += 0.25
			local col = a.col
			if(a.dotted%2<1)col=7
			line(a.ox,a.oy,x,y,col)

			local size =
				sqrt(sqr(a.dx)+sqr(a.dy))
			sfx(3+i%2, i, size * 7, 1)
		else
			if a.expl > 0.25 then
				circfill(x,y,expl_radius,0)
			end
			circfill(
				x,y,
				expl_radius*-sin(a.expl/2),
				10)
		end
	end
end
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088800000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008880888000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008888888877778888888800088000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000008880000000000000000008880888000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000007780000000000000000000000888880000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000007770000000000000000000000000088800000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000770000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000008800000ccccc000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000800ccccc00000cccc00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077cc00000000000000ccc77000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777780000000000000000000000777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000077000800000000000000000000000000770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000007700008000000000000000000000000000007770000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000770000080000000000000000000000000000000007700000000000000000000000000000000000
00000000000000000000000000000000000000000000000077000000800000000000000000000000000000000000070000000000000000000000000000000000
00000000000000000000000000000000000000000000000700000008000000000000000000000000000000000000007700000000000000000000000000000000
00000000000000000000000000000000000000000000077000000008000000000000000000000000000000000000000070000000000000000000000000000000
00000000000000000000000000000000000000000000c0000000008000000000000000000000000000000000000000000cc00000000000000000000000000000
0000000000000000000000000000000000000000000c0000000000800000000000000000000000000000000000000000000c0000000000000000000000000000
00000000000000000000000000000000000000000cc000000000080000000000000000000000000000000000000000000000cc00000000000000000000000000
0000000000000000000000000000000000000000c0000000000007000000000000002222200000000000000000000000000000c0000000000000000000000000
000000000000000000000000000000000000000c000000000000070000000000000222222200000000000000000000000000000c000000000000000000000000
0000000000000000000000000000000000000cc00000000000007000000000000022242224200000000000000000000000000000c00000000000000000000000
000000000000000000000000000000000000c00000000000000070000000000002222222222200000000000000000000000000000c0000000000000000000000
00000000000000000000000000000000000c0000000000000007000000000000277227772777200000000000000000000000000000cc00000000000000000000
0000000000000000000000000000000000c0000000000000000700000000000022722727272720000000000000000000000000000000c0000000000000000000
000000000000000000000000000000000c0000000000000000070000000000002472277727272000000000000000000000000000000007000000000000000000
00000000000000000000000000000000c00000000000000000700000000000002272222727272000000000000000000000000000000007000000000000000000
0000000000000000000000000000000c000000000000000000700000000000002777222727772000000000000000000000000000000000700000000000000000
0000000000000000000000000000000c000000000000000000700000000000000222222222220000000000000000000000000000000000070000000000000000
000000000000000000000000000000c0000000000000000000700000000000000022242224200000000000000000000000000000000000007000000000000000
00000000000000000000000052225220000000000000000007000000000000000002222222000000000000000000000000000000000000000700000000000000
00000000000000000000002222222222200000000000000007000000000000000000222220000000000000000000000000000000000000000070000000000000
00000000000000000000025222522252220000000000000070000000000000000000000000000000000000000000000000000000000000000007000000000000
00000000000000000000222222222222222000000000000070000000000000000000000000000000000000000000000000000000000000000000700000000000
00000000000000000002522252225222522200000000000070000000000000000000000000000000000000000000000000000000000000000000700000000000
00000000000000000022222222222222222220000000000070000000000000000000000000000000000000000000000000000000000000000000070000000000
0000000000000000005222522252225222522000000000070000000000000000000000000000000000000000000000000000000000000000000000c000000000
0000000000000000022222222222222222222200000000070000000000000000000000000000000000000000000000000000000000000000000000c000000000
00000000000000000222527772777277722252000000000800000000000000000000000000000000000000000000000000000000000000000000000c00000000
00000000000000000222222272727222722222000000000800000000000000000000000000000000000000000000000000000000000000000000000c00000000
000000000000000002522277727272577252220000000080000000000000000000000000000000000000000000000000000000000000000000000000c0000000
000000000000000002222272227272227222220000000080000000000000000000000000000000000000000000000000000000000000000000000000c0000000
0000000000000000022252777277727772225200000008000000000000000000000000000000000000000000000000000000000000000000000000000c000000
0000000000000000022222222222222222222200000008000000000000000000000000000000000000000000000000000000000000000000000000000c000000
00000000000000000052225222522252225220000000800000000000000000000000000000000000000000000000000000000000000000000000000000c00000
00000000000000000022222222222222222220000000800000000000000000000000000000000000000000000000000000000000000000000000000000c00000
00000000000000000002522252225222522200000008000000000000000000000000000000000000000000000000000000000000000000000000000000c00000
000000000000000000002222222222222220000000080000000000000000000000000000000000000000000000000000000000000000000000000000000c0000
000000000000000000000252225222522200000000800000000000000000000000000000000000000000000000000000000000000000000000000000000c0000
00000000000000000000002222222222200000000080000000000000000000000000000000000000000000000000000000000000000000000000000000070000
00000000000000000000000052225220000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000007000
00000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000007000
000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000e4e4e000000007000
0000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000e4e4e4e4e0000007000
00000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000e444e444e444e00000700
00000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000004e4e4e4e4e4e4e40000700
00000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000004e4e4e4e4e4e4e40000700
000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000e4e4e4e4e4e4e4e4e000700
00000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000044e444e444e444e44000700
000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000004e4e774e777e777e4e400700
000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000004e4e474e7e7e4e7e4e400700
000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000004e4e474e7e7e777e4e400700
00000000000000000000000000000770000000000000000000000000000000000000000000000000000000000000000000000000444e474e747e744e44400700
000000000000000000000000007770000000000000000000000000000000000000000000000000000000000000000000000000004e4e777e777e777e4e400700
000000000000000000000000870000000000000000000000000000000000000000000000000000000000000000000000000000000e4e4e4e4e4e4e4e4e000700
000000000000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000e4e4e4e4e4e4e4e4e000700
00000000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000004e444e444e444e40000c00
00000000000008888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000004e4e4e4e4e4e4e4000c000
07777777777780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e4e4e4e4e4e4e0000c000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e4e4e4e4e00000c0000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e444e0000000c0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000770000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc0000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007cc00000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ccc00000cc700000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc00cc00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc00000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002101021020210302104021050210602107000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a03002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000015520165201752018520195201a5201b5201c5201d5201e5201f520205202152022520235202452025520265202752028520295202a5202b5202c5202d5202e5202f5203052031520325203352034520
0104000015720167201772018720197201a7201b7201c7201d7201e7201f720207202172022720237202472025720267202772028720297202a7202b7202c7202d7202e7202f7203072031720327203372034720
000d0000106430e033090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100001305302670026600265002650026400264002640026300263002623026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700002b6201261013033024001f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
