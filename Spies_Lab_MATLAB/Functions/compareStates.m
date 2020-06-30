function out = compareStates(vec1, vec2)
out = 1;
if ~all(vec1(~isnan(vec1))==vec2(~isnan(vec1)))
    out = 0;
end


end