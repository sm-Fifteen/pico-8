pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- gravity war
-- work in progress

function _init()
	cls()
	playing = 0
	players = init_players()
	planets = init_planets()
	shots = {}
end

function control()
	move_player(players[playing])

	if btnp"4" then
		playing += 1
		sfx(7)
	end

	local mars = planets[1]
	if (btnp(2,1)) mars.mass += 4
	if (btnp(3,1)) mars.mass -= 4
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
	rectfill(0, 0, 128, 3, 10)
	rectfill(x, 0, 128, 3, 0)
end
-->8
------------------- player ----

aim_sens = 0.005
power_sens = 0.03
max_power = 2.0

player_radius = 2
gun_length = 7

function init_players()
	return {
		player(15, 15, 8),
		player(113, 113, 12),
	}
end

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
	pwr = min(max(pwr,0),max_power)
	if pwr != a.power then
		sfx(1, 3, pwr * 3, 1)
		a.power = pwr
	end
end

function draw_players()
	for i, a in pairs(players) do
		draw_gun(a.x, a.y, a.old, 0)
		draw_gun(a.x, a.y, a.d, a.col)

		circfill(a.x, a.y, a.r, a.col)

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

function init_planets()
	return {
		planet(64, 64, 20, 150),
	}
end

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
		pl.x + cos(pl.d) * 4,
		pl.y + sin(pl.d) * 4,
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
	}
end

function move_shots()
	for a in all(shots) do
		if a.expl > 0 then
			a.expl += 0.01
			if (a.expl>0.5) del(shots,a)
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

function outside(a)
	return
		a.x < 0 or a.x > 128 or
		a.y < 0 or a.y > 128
end

function draw_shots()
	for i, a in pairs(shots) do
		local x, y = a.x, a.y

		if a.expl == 0 then
			line(a.ox,a.oy,x,y,a.col+1)
			local size =
				sqrt(sqr(a.dx)+sqr(a.dy))
			sfx(3+i%2, i, size * 7, 1)
		else
			if a.expl > 0.25 then
				circfill(x,y,expl_radius,0)
			end
			circfill(
				x,y,
				expl_radius*-sin(a.expl),
				a.col+1)
		end
	end
end
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002101021020210302104021050210602107000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a03002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000015520165201752018520195201a5201b5201c5201d5201e5201f520205202152022520235202452025520265202752028520295202a5202b5202c5202d5202e5202f5203052031520325203352034520
0104000015720167201772018720197201a7201b7201c7201d7201e7201f720207202172022720237202472025720267202772028720297202a7202b7202c7202d7202e7202f7203072031720327203372034720
000d0000106430e033090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100001305302670026600265002650026400264002640026300263002623026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700002b6201261013033024001f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
