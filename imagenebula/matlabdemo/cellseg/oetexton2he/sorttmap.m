d = zeros(16, 1);
for i = 1 : 16
	mask = (tmap == i);
	mask2 = (mask & (gt > 0));
	d(i) = numel(find(mask2>0)) / numel(find(mask>0));
	disp([i, d(i)]);
end

[d, idx] = sort(d);

disp(d);
disp(idx);


newmask = zeros(size(tmap));
for i = 1 : 16;
	newmask(tmap==idx(i)) = i;
end

imagesc(newmask);