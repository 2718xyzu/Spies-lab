function interpretation = parseTransitionState(expr, channels, stateList)
exprClean = regexprep(expr,'[?<=]',' ');
exprClean = regexprep(exprClean,' +',' ');
interpretation = ['[' exprClean ']'];

end