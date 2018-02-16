x = NaN(4,1);
y = NaN(4,1);

[x(1),y(1)] = ginput(1);
line(x(:),y(:),'Marker','+','LineStyle','none')
[x(2),y(2)] = ginput(1);
line(x(:),y(:),'Marker','+','LineStyle','none')
[x(3),y(3)] = ginput(1);
line(x(:),y(:),'Marker','+','LineStyle','none')
[x(4),y(4)] = ginput(1);
line(x(:),y(:),'Marker','+','LineStyle','none')

display(x)
display(y)

ys = sort(y);
Top = mean(ys(1:2));
Bot = mean(ys(3:4));

xs = sort(x);
Lef = mean(xs(1:2));
Rgt = mean(xs(3:4));

ParamSave.Scale = [(Rgt-Lef)/10,(Bot-Top)/7];
ParamSave.Center = [(Rgt+Lef)/2,(Bot+Top)/2];

save([Name,'.mat'],'ParamSave');
Display