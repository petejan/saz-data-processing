
%file = 'data/IMOS_ABOS-SOTS_AETVZ_20120718T050000Z_SAZ47_FV01_SAZ47-15-2012-Aquadopp-CUR_MAGrent-Meter-1215_END-20131008T200000Z_C-20140826T061918Z.nc';
%file = 'data/IMOS_ABOS-ASFS_EVZ_20150322T001500Z_SOFS_FV01_SOFS-5-2015-Sea-Guard-200_END-20160420T041501Z_C-20161023T042146Z.nc';
%file = 'data/IMOS_ABOS-ASFS_EVZ_20150322T001500Z_SOFS_FV01_SOFS-5-2015-Sea-Guard-800_END-20160420T040000Z_C-20161023T042334Z.nc';

file = 'netCDF/IMOS_DWM-SOTS_AEPV_20220501_SAZ47_FV00_SAZ47-24-2022-Aquadopp-2-MHz-AQD-9882-1215m_END-20230530_C-20230727.nc';

%file = 'IMOS_DWM-SOTS_AETVZ_20180303_SAZ47_FV01_SAZ47-20-2018-Aquadopp-Current-Meter-AQD-5961-1200m_END-20190322_C-20190719.nc';

ttl = ncreadatt(file, '/', 'deployment_code');
dpt = ncreadatt(file, '/', 'instrument_nominal_depth');
inst = ncreadatt(file, '/', 'instrument');

TIME = ncread(file, 'TIME') + datenum(1950,1,1);

VCUR = ncread(file, 'VCUR_MAG');
%qc_v = ncreadatt(file, 'VCUR_MAG', 'ancillary_variables');
%VCUR_qc = ncread(file, qc_v);
UCUR = ncread(file, 'UCUR_MAG');
%qc_u = ncreadatt(file, 'UCUR_MAG', 'ancillary_variables');
%UCUR_qc = ncread(file, qc_u);

roll = ncread(file, 'ROLL');
pitch = ncread(file, 'PITCH');
tilt=acosd(cosd(roll).*cosd(pitch));

cspd = sqrt(VCUR.^2 + UCUR.^2);

figure(1)
edges = 0:0.001:0.4;
%N = histcounts(cspd(VCUR_qc<=1), edges, 'Normalization', 'cdf');
% using FV00 file, which hasn't run through the IMOS tool box
N = histcounts(cspd, edges, 'Normalization', 'cdf');
plot(edges(1:end-1),N)
current_90_idx = find(N>0.9,1);
current_90 = edges(current_90_idx);

% histogram(cspd(cspd_qc==0), 'DisplayStyle', 'stair', 'Normalization', 'cdf'); 

grid on; title(sprintf('%s @ %4.0f m : 90 current %4.3f m/s',  ttl, dpt, current_90));
ylabel('cumulative probability'); xlabel('current (m/s)');

figure(4)

edg_tilt = 0:0.2:20;
%Ntilt = histcounts(tilt(VCUR_MAG_qc<=1), edg_tilt, 'Normalization', 'pdf');
% FV00 file
%Ntilt = histcounts(tilt(VCUR_qc<=1), edg_tilt, 'Normalization', 'probability');
Ntilt = histcounts(tilt, edg_tilt, 'Normalization', 'probability');


plot(edg_tilt(1:end-1), Ntilt);
ylabel('probability'); xlabel('tilt (deg)');
xlim([0 8]);

grid(); title(sprintf('%s : %s @ %4.0f m',  ttl, inst, dpt))

figure(5);
%plot(TIME(VCUR_qc<=1), cspd(VCUR_qc<=1)); grid on; datetick('x', 'keeplimits');
% FV00 file
plot(TIME, cspd); grid on; datetick('x', 'keeplimits');
title(sprintf('%s : %s @ %4.0f m',  ttl, inst, dpt))
ylabel('current (m/s)');

figures = findall(0,'type','figure'); 
for f = 1:numel(figures)
      fig = figures(f);
      filename = sprintf('SAZ47-23-current-1200m-Figures.ps');
      print( fig, '-dpsc2', filename, '-append');
end

