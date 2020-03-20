addpath('Functions')

kera = Kera();
kera.gui.createPrimaryMenu('Import');
kera.gui.createSecondaryMenu('Import', 'ebFRET', @kera.ebfretAnalyze);
kera.gui.createSecondaryMenu('Import', 'QuB', @kera.qubAnalyze);
kera.gui.createSecondaryMenu('Import', 'spkg', @kera.importSPKG);

kera.gui.createPrimaryMenu('Export');
kera.gui.createSecondaryMenu('Export', 'spkg', @kera.exportSPKG);
kera.gui.createSecondaryMenu('Export', 'Analyzed Data');
kera.gui.createSecondaryMenu('Analyzed Data', 'csv', @kera.exportAnalyzed);
kera.gui.createSecondaryMenu('Export', 'State Dwell Summary');
kera.gui.createSecondaryMenu('State Dwell Summary', 'csv', @kera.exportStateDwellSummary);

kera.gui.createPrimaryMenu('Settings');
kera.gui.createSecondaryMenu('Settings','Set time step', @kera.setTimeStep);
kera.gui.createSecondaryMenu('Settings','Set baseline state', @kera.setBaselineState);

kera.gui.disable('Export');
