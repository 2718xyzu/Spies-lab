addpath('Functions')

kera = Kera();
kera.gui.createPrimaryMenu('Import');
kera.gui.createSeconaryMenu('Import', 'ebFRET', @kera.ebfretAnalyze);
kera.gui.createSeconaryMenu('Import', 'QuB', @kera.qubAnalyze);
kera.gui.createSeconaryMenu('Import', 'spkg', @kera.importSPKG);

kera.gui.createPrimaryMenu('Export');
kera.gui.createSeconaryMenu('Export', 'spkg', @kera.exportSPKG);
kera.gui.createSeconaryMenu('Export', 'Analyzed Data');
kera.gui.createSeconaryMenu('Analyzed Data', 'csv', @kera.exportAnalyzed);
kera.gui.createSeconaryMenu('Export', 'State Dwell Summary');
kera.gui.createSeconaryMenu('State Dwell Summary', 'csv', @kera.exportStateDwellSummary);
kera.gui.disable('Export');
