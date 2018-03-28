function pmaViewer()

[A,fileName] = openFile(); %Old function used to get file id

sizeX = fread(A,1,'uint16'); %the first 16 bits of a pma file always contains the pixels on the X dimension
sizeY = fread(A,1,'uint16'); %And the next 16 bits contain the pixels along the Y dimension
frames = 0;
while ~feof(A) %Scan file quickly to see how many total frames there are
    fread(A,sizeX*sizeY,'uint8');
    frames = frames + 1;
end 
frames = frames - 1;
fseek(A,4,-1); %Go back to (almost) the beginning, 4 bytes in
movie = zeros(512,512, 1, frames,'uint8'); %for now, we assume 512x512
%frame1 is the movie data with each frame as a slice along the 3rd dimension
%Vectorized reading of file:
movie(:,:,1,:) = permute(reshape(fread(A,512*512*frames,'uint8'),512,512,frames),[2 1 3]);

mov = immovie(movie, parula);
implay(mov);



end