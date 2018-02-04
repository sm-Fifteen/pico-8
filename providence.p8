pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- providence
-- work in progress

function wav(val,amp,len)
	return amp*sin(val/len)
end


function new_backdrop()
	local backdrop = {v=0}

	function backdrop:update()
		local speed = wav(gt,0.63,200)
		self.v += speed
	end

	function backdrop:draw()
		cls()
		map(16,0,0,0,16,16)
		map(32,0,0,-64+self.v,16,32)
		map(0,16,64+self.v,72,16,2)
		map(0,16,-64-self.v,72,16,2)
		map(0,0,0,0,16,16)
	end

 return backdrop
end


function draw_health()
	local hp = eye.health
	if hp > 190 then
		rect(-191+hp,0,0,0,8)
		rect(318-hp,0,127,0,8)
	end
	if hp > 63 then
		rect(0,191-hp,0,127,8)
		rect(127,191-hp,127,127,8)
	end
	if hp > 0 then
		rect(64-hp,127,64,127,8)
		rect(63+hp,127,64,127,8)
	end
end


function new_eye()
	local eye =
	{ x = 48, y = 0, by = 0
	, px = 0, py = 0
	, health = 254
	}

	function eye:update()
		self.y = 1+wav(gt-20,1.98,200)
		self.by = -2+wav(gt-120,2.98,200)

		local d = atan2(pl.x-64,pl.y-20)
		self.px = flr(2*cos(d)+0.5)
		self.py = flr(2*sin(d)+0.5)
	end

	function eye:draw()
		spr(010,self.x-8,self.by,6,4)
		spr(078,
				self.x+self.px+8,
				self.y+self.py+16,2,2)
		spr(006,self.x,self.y,4,4)
	end

	return eye
end


function new_lemon(x,y,dx)
	local lemon =
	{ x = x + dx, y = y
	, dx = dx
	,	frame = 088
	}

	function lemon:allergy()
		local function test(x,y)
			if pget(x,y) == 10 then
				if not self.dead then
					self.dead = true
					del(lemons, self)
					eye.health -= 1
				end
			end
		end

		local x,y = self.x,self.y
		for i=x+1,x+6 do
			test(i,y+3)
		end
	end

	function lemon:update()
		self.x += self.dx
		if self.x<-20 or self.x>140 then
			del(lemons, self)
		end
	end

	function lemon:draw()
		spr(self.frame,
		self.x,self.y,
		1, 1, self.dx > 0)
	end

	return lemon
end


function new_shield()
	local shield =
	{ y = 40
	, frame = 096 }
	
	function shield:draw()
 	map(0,24,-16+(gt%8),self.y,32,1)
	end
	
	return shield
end


function new_player()
	local pl =
	{ x = 61, y = 68
	, speed = 2
	, tail = {}
	, bt = 0
	}

	for i=1,4 do
		pl.tail[i] =
		{ x = pl.x, y = pl.y
		, frame = 072 + i
		}
	end

	function pl:joydelta()
		if (self.dead) return 0,0

		local dx,dy = 0,0
		if (btn"0") dx -= self.speed
		if (btn"1") dx += self.speed
		if (btn"2") dy -= self.speed
		if (btn"3") dy += self.speed
		return dx,dy
	end

	function pl:shoot(d)
		if (self.dead) return

		local a =
				new_lemon(
				self.x,self.y,3*d)

		add(lemons, a)
	end

	function pl:allergy()
		local function test(x,y)
			if pget(x,y) == 10 or
						pget(x,y) == 8 then
				if not self.dead then
					sfx(1)
					self.dead = true
					self.deadt = 0
					rumble(8, 10)
				end
			end
		end

		local x,y = self.x,self.y
		for j=y+1,y+5 do
			test(x+3,j)
		end
	end

	function pl:update()
		if (self.deadt) self.deadt += 1
	 self.bt += 1

		local cx,cy = self.x,self.y
		for a in all(self.tail) do
			local tx,ty = a.x,a.y
			a.x,a.y = cx,cy
			cx,cy = tx,ty
		end

		local dx,dy = self:joydelta()
		self.x += dx
		self.y += dy
		self.x = min(max(self.x,1),120)
		self.y = min(max(self.y,1),120)

		if (self.bt < 0) return
		if (btn"4") self:shoot(-1)
		if (btn"5") self:shoot(1)
		if btn"4" or btn"5" then
			self.bt = -6
		end
	end

	function pl:draw()
		for a in all(pl.tail) do
			spr(a.frame,a.x,a.y)
		end
		spr(072,self.x,self.y)
	end

	return pl
end


function transparent(col)
	palt(0,false)
	palt(col,true)
end

function _init()
	gt = 0
	transparent(15)
	backdrop = new_backdrop()
	
	shield = new_shield()
	eye = new_eye()
	
	pl = new_player()
	lemons = {}

	rumble_stop = nil
	rumble_power = nil
end

function _update()
	gt += 1

	backdrop:update()
	eye:update()
	pl:update()

	for a in all(lemons) do
		a:update()
	end
