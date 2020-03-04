%% Create and save 2D error plots
%
%
%% Changes:
%           - Merged error and consistency plots
%
function PlotErr2D(data, fileName, parPlot)

algs = data.algs;
Err = data.ErrMean; % F-score
% Err = data.PreMean; % Precision 
consChk = data.consChk;
prmChk = data.prmChk;
rangeX = data.rangeX;
rangeY = data.rangeY;


XLabel = parPlot.XLabel;
YLabel = parPlot.YLabel;

idxAlg = ones(1, length(algs));
numAlg = length(algs(idxAlg));

numI = length(rangeX);
numJ = length(rangeY); 

% Color for zero error
col = ([154,205,50]+50)./ 255; % Light Green 
colG = [154,205,50]./ 255; % Dark Green
colR = [220,20,60]./ 255; % Red
colO = [255,140,0]./ 255; % Orange
colP = [148,0,211]./ 255; % Violet



%% Folder to save the figure

currentFolder   = pwd;
address         = strcat(currentFolder,'\SavedFigs\');


%% Parameters

sizeFig     = [5 4];
position    = [2 2, sizeFig];
figure('Units', 'inches', 'Position', position);
% axis equal
axis square


fontSiz = 22;
fontSiz2 = 18;
numSiz = 24;
squareSiz = 2300;


%% Adjust Font and Axes Properties

hAx = gca;

xh = diff(rangeX(1:2))/2;
yh = diff(rangeY(1:2))/2;

xlim(hAx, [rangeX(1)-xh,  rangeX(end)+xh]);
ylim(hAx, [rangeY(1)-yh,  rangeY(end)+yh]);
box on

set(hAx                          , ...
   'TickDir'     , 'out'         , ...
   'TickLength'  , [.01 .01]     , ...
   'XMinorTick'  , 'off'         , ...
   'YMinorTick'  , 'off'         , ...
   'XGrid'       , 'on'          , ...
   'YGrid'       , 'on'          , ...
   'XColor'      , [.3 .3 .3]    , ...
   'YColor'      , [.3 .3 .3]    , ...
   'ZColor'      , [.3 .3 .3]    , ...
   'XTick'       , rangeX        , ...
   'YTick'       , rangeY        , ...
   'LineWidth'   , 1.0           , ...
   'FontSize'    , fontSiz2        );


% Axis labels
hXLabel = xlabel(XLabel,'FontWeight','demi', ...
    'FontSize', fontSiz, 'Interpreter', 'latex');
hYLabel = ylabel(YLabel,'FontWeight','demi', ...
    'FontSize', fontSiz, 'Interpreter', 'latex');



%% Draw and save plot

for itr = 1 : numAlg % Result of each algorithm

% Draw plot
hold on
for i = 1 : numI
    for j = 1 : numJ
        err = Err{i,j}(itr);
        if err == 1
            colij = colG;
            coltxt = [0, 0, 0];
        else
            colij = col;
            coltxt = [0, 0, 0];
        end
        if ~consChk{i,j}(itr) % Check consistency
            colij = colR;
            coltxt = [1, 1, 1];
        end
        if ~prmChk{i,j}(itr) % Check permutation
            colij = colO;
            coltxt = [0, 0, 0];
        end        
        if (~consChk{i,j}(itr)) && (~prmChk{i,j}(itr)) % Check both consistency & permutation
            colij = colP;
            coltxt = [1, 1, 1];
        end
        
        scatter(rangeX(i),rangeY(j), squareSiz, colij, 'filled', 's');
        text(rangeX(i),rangeY(j), num2str(floor(err*100)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', numSiz, 'Interpreter', 'latex', 'Color', coltxt);
%         text(rangeX(i),rangeY(j), num2str(100-ceil(err*100)), ...
%             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
%             'FontSize', 15, 'Interpreter', 'latex', 'Color', coltxt);
    end
end
hold off


% Title
title(algs{itr}, 'FontSize', fontSiz, 'Interpreter', 'latex')


%% Save the Figs

set(gcf, 'PaperPositionMode', 'auto');
set(gcf, 'PaperUnits', 'inches', 'PaperSize', sizeFig);

% Save as Figure
fileType = '.fig';
fullAddress = strcat(address,fileName,'_',algs{itr},fileType);
saveas(gcf,fullAddress)

% Save as PDF
fileType = '.pdf';
fullAddress = strcat(address,fileName,'_',algs{itr},fileType);
saveas(gcf,fullAddress)


% Clear axes
if itr ~= numAlg, cla; end  % Do not wipe the last frame

end






























































