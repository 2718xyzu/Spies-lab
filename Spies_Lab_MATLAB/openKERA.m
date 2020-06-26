lastwarn('');
addpath('Functions');
[warnMsg, warnId] = lastwarn;
if ~isempty(warnMsg)
    questdlg(['Functions directory not found; please select the Spies-lab '...
        'scripts directory to add it to the search path'],'Select search dir',...
    'Ok','Ok');
    cd(uigetdir);
    addpath('Functions');
end

kera = Kera();
kera.gui.createPrimaryMenu('Import');
kera.gui.createSecondaryMenu('Import', 'ebFRET', @kera.ebfretImport);
kera.gui.createSecondaryMenu('Import', 'QuB', @kera.qubImport);
kera.gui.createSecondaryMenu('Import', 'Hammy', @kera.haMMYImport);
kera.gui.createSecondaryMenu('Import', 'spkg', @kera.importSPKG);

kera.gui.createPrimaryMenu('Export');
kera.gui.createSecondaryMenu('Export', 'spkg', @kera.exportSPKG);
kera.gui.createSecondaryMenu('Export', 'Analyzed Data');
kera.gui.createSecondaryMenu('Analyzed Data', 'csv', @kera.exportAnalyzed);
kera.gui.createSecondaryMenu('Export', 'State Dwell Summary');
kera.gui.createSecondaryMenu('State Dwell Summary', 'csv', @kera.exportStateDwellSummary);

kera.gui.createPrimaryMenu('Analyze');
kera.gui.createSecondaryMenu('Analyze', 'View Data', @kera.viewTraces);
kera.gui.createSecondaryMenu('Analyze', 'Run Analysis', @kera.processDataStates);
kera.gui.createSecondaryMenu('Analyze','Custom Search', @kera.customSearch);

kera.gui.createPrimaryMenu('Settings');
kera.gui.createSecondaryMenu('Settings','Set channels and states', @kera.setChannelState);
kera.gui.createSecondaryMenu('Settings','Set time step', @kera.setTimeStep);
kera.gui.createSecondaryMenu('Settings','Set baseline state', @kera.setBaselineState);


kera.gui.disable('Export');
kera.gui.disable('Analyze');
