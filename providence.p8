pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
function new_backdrop()
	local backdrop = {y = 0}

 function backdrop:update()
	local speed = wav(gt,0.7,98)
 	self.y += speed
 end

 function backdrop:draw()
 	cls()
		map(16,0,0,0,16,16)
		map(32,0,0,-64+self.y,16,32)
		map(0,16,64+self.y,64,16,2)
		map(0,16,-64-self.y,64,16,2)
		map(0,0,0,0,16,16)
	end

 return backdrop
end

function _init()
	palt(0,false)
	palt(14,true)
	gt = 0
	backdrop = new_backdrop()
end

function _update()
	gt += 1
	backdrop:update()
end

function wav(val,amp,len)
	return amp*sin(val/len)
end

function _draw()
	backdrop:draw()
	spr(10,40,-2+wav(gt+40,2.98,98),6,4)
	spr(006,48,3+wav(gt,1.28,98),4,4)
end
__gfx__
000000002222222222222222eeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11dddddddddd116666666666666666666666661111dd11e
000000002fffffffffffffffeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeee111ddddddddd116666666666666666666661111ddddd11
007007002f4444444444444feeeeeee0f0eeeeeeeeeeeeeeeeeeeeeeeeeeee0990eeeeeeeeeeeeeeeee1111dddddddd116666666666666666611111dddddddd1
000770002f4444444444444feeeeeee0f0eeeeeeeeeeeeeeeeeeeeeeeeeee09aa90eeeeeeeeeeeeeeeee11111ddddddd116666666666666661111dddddddd111
000770002f4444444444444feeeeee0f4f0eeeeeeeeeeeeeeeeeeeeeeeeee09aa90eeeeeeeeeeeee11e11661111dddddd111666666666661111dddddddd1111e
007007002f4444444444444feeeeee0f4f0eeeeeeeeeeeeeeeeeeeeeeeee09aaaa90eeeeeeeeeeee1d116666611111ddddd11666666661111dddddddd1111eee
000000002f4444444444444feeeee0f444f0eeeeeeeeeeeeeeeeeeeeeeee09aaaa90eeeeeeeeeeee1d1166666661111ddddd11166611111dddddddd1116111ee
000000002fffffffffffffffeeeee0fffff0eeeeeeeeeeeeeeeeeeeeeee09aaaaaa90eeeeeeeeeee1dd11666666611111dddd1111111ddddddddd11166661d1e
22222222eeee022222220eeeeeee022222220eee24242424eeeeeeeeeee09aaaaaa90eeeeeeeeeee1dd1111666666661111dddd111ddddddddd1111666661dd1
ffffffffeeee0fff2fff0eeeeeee0fffffff0eee42424242eeeeeeeeee09aaaaaaaa90eeeeeeeeee11ddd111166666666111ddddddddddddd1111166666611d1
44444444eee0f44f2f44f0eeeee0f4444444f0ee24242424eeeeeeeeee09aaaaaaaa90eeeeeeeeeee1ddddd11116666666611dddddddddd11116666666611dd1
44444444eee0f44f2f44f0eeeee0f4444444f0ee42424242eeeeeeeee09aaaaaaaaaa90eeeeeeeeee11dddddd1111666666611dddddd1111166666666111ddd1
44444444ee0f444f2f444f0eee0f444444444f0e24242424eeeeeeeee09aaaaaaaaaa90eeeeeeeeeee1dddddddd1111666666111ddd1111666666661111dddd1
44444444ee0f444f2f444f0eee0f444444444f0e42424242eeeeeeee09aaaaaaaaaaaa90eeeeeeeeee111dddddddd1111666661111111666666661111ddddd11
44444444e0f4444f2f4444f0e0f44444444444f024242424eeeeeeee09aaaaaaaaaaaa90eeeeeeeeeee1111ddddddd1111166661111666666661111ddddddd11
ffffffffe0ffffff2ffffff0e0fffffffffffff042424242eeeeeee09aaaaaaaaaaaaaa90eeeeeeeeeee11111ddddddd1111166116666666611111ddddddd111
d6d6d6d6d6d6d6d606d6d6d6022222220222222200000000eeeeeee09aaaaaaaaaaaaaa90eeeeeeee11e1161111dddddddd1111116666661111dddddddd1111e
2fffffffffffffff0fffffff0fffffff0fffffff00000000eeeeee09aaaaa111111aaaaa90eeeeee1d111666611111ddddddd111166661111dddddddd111eeee
2f4444444444444ff444444ff4444444f444444f10001000eeeeee0aaaa1111111111aaaa0eeeeee1d1166666661111dddddddd11661111dddddddd1111eeeee
2f4444444444444ff444444ff4444444f444444f01010101eeeee09aa11117cccc71111aa90eeeee1dd11666666661111dddddd111111ddddddd1111111eeeee
2f4444444444444f4444444f444444444444444f10101010eeeee09a11177cc00cc77111a90eeeee1dd1111666666611111dddd1111dddddddd111166611eeee
2f4444444444444f4444444f444444444444444fd101d101eeee09a117777c0700c777711a90eeee11ddd11116666666611111d11dddddddd11116666661eeee
2f4444444444444f4444444f444444444444444f1d1d1d1deeee09a177777c0000c777771a90eeeee1ddddd111116666661111111dddddd11116666666611111
2fffffffffffffffffffffffffffffffffffffff01d101d1eee09aaa17777cc00cc77771aaa90eeee11dddddd1111666666661111dd111111666666666666661
161116111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1d1d1d1deee09aaaa11777cccc77711aaaa90eeeee1dddddddd1111666661111111111166666666166666661
111d111d1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed101d101ee09aaaaaaa1177777711aaaaaaa90eeee111dddddddd11111611eeeeee11666666661111666611e
1d111d111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1d1d1d1dee09aaaaaaaaa111111aaaaaaaaa90eeeee1111dddddddd11111eeeeeeee1166666111eee1111eee
111611161eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed1d1d1d1e09aaaaaaaaaaaaaaaaaaaaaaaaaa90eeeeee1111dddddddd1eeeeeeeeeeee11611eeeeeeeeeeeee
161116111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1d1d1d1de09aaaaaaaaaaaaaaaaaaaaaaaaaa90eeeeeeeee111ddddd1eeeeeeeeeeeeee1111eeeeeeeeeeeee
111d111d1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000009aaaaaaaaaaaaaaaaaaaaaaaaaaaa90eeeeeeeeee111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1d111d111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddd09999999999999999999999999999990eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
111611161eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777700000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777770000000000500000000000050000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000
07777777777777000050000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000
07777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777700000000000050000006000050000000000000000060000000000000000000000000000000000000000000000000000000000000000000000
77777777777777700000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777700500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777700000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777700000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777777777000000000000000000000000000500000000000000000500000000000000000000000000000000000000000000000000000000000000000000
07777777777777000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777770000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777700000060000000000000007000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777770000000000000000500000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000004600000000000000000053000045000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000043004343000000000000004500404100000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000055465253000000000000000000505100000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000043440000540000000000000053450057000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000465355000000000000004544574344000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000042000044000000000000004600465354000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003222021202120040000000052544557000000000000000043000045000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011010201020102120000000057000000000000000000000000570000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000323020102010201100400000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001302010201020102011400000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000032401020102010201020104000015151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000110102010201020102010212000015151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003230201020102010201020110040015151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013020102010201020102010201140015151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0324010201020102010201020102010415151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1101020102010201020102010201021215151515151515151515151515151515000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2525252525252525252525252525252525252525250000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3535353535353535353535353535353535353535350000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000030303030303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000