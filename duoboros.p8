pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- duoboros
-- work in progress

rose = 003
vert = 009

sound =
{ turnx = 01
, turny = 02
, vert = 03
, rose = 04
, gameover = 05
, eat = 06
, perfect = 07
, boot = 08
, win = 09
}

function bright(snake)
	if (snake==rosee) return 14
	if (snake==verte) return 11
	return 1
end

function muted(snake)
	if (snake==rosee) return 02
	if (snake==verte) return 03
	return 1
end

function other(snake)
	if (snake==verte) return rosee
	if (snake==rosee) return verte
end

function snake(frame,x,y,dx)
	local a =
	{ x = x, y = y
	,	dx = dx, dy = 0
	, ddx = dx, ddy = 0
	, tail = {}
	, frame = frame
	, move = move_snake
	, control = control_snake
	, draw = draw_snake
	, ruler = draw_ruler

	, collide = collide_snake
	, selfcol = nil
	, headheadcol = nil
	, headtailcol = nil
	, tailheadcol = nil
	}

	for i=6,1,-1 do
		add(a.tail,
		{x = x-sgn(dx)*i, y = y})
	end

	return a
end

function move_snake(a)
	a.dx,a.dy=a.ddx,a.ddy
	add(a.tail,{x=a.x,y=a.y})
	if not a.omnomnom then
		del(a.tail,a.tail[1])
	else
		a.omnomnom = false
	end
	a.x = (a.x+a.dx)%14
	a.y = (a.y+a.dy)%14
end

function control_snake(a)
	local ddx=a.ddx
	if a.dx == 0 then
		if (btn"0") a.ddx,a.ddy=-1,0
		if (btn"1")	a.ddx,a.ddy=1,0
		if (ddx~=a.ddx) sfx(sound.turnx)
	else
		if (btn"2") a.ddx,a.ddy=0,-1
		if (btn"3") a.ddx,a.ddy=0,1
		if (ddx~=a.ddx) sfx(sound.turny)
	end
end

function collides(a, b)
	return
	flr(a.x)==flr(b.x) and
	flr(a.y)==flr(b.y)
end

function collide_snake(a)
	local other = other(a)
	for b in all(a.tail) do
		-- self
		if (collides(a,b)) a.selfcol=b
		-- tail head
		if collides(b, other) then
			a.tailheadcol = other
			goto next
		end
		::next::
	end
	-- head head
	if collides(a, other) then
		a.headheadcol = other
		return
	end
	-- head tail
	for c in all(other.tail) do
		if collides(a, c) then
			a.headtailcol = c
			return
		end
	end
end

function perfect()
	local cells = {rosee, verte}
	for c in all(rosee.tail) do
		add(cells, c)
	end
	for c in all(verte.tail) do
		add(cells, c)
	end
	perfect_x(cells)
	perfect_y(cells)
end

function perfect_x(cells)
	local x = verte.x
	for c in all(cells) do
		if (c.x ~= x) return
	end
	local virgin = mget(x+1,1)~=16
	for y=1,14 do
		mset(x+1,y,16)
	end
	if virgin and not is_win() then
		sfx(sound.perfect)
		slowness -= 0.5
		rumble(4, 4)
	end
end

function perfect_y(cells)
	local y = verte.y
	for c in all(cells) do
		if (c.y ~= y) return
	end
	local virgin = mget(1,y+1)~=16
	for x=1,14 do
		mset(x,y+1,16)
	end
	if virgin and not is_win() then
		sfx(sound.perfect)
		slowness -= 0.5
		rumble(4, 4)
	end
end

function draw_snake(a)
	local frame = a.frame
	if curr ~= a then
		frame += 2
	end
	for b in all(a.tail) do
		spr(frame+1,
		flr(b.x+1)*8,flr(b.y+1)*8)
	end
	spr(frame,
	flr(a.x+1)*8,flr(a.y+1)*8)
end

