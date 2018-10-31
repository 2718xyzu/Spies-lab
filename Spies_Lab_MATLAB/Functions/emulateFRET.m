function [emFret] = emulateFRET(intensity)
    answer = questdlg('Which method would you like to use?', 'Method', 'Original', 'No baseline shift', 'Advanced', 'Original');
    if answer(1) == 'O'
        maxIntensities = prctile(intensity(:),98);
        emFret2 = zeros(size(intensity));
        for i = 1:size(intensity,1)
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
%             gaussFit = 'a*exp(-((x-b)/c)^2)';
            fit1 = fit((-.005:.01:(.01*(maxX+2)+.005))',valueS(1:(maxX+4))','gauss1');
            newBaseLine = fit1.b1+fit1.c1*2;
            emFret = max(emFret,newBaseLine);
            emFret = emFret + rand(size(emFret))*.005;
        end
        answer = questdlg(['Would you like to see the emulated Fret values converted '...
            'back to original levels, for comparison?']);
        if answer(1)=='Y'
            revertedFret = emFret*maxIntensities/.85;
            plotCut2(revertedFret,intensity,length(emFret),.1);
            msgbox('Comparison has been halted; program is terminating before function return (this is normal)');
            endNow = 1;
            assert(~endNow);
        end

    elseif answer(1)=='N'
        baselineSelect = zeros([1,size(intensity,1)]);
        baseline((size(intensity,1))).Values = 0;
        for i = 1:size(intensity,1)
            figure();
            plot(intensity(i,:));
            title(['Trace ' num2str(i)]);
            goOn = emFretUi;
            if isfield(goOn,'xValues')
                x = round(goOn.xValues);
            end
            switch goOn.Value
                case 10
                    continue
                case 6
                    break
                case 3
                    baselineSelect(i) = 1;
                    try
                        baseline(i).Values = intensity(i,x(1):x(2));
                    catch
                        baseline(i).Values = intensity(i,x(1):end);
                    end
            end     
        end
        emFret = zeros(size(intensity));
        for i = 1:size(intensity,1)
            if ~baselineSelect(i)
                continue
            end
            clear smoothedBase;
            smoothedBase = smoothTrace(baseline(i).Values);
            meaN = mean(smoothedBase);
            stDev = std(smoothedBase);
            atBaseline = diff(smoothTrace(intensity(i,:))<(meaN+2*stDev));
            boundaries = find(atBaseline);
            if length(boundaries)<1
                emFret(i,:) = .85*smoothTrace(intensity(i,:))./prctile(intensity(i,:),98);
                continue
            elseif length(boundaries)==1
                intensity(i,:) = [smoothTrace(intensity(i,1:boundaries)) smoothTrace(intensity(i,(boundaries+1):end))];
                emFret(i,:) = .85*intensity(i,:)./prctile(intensity(i,:),98);
                continue
            end
            intensity(i,1:boundaries(1)) = smoothTrace(intensity(i,1:boundaries(1)));
            for j = 1:length(boundaries)-1
                intensity(i,boundaries(j)+1:boundaries(j+1)) = smoothTrace(intensity(i,boundaries(j)+1:boundaries(j+1)));
            end
            intensity(i,boundaries(end)+1:end) = smoothTrace(intensity(i,boundaries(end)+1:end));
            emFret(i,:) = .85*intensity(i,:)./prctile(intensity(i,:),98);
        end
    else
        
    end
        
end
