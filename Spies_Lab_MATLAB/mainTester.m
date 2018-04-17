addpath('Functions')

kera = Kera();
kera.gui.createPrimaryMenu('Import');
kera.gui.createSeconaryMenu('Import', 'ebFRET', @kera.ebfretAnalyze);
kera.gui.createSeconaryMenu('Import', 'QuB', @kera.qubAnalyze);
kera.gui.createSeconaryMenu('Import', 'spkg', @kera.importSPKG);

kera.gui.createPrimaryMenu('Analysis');
kera.gui.createSeconaryMenu('Analysis', 'Histogram', @kera.histogramData);
kera.gui.toggle('Analysis');

kera.gui.createPrimaryMenu('Export');
kera.gui.createSeconaryMenu('Export', 'spkg', @kera.exportSPKG);
kera.gui.createSeconaryMenu('Export', 'Output');
kera.gui.createSeconaryMenu('Output', 'csv', @kera.exportOutput);
kera.gui.createSeconaryMenu('Output', 'Matlab variable', @kera.exportOutput);
kera.gui.createSeconaryMenu('Export', 'State Dwell Summary');
kera.gui.createSeconaryMenu('State Dwell Summary', 'csv', @kera.exportStateDwellSummary);
kera.gui.createSeconaryMenu('State Dwell Summary', 'Matlab variable', @kera.exportStateDwellSummary);
kera.gui.toggle('Export');