end

function _draw()
	draw_rumble()
	backdrop:draw()

	shield:draw()
	eye:draw()

	for a in all(lemons) do
		a:allergy()
	end

	for a in all(lemons) do
		a:draw()
	end

	pl:allergy()
	pl:draw()

	for i=0,5 do
		rect(-i,-i,127+i,127+i,1)
	end
	
	draw_health()
	
	if pl.dead then
		circfill(pl.x+3,pl.y+3,
		pl.deadt*5,0)
		spr(077,pl.x,pl.y)
	end
end

-- rumble ---------------------

function rumble(time, power)
	rumble_stop = gt + time
	rumble_power = power
end

function draw_rumble()
	if gt < (rumble_stop or 0) then
		camera(
		rnd(rumble_power)-rumble_power/2,
		rnd(rumble_power)-rumble_power/2)
	elseif rumble_stop then
		camera(0,0)
		rumble_stop = nil
	end
end
__gfx__
000000001111111111111111ffffffff0ffffffffffffffffffffffffffffffffffffffffffffffff11dddddddddd116666666666666666666666661111dd11f
000000001dddddddddddddddffffffff0ffffffffffffffffffffffffffffff00fffffffffffffffff111ddddddddd116666666666666666666661111ddddd11
007007001dddddddddddddddfffffff0d0ffffffffffffffffffffffffffff0990fffffffffffffffff1111dddddddd116666666666666666611111dddddddd1
000770001dddddddddddddddfffffff0d0fffffffffffffffffffffffffff09aa90fffffffffffffffff11111ddddddd116666666666666661111dddddddd111
000770001dddddddddddddddffffff0ddd0ffffffffffffffffffffffffff09aa90fffffffffffff11f11661111dddddd111666666666661111dddddddd1111f
007007001dddddddddddddddffffff0ddd0fffffffffffffffffffffffff09aaaa90ffffffffffff1d116666611111ddddd11666666661111dddddddd1111fff
000000001dddddddddddddddfffff0ddddd0ffffffffffffffffffffffff09aaaa90ffffffffffff1d1166666661111ddddd11166611111dddddddd1116111ff
000000001555555555555555fffff0555550fffffffffffffffffffffff09aaaaaa90fffffffffff1dd11666666611111dddd1111111ddddddddd11166661d1f
ffffffffffffffff11110fffffff011111110fff5d5d5d5dfffffffffff09aaaaaa90fffffffffff1dd1111666666661111dddd111ddddddddd1111666661dd1
ffffffffffffffff1ddd0fffffff0ddddddd0fffd5d5d5d5ffffffffff09aaaaaaaa90ffffffffff11ddd111166666666111ddddddddddddd1111166666611d1
ffffffffffffffff1dddd0fffff0ddddddddd0ff5d5d5d5dffffffffff09aaaaaaaa90fffffffffff1ddddd11116666666611dddddddddd11116666666611dd1
ffffffffffffffff1dddd0fffff0ddddddddd0ffd5d5d5d5fffffffff09aaaaaaaaaa90ffffffffff11dddddd1111666666611dddddd1111166666666111ddd1
ffffffffffffffff1ddddd0fff0ddddddddddd0f5d5d5d5dfffffffff09aaaaaaaaaa90fffffffffff1dddddddd1111666666111ddd1111666666661111dddd1
ffffffffffffffff1ddddd0fff0ddddddddddd0fd5d5d5d5ffffffff09aaaaaaaaaaaa90ffffffffff111dddddddd1111666661111111666666661111ddddd11
ffffffffffffffff1dddddd0f0ddddddddddddd05d5d5d5dffffffff09aaaaaaaaaaaa90fffffffffff1111ddddddd1111166661111666666661111ddddddd11
ffffffffffffffff15555550f055555555555550d5d5d5d5fffffff09aaaaaaaaaaaaaa90fffffffffff11111ddddddd1111166116666666611111ddddddd111
f000000000000000ffffffff011111110111111100000000fffffff09aaaaaaaaaaaaaa90ffffffff11f1161111dddddddd1111116666661111dddddddd1111f
f5ddd5ddd5ddd5ddffffffff0ddddddd0ddddddd00000000ffffff09aaaaa111111aaaaa90ffffff1d111666611111ddddddd111166661111dddddddd111ffff
f5d5d5d5d5d5d5d5fffffff0dddddddddddddddd10001000ffffff09aaa1111111111aaa90ffffff1d1166666661111dddddddd11661111dddddddd1111fffff
f5d5d5d5d5d5d5d5fffffff0dddddddddddddddd01010101fffff09aa1111ffffff1111aa90fffff1dd11666666661111dddddd111111ddddddd1111111fffff
f5d5d5d5d5d5d5d5ffffff0ddddddddddddddddd10101010fffff09a111ffffffffff111a90fffff1dd1111666666611111dddd1111dddddddd111166611ffff
f5d5d5d5d5d5d5d5ffffff0dddddddddddddddddd101d101ffff09a1177ffffffffff7711a90ffff11ddd11116666666611111d11dddddddd11116666661ffff
fdd5ddd5ddd5ddd5ffffff0ddddddddddddddddd1d1d1d1dffff09a1777ffffffffff7771a90fffff1ddddd111116666661111111dddddd11116666666611111
f000000000000000ffffffdd55555555dddddddd01d101d1fff09aaa177ffffffffff771aaa90ffff11dddddd1111666666661111dd111111666666666666661
161116111fffffff0fffffff11111111111111111d1d1d1dfff09aaaa11ffffffffff11aaaa90fffff1dddddddd1111666661111111111166666666166666661
111d111d1fffffff0fffffff1dddddddddddddddd101d101ff09aaaaaaa11ffffff11aaaaaaa90ffff111dddddddd11111611ffffff11666666661111666611f
1d111d111fffffffd0ffffff1ddddddddddddddd1d1d1d1dff09aaaaaaaaa111111aaaaaaaaa90fffff1111dddddddd11111ffffffff1166666111fff1111fff
111611161fffffffd0ffffff1dddddddddddddddd1d1d1d1f09aaaaaaaaaaaaaaaaaaaaaaaaaa90ffffff1111dddddddd1ffffffffffff11611fffffffffffff
161116111fffffffdd0fffff1ddddddddddddddd1d1d1d1df09aaaaaaaaaaaaaaaaaaaaaaaaaa90fffffffff111ddddd1ffffffffffffff1111fffffffffffff
111d111d1fffffffdd0fffff1dddddddddddddddd1d1d1d109aaaaaaaaaaaaaaaaaaaaaaaaaaaa90ffffffffff111111ffffffffffffffffffffffffffffffff
1d111d111fffffffdd0fffff1ddddddddddddddd1d1d1d1d09999999999999999999999999999990ffffffffffffffffffffffffffffffffffffffffffffffff
111611161fffffffdddfffffdddddddddddddddd1111111100000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff
00000ddddd000000000000000000000000000000000000000000000000000000ffbbbfffffbbbfffffffffffffffffffffffffffff000ffffff7777777777fff
000ddddddddd000000000000000000d000000000000000000000000000000000fbb0bbfffbbbbbffffbbbffffffffffffffffffff00800fff77777777777777f
00ddddddddddd000000000050000000000005000000000000000000000005000bb000bbfbbbbbbbffbbbbbffffbbbfffffffffff0088800ff77777777777777f
0ddddddddddddd0000100000000000000000000000000000000d000000000000bbb0bbbfbbbbbbbffbbbbbffffbbbffffffbffff0008000f777777cccc777777
0ddddddddddddd00000000000000000000000000000000000000000000000000bbb0bbbfbbbbbbbffbbbbbffffbbbfffffffffff0008000f77777cc00cc77777
ddddddddddddddd0000000000005000000d00001000000000000000001000000fbb0bbfffbbbbbffffbbbffffffffffffffffffff00800ff77777c0700c77777
ddddddddddddddd0000000000000000000000000000005000000000000000000ffbbbfffffbbbfffffffffffffffffffffffffffff000fff77777c0000c77777
ddddddddddddddd0050000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff77777cc00cc77777
ddddddddddddddd0000000000000000000000000000000000500000000000000ffffffff0000000000000000000000000000000000000000777777cccc777777
ddddddddddddddd000000001000000000000000000000000000000000000000011111fff0000000000000000000000000000000000000000f77777777777777f
0ddddddddddddd000000000000000000000000000500000000000000000500001bbb11110000000000000000000000000000000000000000f77777777777777f
0ddddddddddddd000000000000005000000000000000000000000000000000001b0bb1b10000000000000000000000000000000000000000fff7777777777fff
00ddddddddddd000000000000000000000000000000000000d000000000000001bbb11110000000000000000000000000000000000000000ffffffffffffffff
000ddddddddd000000d000000000000000d0000000001000000000000000000011111fff0000000000000000000000000000000000000000ffffffffffffffff
00000ddddd000000000000000010000000000000000000000000001000000000ffffffff0000000000000000000000000000000000000000ffffffffffffffff
0000000000000000000000000000000000000000000000000000000000000000ffffffff0000000000000000000000000000000000000000ffffffffffffffff
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
81888188000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
81818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88818881000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000053000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000004343000000000000004500404100000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000465253000000000000000000505100000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000440000540000000000000053450057000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000465355000000000000004544574300000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000202121212121000000000000000044000000000000004600465354000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003230102010201040000000045554557000000000000000043000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013010201020102120000000000540000000000000000000000570000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000323020102010201020400000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001302010201020102011400000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000032301020102010201020104000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000130102010201020102010212000015151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003230201020102010201020102040015151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013020102010201020102010201140015151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2224333433343334333433343334333215151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2525252525252525252525252525252525252525250000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3535353535353535353535353535353535353535350000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060606060606060606060606060606060606060606060606060606060606060000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001b053226301e6201a61014610146001f603136001e6001a60000000000001b003226001e6001a60000000000000000000000000000000000000000000000000000000000000000000000000000000000
