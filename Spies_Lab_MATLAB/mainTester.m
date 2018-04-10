addpath('Functions')

kera = Kera();
kera.gui.createPrimaryMenu('Import');
kera.gui.createSeconaryMenu('Import', 'ebFRET', @kera.ebfretAnalyze);
kera.gui.createSeconaryMenu('Import', 'QuB', @kera.qubAnalyze);
kera.gui.createSeconaryMenu('Import', 'spkg', @kera.import_spkg);
