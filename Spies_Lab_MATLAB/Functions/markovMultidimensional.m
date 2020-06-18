function final = markovMultidimensional(start, markovMat)
s3 = size(markovMat,1);
s5 = size(markovMat,2);
startExpand = repmat(start,[1,1,s3,s5]);
startPermute = permute(startExpand,[3,4,1,2]);
startMult = startPermute.*markovMat;
final = sum(sum(startMult,4),3);

end