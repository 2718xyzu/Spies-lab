% 2006 Author Hideaki Shimazaki
% Department of Physics, Kyoto University
% shimazaki at ton.scphys.kyoto-u.ac.jp
% Please feel free to use/modify this program.

%Modified for use in KERA by Joseph Tibbs, located in the 2718xyzu Github
%repository

function binEdges = shimazakiHistBins(x)
x_min = min(x);
x_max = max(x);

N_MIN = 4;              % Minimum number of bins (integer)
                        % N_MIN must be more than 1 (N_MIN > 1).
N_MAX = 50;             % Maximum number of bins (integer)

N = N_MIN:N_MAX;                      % # of Bins
D = (x_max - x_min) ./ N;             % Bin Size Vector


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation of the Cost Function
for i = 1: length(N)
	edges = linspace(x_min,x_max,N(i)+1);	% Bin edges

	ki = histcounts(x,edges);            % Count # of events in bins
	ki = ki(1:end-1);

	k = mean(ki);                   % Mean of event count
	v = sum( (ki-k).^2 )/N(i);      % Variance of event count

	C(i) = ( 2*k - v ) / D(i)^2;    % The Cost Function

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimal Bin Size Selectioin
[Cmin,idx] = min(C);
optD = D(idx);                         % *Optimal bin size
binEdges = linspace(x_min,x_max,N(idx)+1);  

end