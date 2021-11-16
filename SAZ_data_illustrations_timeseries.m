% illustrating SAZ data as a timeseries

path = 'C:\Users\cawynn\OneDrive - University of Tasmania\Documents\GitHub\saz-data-processing\netCDF\trap data';
cd(path)
%files = dir('IMOS*PARFLUX*2000m*nc');
files = dir('IMOS*PARFLUX*nc');
plotVar = 'POC_mass_flux';
% plotVar = 'Bsi_mass_flux';
% plotVar = 'PIC_mass_flux';
% plotVar = 'PC_mass_flux';
% plotVar = 'mass_flux';
data = [];

for i = 1:length(files)
    file = files(i);
    fn = [file.folder '\' file.name]
    
    var = ncread(fn,plotVar);
    var_unit = ncreadatt(fn, plotVar, 'units');
    var_name = ncreadatt(fn, plotVar, 'long_name');
    varQCname = strsplit(ncreadatt(fn, plotVar, 'ancillary_variables'), ' ');
    varQC = ncread(fn, varQCname{2});
    time = ncread(fn, 'TIME') + datetime(1950,1,1); 
    depth = ncread(fn,'NOMINAL_DEPTH');
    m = month(time);
    deployment_code_spl = strsplit(ncreadatt(fn,'/','deployment_code'),'-');
    deployment_year = deployment_code_spl{3};
    varmsk = var;
    varmsk(varQC>2)=NaN;
    
    if depth < 1050
        plot(time,varmsk,'bo','DisplayName','1000m')
        hold on
    elseif depth >1050 && depth <2050
        plot(time,varmsk, 'r*','DisplayName','2000m')
        hold on
    elseif depth >2050
        plot(time,varmsk, 'k+','DisplayName','3800m')
    end
    label=join(strsplit(plotVar,'_'), ' ');
    ylabel([label '-' var_unit])
    xlabel('Time')
    legend('1000m','2000m','3800m')               

end