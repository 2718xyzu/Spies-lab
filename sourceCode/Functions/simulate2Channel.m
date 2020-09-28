N = 10; %number of traces to create
lengthTrace = 1000; %length of each trace in time points
cy3Final = cell([N 1]);
cy5Final = cell([N 1]);
cy3QuB = cell([N 1]);
cy5QuB = cell([N 1]);
s3 = 3; %the number of states in the cy3 model
s5 = 2; %the number of states in the cy5 model
t = 1/30; %some parameters to control how fast events tend to happen
t2 = 1/50;
transition_matrix3 = cat(3, [ 1-t, t, 0; t, 1-2*t, t ; 0, t, 1-t],...   %the transition matrix of cy3 iff cy5 is in state 1
                            [ 1-2*t t t; .5*t  1-2*t 1.5*t ; 0 t 1-t]); % "     " iff cy5 is in state 2
transition_matrix5 = cat(3, [ 1-t2 t2; t2 1-t2], ... %the transition matrix of cy5 iff cy3 is in state 1
                            [ 1-2*t2 2*t2; t2 1-t2],... % "    " in state 2
                            [ 1-t2 t2; 3*t2 1-3*t2]); % "     " in state 3
                        

markovCell = cell([s3,s5]);

for i = 1:s3
    for j = 1:s5
        for i2 = 1:s3
            for j2 = 1:s5
                markovCell{i,j}(i2,j2) = transition_matrix3(i,i2,j)*transition_matrix5(j,j2,i);
            end
        end
    end
end


for i = 1:N
    cy3 = zeros([1 lengthTrace]);
    cy5 = zeros([1 lengthTrace]);
    cy3(1) = randi(s3);
    cy5(1) = randi(s5);
    cy3Q = zeros([1 2]);
    cy5Q = zeros([1 2]);
    row3 = 1;
    row5 = 1;
    time3 = 1;
    time5 = 1;
    for j = 2:lengthTrace
        prob3 = markovCell{cy3(j-1),cy5(j-1)};
        accept = 0;
        while ~accept %Monte Carlo on the probabilities of transition
            val3 = randi(s3);
            val5 = randi(s5);
            test = prob3(val3,val5);
            accept = rand<test;
        end
        if val3==cy3(j-1) && j<lengthTrace
            time3 = time3+1;
        else
            cy3Q(row3,:) = [cy3(j-1) time3];
            time3 = 1;
            row3 = row3+1;
        end
        if val5==cy5(j-1) && j<lengthTrace
            time5 = time5+1;
        else
            cy5Q(row5,:) = [cy5(j-1) time5];
            time5 = 1;
            row5 = row5+1;
        end
        cy3(j) = val3;
        cy5(j) = val5;
    end
    cy3Q(row3,:) = [cy3(j-1) time3];
    cy5Q(row5,:) = [cy5(j-1) time5];
    cy3Final{i} = cy3./s3+randn(size(cy5))/40;
    cy5Final{i} = cy5./s5+randn(size(cy5))/40;
    cy3QuB{i} = cy3Q;
    cy5QuB{i} = cy5Q;
end
filenames = cell([1 N]);
for i = 1:N
    filenames{i} = num2str(i);
end

saveebFRET = 0;
if saveebFRET
    saveEmFret(cy3Final,1, filenames); %save the cy3 traces
    saveEmFret(cy5Final,2, filenames); %save the cy5 traces
end

saveQuB = 0;
if saveQuB
    
    for channel = 1:2
        [~] = questdlg(['Please select a directory (or make a new one) in which to save traces in channel ',...
            num2str(channel) 'in the QuB format'], 'Select Directory','Ok','Ok');
        saveDir = uigetdir;
        if ~isfolder(saveDir)
            errordlg('Directory not found.  Using default directory');
            saveDir = [];
        end
        for i = 1:N
            switch channel
                case 1
                    saveMatrix = cy3QuB{i};
                case 2
                    saveMatrix = cy5QuB{i};
            end
            save(([saveDir filesep '1 tr' filenames{i} '_c' num2str(channel) '.dwt']),'saveMatrix','-ascii');
        end
    end
end

savehFRET = 1;
if savehFRET
    cy3Save = cell2mat(cy3Final)';
    save('/Users/josephtibbs/Desktop/cy3Save.dat','-ascii');
end