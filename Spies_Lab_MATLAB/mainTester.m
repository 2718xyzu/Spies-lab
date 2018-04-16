addpath('Functions')

kera = Kera();
kera.gui.createPrimaryMenu('Import');
kera.gui.createSeconaryMenu('Import', 'ebFRET', @kera.ebfretAnalyze);
kera.gui.createSeconaryMenu('Import', 'QuB', @kera.qubAnalyze);
kera.gui.createSeconaryMenu('Import', 'spkg', @kera.import_spkg);

kera.gui.createPrimaryMenu('Analysis');
kera.gui.createSeconaryMenu('Analysis', 'Histogram', @kera.histogramData);

kera.gui.createPrimaryMenu('Export');
kera.gui.createSeconaryMenu('Export', 'spkg', @kera.export_spkg);
kera.gui.createSeconaryMenu('Export', 'Output');
kera.gui.createSeconaryMenu('Output', 'csv', @kera.export_output);
kera.gui.createSeconaryMenu('Output', 'Matlab variable', @kera.export_output);
kera.gui.createSeconaryMenu('Export', 'State Dwell Summary');
kera.gui.createSeconaryMenu('State Dwell Summary', 'csv', @kera.export_stateDwellSummary);
kera.gui.createSeconaryMenu('State Dwell Summary', 'Matlab variable', @kera.export_stateDwellSummary);