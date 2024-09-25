% illustrating SAZ data month by month

path = 'C:\Users\wyn028\OneDrive - CSIRO\Documents\GitHub\saz-data-processing';
cd(path)
%files = dir('IMOS*PARFLUX*2000m*nc');
files = dir('IMOS*PARFLUX*nc');
% plotVar = 'POC_mass_flux';
% plotVar = 'BSi_mass_flux';
% plotVar = 'PIC_mass_flux';
% plotVar = 'PC_mass_flux';
% plotVar = 'mass_flux';
plotVariables = {'POC_mass_flux','BSi_mass_flux','PIC_mass_flux',...
'PC_mass_flux','mass_flux'};

for v = 1:length(plotVariables)
    plotVar = plotVariables{v}
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
        time_length = length(time);
        m = month(time);
        deployment_code_spl = strsplit(ncreadatt(fn,'/','deployment_code'),'-');
        deployment_year = deployment_code_spl{3};
        varmsk = var;
        varmsk(varQC>2)=NaN;
        
        if time_length ==21
            for t = 1:21
                data(end+1,m(t))=varmsk(t);
            end
        else
           for t = 1:13
                data(end+1,m(t))=varmsk(t);
           end
        end
    end
    data(data==0) = NaN;
    
    figure(5)
    boxchart(data)
    xlabel('Month')
    label=join(strsplit(plotVar,'_'), ' ');
    ylabel([label '-' var_unit])
    
    print(figure(5), '-dpng', ['SAZ-' var_name '-boxchart.png'] , '-r600');
end    