function draw_ruler(a)
	local color = muted(a)
	local x,y=flr(a.x+1)*8,flr(a.y+1)*8
	if a.dx == 0 then
		rectfill(x+1,8,x+5,118,color)
	else
		rectfill(8,y+1,118,y+5,color)
	end
end

function _init()
	reload(0x2000,0x2000,0x1000)
	pal()
	pal(4, 0)
	curr=nil
	rosee = snake(rose,5,10,-1)
	verte = snake(vert,8,3,1)
	sfx(sound.boot)
	slowness = 8
	rumble_stop = nil
end

function switch()
	if curr == false then
		if (btn"5") _init()
		return
	end

	if not btn"4" then
		hold4 = false
	elseif not hold4 and btn"4" then
		hold4 = true
		if (not curr) curr = rosee
		curr = other(curr)
		if (curr==verte) sfx(sound.vert)
		if (curr==rosee) sfx(sound.rose)
	end
end

function react(a)
	if a.headheadcol or
				a.tailheadcol or
				a.selfcol then
		gameover()
		return
	end

	if a.headtailcol then
		del(other(a).tail,a.headtailcol)
		a.headtailcol = nil
		a.omnomnom = true
		sfx(sound.eat)
	end
end

function gameover()
	rumble(10, 6)
	curr = false
	pal(11,6)
	pal(3,5)
	pal(14,6)
	pal(2,5)
	sfx(sound.gameover)
end

function is_win()
	for x=1,14 do for y=1,14 do
		if (mget(x,y)~=16) return false
	end end
	return true
end

function check_win()
	if is_win() and curr then
		sfx(sound.win)
		rumble(4, 6)
		curr = false
	end
end

t = 0
function update()
	curr:control()
	local slow = max(flr(slowness),0)
	if t % slow == 0 then
		rosee:move()
		verte:move()
		curr:collide()
		react(curr)
		perfect()
		check_win()
	end
end

function _update()
	t += 1
	switch()
	if (curr) update()
end

function draw_border()
	local color = bright(curr)
	rect(0,2,126,124,color)
	rect(2,0,124,126,color)
end

function _draw()
	cls()
	draw_rumble()
	draw_border()
	local other = other(curr)
	if (other) other:ruler()
	map(1,1,8,8,14,14)
	if other then
		other:draw()
		curr:draw()
	else
		rosee:draw()
		verte:draw()
		spr(005,
		flr(rosee.x+1)*8,flr(rosee.y+1)*8)
	end
end

-- rumble ---------------------

rumble_stop = nil
rumble_power = nil

function rumble(time, power)
	rumble_stop = t + time
	rumble_power = power
end

function draw_rumble()
	if t < (rumble_stop or 0) then
 	camera(
 	rnd(rumble_power)-rumble_power/2,
 	rnd(rumble_power)-rumble_power/2)
	elseif rumble_stop then
		camera(0,0)
		rumble_stop = nil
	end
