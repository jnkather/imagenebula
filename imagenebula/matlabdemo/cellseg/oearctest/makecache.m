% This script creates several common arc oe filter kernels and cache it

for r = 5 : 30
	for theta = 0 : pi /36 : 2 * pi
		for dev = 0 : 2
			for hil = 0 : 1
				f = filteroearccache([5 1], r, 5, theta, dev, hil);
				disp([r theta dev hil]);
			end
		end
	end
end