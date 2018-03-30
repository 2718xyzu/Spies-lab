function [emFret] = emulateFRET(intensity)
    maxIntensities = prctile(intensity(:),98);
    for i = 1:size(intensity,1);
        emFret2(i,:) = smoothTrace(intensity(i,:)/maxIntensities*.85);
        emFret2(i,:) = min(emFret2(i,:),1);
        oneS = emFret2(i,:)==1;
        noise = -abs(oneS.*randn(size(oneS))*.025);
        emFret2(i,:) = emFret2(i,:)+noise;
    end

    emFret = emFret2;
    answer = questdlg('Would you like to smooth the baseline (recommended to suppress low states)');
    if answer(1) == 'Y'
        figure();
        handle1 = gcf;
        histEmFRET = histogram(emFret,'BinEdges',[-Inf 0:.01:1 Inf]);
        valueS = histEmFRET.Values;
        close(handle1);
        clear histEmFREt;
        [~,maxX] = max(valueS(1:50));
        gaussFit = 'a*exp(-((x-b)/c)^2)';
        fit1 = fit((-.005:.01:(.01*(maxX+2)+.005))',valueS(1:(maxX+4))','gauss1');
        newBaseLine = fit1.b1+fit1.c1*2;
        emFret = max(emFret,newBaseLine);
        emFret = emFret + rand(size(emFret))*.005;
    end
end
