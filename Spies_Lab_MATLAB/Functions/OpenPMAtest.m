close all;
A = fopen('roughtest.pma');
sizeX = fread(A,1,'uint16');
sizeY = fread(A,1,'uint16');
frame1 = zeros(512,512,100,'int8');
frame2 =  zeros(512,512,100,'int8');

for j = 1:100
    for i = 1:512
        frame1(i,:,j) = fread(A,512,'int8');
    end
end

for j = 1
    figure(j);
    image(frame1(:,:,j));
end

figure(101)
yList = squeeze(frame1(45,54,1:100));
yList2 = squeeze(frame1(46,309,1:100));
plot(1:100,yList);
hold
plot(1:100, yList2);
