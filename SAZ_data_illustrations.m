% illustrating SAZ data month by month

path = 'C:\Users\cawynn\OneDrive - University of Tasmania\Documents\GitHub\saz-data-processing\netCDF';
cd(path)
files = dir('IMOS*PARFLUX*2000m*nc');
plotVar = 'POC_mass_flux';
% plotVar = 'Bsi_mass_flux';
% plotVar = 'PIC_mass_flux';
% plotVar = 'PC_mass_flux';
% plotVar = 'mass_flux';
data = [];

for i = 1:length(files)
    file = files(i);
    fn = [file.folder '\' file.name]
    
    %plotVar = 'POC_mass_flux';
    
    var = ncread(fn,plotVar);
    var_unit = ncreadatt(fn, plotVar, 'units');
    var_name = ncreadatt(fn, plotVar, 'long_name');
    varQCname = strsplit(ncreadatt(fn, plotVar, 'ancillary_variables'), ' ');
    varQC = ncread(fn, varQCname{2});
    time = ncread(fn, 'TIME') + datetime(1950,1,1); 
    m = month(time);
    deployment_code_spl = strsplit(ncreadatt(fn,'/','deployment_code'),'-');
    deployment_year = deployment_code_spl{3};
    varmsk = var;
    if varQC>2
        isnan(varmsk)
    end
          
    for t = 1:21
        data(end+1,m(t))=varmsk(t);
    end
end
data(data==0) = NaN;

figure()
boxchart(data)
xlabel('Month')
label=join(strsplit(plotVar,'_'), ' ');
ylabel([label '-' var_unit])
    