end
__gfx__
000000001111111411111114eeeeeee0eeeeeee022222220222222200001eee00001eee0bbbbbbb0bbbbbbb03333333033333330bbb10000bbb1000000000000
000000001000001410101014e22222e0e22222e02eeeee202eeeee200001e2e0000122e0b33333b0b33333b03bbbbb303bbbbb30b3b10000b331000000000000
007007001111111410101014e27772e0e22222e02eeeee202e222e200001eee0000122e0b37773b0b33333b03bbbbb303b333b30bbb10000b331000000000000
000770001000001410101014e27172e0e22222e02eeeee202e222e201111111011111110b37173b0b33333b03bbbbb303b333b30111111101111111000000000
000770001111111410101014e27772e0e22222e02eeeee202e222e20eee10000e2210000b37773b0b33333b03bbbbb303b333b300001bbb0000133b000000000
007007001000001410101014e22222e0e22222e02eeeee202eeeee20e2e10000e2210000b33333b0b33333b03bbbbb303bbbbb300001b3b0000133b000000000
000000001111111411111114eeeeeee0eeeeeee02222222022222220eee10000eee10000bbbbbbb0bbbbbbb033333330333333300001bbb00001bbb000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000088888880aaaaaaa0aaaaaaa088888880000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000081111180a11111a0a98989a089a9a980000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000081999180a19991a0a89898a08a9a9a80000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000081919180a19191a0a98989a089a9a980000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000081999180a19991a0a89898a08a9a9a80000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000081111180a11111a0a98989a089a9a980000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000088888880aaaaaaa0aaaaaaa088888880000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111033333330333333303333333033333330333333303333333033333330111111101111111011111110111111101111111000001010
1010000010101010100000103bbbbb303bbbbb303bbbbb303bbbbb303bbbbb303bbbbb303bbbbb30100000101010101010000010101010101000001000001010
1010000010101010111111103b333b303b333b303b333b303b333b303b333b303b333b303bbbbb30111111101010101011111110101010101111111000001010
1010000010101010100000103b333b303b333b303b333b303b333b303b333b303b333b303bbbbb30100000101010101010000010101010101000001000001010
1010000010101010111111103b333b303b333b303b333b303b333b303b333b303b333b303bbbbb30111111101010101011111110101010101111111000001010
1010000010101010100000103bbbbb303bbbbb303bbbbb303bbbbb303bbbbb303bbbbb303bbbbb30100000101010101010000010101010101000001000001010
10100000111111101111111033333330333333303333333033333330333333303333333033333330111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111022222220222222202222222022222220222222202222222022222220111111101111111000001010
1010000010000010101010101000001010101010100000102eeeee202eeeee202eeeee202eeeee202eeeee202eeeee202eeeee20100000101010101000001010
1010000011111110101010101111111010101010111111102eeeee202e222e202e222e202e222e202e222e202e222e202e222e20111111101010101000001010
1010000010000010101010101000001010101010100000102eeeee202e222e202e222e202e222e202e222e202e222e202e222e20100000101010101000001010
1010000011111110101010101111111010101010111111102eeeee202e222e202e222e202e222e202e222e202e222e202e222e20111111101010101000001010
1010000010000010101010101000001010101010100000102eeeee202eeeee202eeeee202eeeee202eeeee202eeeee202eeeee20100000101010101000001010
10100000111111101111111011111110111111101111111022222220222222202222222022222220222222202222222022222220111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101010101011111110101010101111111010101010111111101010101011111110101010101111111010101010111111101010101000001010
10100000100000101010101010000010101010101000001010101010100000101010101010000010101010101000001010101010100000101010101000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000101010101111111010101010111111101010101011111110101010101111111010101010111111101010101011111110101010101111111000001010
10100000101010101000001010101010100000101010101010000010101010101000001010101010100000101010101010000010101010101000001000001010
10100000111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
10100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000
00111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020102010201020102010201020000010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002010201020102010201020102010000020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020102010201020102010201020000010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002010201020102010201020102010000020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020102010201020102010201020000010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002010201020102010201020102010000020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020102010201020102010201020000010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002010201020102010201020102010000020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020102010201020102010201020000010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002010201020102010201020102010000020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020102010201020102010201020000010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002010201020102010201020102010000020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020102010201020102010201020000010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002010201020102010201020102010000020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000156200d610150000c0000e000020000b0000c000090000800002000040000000000000000000000000000000000000000000000000000000000336000000000000000000000000000000000000000000
000500002062016610150000c0000e000020000b0000c000090000800002000040000000000000000000000000000000000000000000000000000000000156000000000000000000000000000000000000000000
000800001e14025140245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001943012430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000018073106600f6200561000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001d0231f630016001f62004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00190000180432550023520215301e5401e5201e5101c5001c5001c50010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002c00000602003000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011000025043120301e54017550246331c0300d5401055003500125701255012530125102a2101e2200220000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0019000025043120301e540175501d0430b0300d5401055003500125701255012530125102a2301e2200220000000000000000000000000000000000000000000000000000000000000000000000000000000000