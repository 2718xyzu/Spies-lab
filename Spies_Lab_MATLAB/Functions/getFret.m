%Joseph Tibbs
%Last updated 6/12
function traceFret = getFret(traceD,traceA)
traceFret = traceA./(traceD+traceA);
end