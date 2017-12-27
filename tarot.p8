pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
defs={}
defs[004]="a disk"
defs[006]="2 disks"
defs[008]="3 disks"
defs[010]="4 disks"
defs[012]="5 disks"
defs[014]="6 disks"
defs[068]="a sword"
defs[070]="2 swords"
defs[072]="3 swords"
defs[074]="4 swords"
defs[076]="5 swords"
defs[078]="6 swords"
defs[132]="a cup of love"
defs[134]="2 cups of union"
defs[136]="3 cups of abundance"
defs[138]="4 cups"
defs[140]="5 cups of disappointment"
defs[142]="6 cups"
defs[196]="a wand"
defs[198]="2 wands"
defs[200]="3 wands"
defs[202]="4 wands"
defs[204]="5 wands"
defs[206]="6 wands"

deck = {}

open = 192
closed = 193

hand = {
	x = 88,
	y = 12,
	card = nil,
}

limbo = {}
for i,_ in pairs(defs) do
	add(limbo, i)
end

while #limbo > 0 do
	local s = limbo[flr(rnd(#limbo)+1)]
	del(limbo, s)

	add(deck, {
		s = s,
		def = defs[s],
		x = 96, y = 0,
		f = false,
	})
end

function _update()
	local dx,dy = 0,0
	if (btn"0") dx -= 2
	if (btn"1") dx += 2
	if (btn"2") dy -= 2
	if (btn"3") dy += 2

	hand.x += dx
	hand.y += dy

	if hand.card then
		hand.card.x += dx
		hand.card.y += dy
	end

	if btn"4" then
		if (hold4) return
		hold4 = true

		if hand.card then
			add(deck, hand.card)
			hand.card = nil
		else
			for i=#deck,1,-1 do
				local card = deck[i]

				if hand.x > card.x and
						hand.x < card.x + 26 and
						hand.y > card.y and
						hand.y < card.y + 28 then
					del(deck, card)
					hand.card = card
					break
				end
			end
		end
	else
		hold4 = false
	end

	if btn"5" then
		if (hold5) return
		hold5 = true

		if hand.card then
			hand.card.f = not hand.card.f
		else
			for i=#deck,1,-1 do
				local card = deck[i]

				if hand.x > card.x and
						hand.x < card.x + 26 and
						hand.y > card.y and
						hand.y < card.y + 28 then
					card.f = not card.f
					break
				end
			end
		end
	else
		hold5 = false
	end
end

function draw_card(card)
	local x,y = card.x,card.y

	if card.f then
		spr(0,  x, y, 4, 1)
 	spr(16, x, y+8, 1, 3)
 	spr(19, x+24, y+8, 1, 3)
 	spr(48, x, y+24, 4, 1)
		spr(card.s, x+8, y+8, 2, 2)
	else
		spr(128, x, y, 4, 4)
	end
end

function _draw()
	map(0,0,0,0,16,16)

	for card in all(deck) do
		draw_card(card)
	end

	if hand.card then
		draw_card(hand.card)
		spr(closed, hand.x, hand.y)
	else
		spr(open, hand.x, hand.y)
	end
	
	if hand.card and hand.card.f then
	 print(hand.card.def, 3, 120, 7)
	else
 	for i=#deck,1,-1 do
 		local card = deck[i]
 
 		if card.f and
 				hand.x > card.x and
 				hand.x < card.x + 26 and
 				hand.y > card.y and
 				hand.y < card.y + 28 then
 			print(card.def, 3, 120, 7)
 			break
 		end
 	end
	end
end
__gfx__
00000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111117111111171111111111111111111
00000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111177711111777111111111111111711
00000000000000000000000000000000111111111111111111111111111111111111171111111111111117111111711111777771117777711117111111117771
00000000000000000000000000000000111111111111111111117111111111111111777111111111111177711117771111177711111777111177711111177777
00000222222222222222222222200000111111111111111111177711111111111117777711111111111777771177777111117111111171111777771111117771
00002277777777777777777777220000111111111111111111777771111111111111777111111111111177711117771111111111117111111177711171111711
00002771111111111111111117720000111111117111111111177711111111111111171111111111111117111111711111111111177711111117111777111111
00002711111111111111111111720000111111177711111111117111111111111111111111171111111111111111111111171111777771111111117777711111
00002711111111111111111111720000111111777771111111111111117111111111111111777111111111111111111111777111177711111111111777111711
00002711111111111111111111720000111111177711111111111111177711111111711117777711111171111111111117777711117111111171111171117771
00002711111111111111111111720000111111117111111111111111777771111117771111777111111777111117111111777111711111111777111111177777
00002711111555555511111111720000111111111111111111111111177711111177777111171111117777711177711111171117771111117777711171117771
00002711111555555555111111720000111111111111111111111111117111111117771111111111111777111777771111111177777111111777111777111711
00002711111555111555111111720000111111111111111111111111111111111111711111111111111171111177711111111117771111111171117777711111
00002711111555111555111111720000111111111111111111111111111111111111111111111111111111111117111111111111711111111111111777111111
00002711111555111555111111720000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111171111111
00002711111111111555111111720000333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
00002711111111155555111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111155551111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111155511111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111155111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111111111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111155111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111155111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111111111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111111111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111111111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111111111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002711111111111111111111720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002771111111111111111117720000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00002277777777777777777777220000300000000000000330000000000000033000000000000003300000000000000330000000000000033000000000000003
00000222222222222222222222200000333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
1111ddd111ddd1111111ddd111ddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111711
dd111d11d11d111ddd111d11d11d111d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111177777771
dddd111ddd111ddddddd111ddd111ddd111111111111111111111111111111111111111111111111111111111111111111711111711117111171111111111711
ddddd11ddd11ddddddddd11ddd11dddd111111111111111111111111111111111111111111111111111711171117111117771117771177711777777777111111
11dddd11d11dddd111dddd11d11dddd1111111111111111111111171111711111111711171117111111711171117111111711111711117111171111111111111
d111ddd111ddd111d111ddd111ddd111111111117111111111111171111711111111711171117111111711171117111111711111711117111111111111111111
ddd11ddd1ddd11ddddd11ddd1ddd11dd111111117111111111111171111711111111711171117111111711171117111111711711717117111111111111117111
dddd11dd1dd11ddddddd11dd1dd11ddd111111117111111111111171111711111111711171117111111711171117111111711711717117111111111777777711
11ddd1111111ddd111ddd1111111ddd1111111117111111111111777117771111117771777177711117771777177711111711711717117111111111111117111
d11d111ddd111d11d11d111ddd111d11111111177711111111111171111711111111711171117111111711171117111111711711717117111117111111111111
dd111ddddddd111ddd111ddddddd111d111111117111111111111111111111111111111111111111111111111111111111111711717111111177777771111111
dd11ddddddddd11ddd11ddddddddd11d111111111111111111111111111111111111111111111111111111111111111111111711117111111117111111111111
d11dddd111dddd11d11dddd111dddd11111111111111111111111111111111111111111111111111111117111111111111117771177711111111111111117111
11ddd111d111ddd111ddd111d111ddd1111111111111111111111111111111111111111111111111111777777777771111111711117111111117111177777711
1ddd11ddddd11ddd1ddd11ddddd11ddd111111111111111111111111111111111111111111111111111117111111111111111111111111111177777711117111
1dd11ddddddd11dd1dd11ddddddd11dd111111111111111111111111111111111111111111111111111111111111111111111111111111111117111111111111
1111ddd111ddd1111111ddd111ddd111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dd111d11d11d111ddd111d11d11d111dc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
dddd111ddd111ddddddd111ddd111dddc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
ddddd11ddd11ddddddddd11ddd11ddddc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
11dddd11d11dddd111dddd11d11dddd1c00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
d111ddd111ddd111d111ddd111ddd111c00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
ddd11ddd1ddd11ddddd11ddd1ddd11ddc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
dddd11dd1dd11ddddddd11dd1dd11dddc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
11ddd1111111ddd111ddd1111111ddd1c00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
d11d111ddd111d11d11d111ddd111d11c00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
dd111ddddddd111ddd111ddddddd111dc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
dd11ddddddddd11ddd11ddddddddd11dc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
d11dddd111dddd11d11dddd111dddd11c00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
11ddd111d111ddd111ddd111d111ddd1c00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
1ddd11ddddd11ddd1ddd11ddddd11dddc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000000000c
1dd11ddddddd11dd1dd11ddddddd11ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0000000000000000000000000000000011111dcba98111111111111111111111111111aaaa111111111111111111111117ddd711117ddd711111111111111111
0000000000000000000000000000000011111dcba981111111111111111111111111111aa1111111111111111111111117d1d711117d1d711111111111111111
0000000000000000000000000000000011111dcba98111116111116116111116111111aaaa111111111111111111111117ddd711117ddd711111111111111111
0000000000000000000000000000000011111dcba9811111611111611611111611111aaaaaa111111111177717771111111c11111111c1111177717771777111
0000022222222222222222222220000011111dcba9811111622222611622222611111aaaaaa111111111177717771111111c11111111c1111177717771777111
000022aaaaaaaaaaaaaaaaaaaa2200001114444444444111622222611622222611111182821111111111117111711111161c16111151c1511117111711171111
00002aa222222222222222222aa20000111ffffffffffff116222611116222611111182828211111111117771777111116ccc611115ccc511177717771777111
00002a22222222222222222222a20000111ffeefeefff1f111666111111666111111828282821111111111111111111111666111111555111111111111111111
00002a22222222222222222222a20000111ffeeeeefff1f111161111111161111118282828282111111117771777111111161111111151111177717771777111
00002a22222222222222222222a20000111ffffefffffff111161111111161111182828282828211111117771777111111666111111555111177717771777111
00002a22222282222228222222a200001111ffffffff111111161111111161111128282828282811111111711171111111ddd111111666111117111711171111
00002a2222297f222297f22222a200001144444444444411111611111111611111666666444444111111177717771111111d1111111161111177717771777111
00002a2222a777e22e777a2222a2000011ffffffffffff11116661111116661111666666444444111111111111111111111d1111155161111111111111111111
00002a22222b7d2222d7b22222a20000111ffffffffff11116666611116666611116666114444111111111111111111111ddd511555666111111111111111111
00002a222222c222222c222222a2000011111111111111111111111111111111111166111144111111111111111111111ddd1555555166611111111111111111
00002a22222222222222222222a2000011111111111111111111111111111111111666611444411111111111111111111dd11511551166611111111111111111
00002a22222222222222222222a20000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111111111111111111111111
00002a222222c222222c222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e11111222221111111111111111111111
00002a22222b7d2222d7b22222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e111122eee21111111112ee11112ee111
00002a2222a777e22e777a2222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e11122ee2e2211111112eeee112eeee11
00002a2222297f2222f7922222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e11122eeee221111112eeeeee2eeeeee1
00002a22222282222228222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e11222ee22221111112eeeeeeeeeeeee1
00002a22222222222222222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e11222ee2e221111112eeeeaaaaaeeee1
00002a22222222222222222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e112221e22211111112eeeeaaaaaeeee1
00002a22222222222222222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e112221eeeeeee11112eeeeaaaaaeeee1
00002a22222222222222222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e11222111eeeeee11112eeeeaaaeeee11
00002a22222222222222222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e1a222a1111aeeea11112eeaaaaaee111
00002a22222222222222222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e1aaaaa1111aaaaa111112eeeeeee1111
00002a22222222222222222222a20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e1aaaaa1111aaaaa1111112eeeee11111
00002aa222222222222222222aa20000e00000000000000ee00000000000000ee00000000000000ee00000000000000e11aaa111111aaa111111112eee111111
000022aaaaaaaaaaaaaaaaaaaa220000e00000000000000ee00000000000000ee00000000000000ee00000000000000e1aaaaa1111aaaaa111111112e1111111
00000222222222222222222222200000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111111111111111111111111
01111100000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
01717111000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111117771777177711
01717171011111110000000000000000111111111111111111111111111111111111111111111111177711111111777117771177711177711117171717171711
01717171017171710000000000000000111111111111111111111111111111111111111111111111171711111111717117171171711171711117771777177711
11777771117777710000000000000000111111111111111111111111111111111111111111111111177711111111777117771177711177711111711171117111
71777771177777710000000000000000111111177711111111177717771111111117771777177711117111111111171111711117111117111111711171117111
17777771177777710000000000000000111111171711111111171717171111111117171717171711117111111111171111711117111117111111711171117111
11177711111777110000000000000000111111177711111111177717771111111117771777177711117111111111171111711117111117111111111111111111
00000000000000000000000000000000111111117111111111117111711111111111711171117111111111111111111111111111111111111111111111111111
00000000000000000000000000000000111111117111111111117111711111111111711171117111111777117771111111177711777111111117771777177711
00000000000000000000000000000000111111117111111111117111711111111111711171117111111717117171111111171711717111111117171717171711
00000000000000000000000000000000111111111111111111111111111111111111111111111111111777117771111111177711777111111117771777177711
00000000000000000000000000000000111111111111111111111111111111111111111111111111111171111711111111117111171111111111711171117111
00000000000000000000000000000000111111111111111111111111111111111111111111111111111171111711111111117111171111111111711171117111
00000000000000000000000000000000111111111111111111111111111111111111111111111111111171111711111111117111171111111111711171117111
00000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000900000000000000990000000000000099000000000000009900000000000000990000000000000099000000000000009
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4041424340414243404142434041424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051525350515253505152535051525300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061626360616263606162636061626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071727370717273707172737071727300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041424340414243404142434041424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051525350515253505152535051525300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061626360616263606162636061626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071727370717273707172737071727300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041424340414243404142434041424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051525350515253505152535051525300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061626360616263606162636061626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071727370717273707172737071727300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041424340414243404142434041424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051525350515253505152535051525300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061626360616263606162636061626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071727370717273707172737071727300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

