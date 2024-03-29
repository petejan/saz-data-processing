
% 'C:\Users\cawynn\cloudstor\Shared\SAZ'

clear files
search_path = 'C:\Users\cawynn\OneDrive - University of Tasmania\Documents\GitHub\saz-data-processing\netCDF';
cd(search_path)
    
% 	files{1} = 'IMOS_DWM-SOTS_CPST_20200829_SAZ47_FV01_SAZ47-22-2020-SBE37-SM-3124-2000m_END-20210426_C-20220120.nc';
%     files{2} = 'IMOS_DWM-SOTS_PT_20200815_SAZ47_FV01_SAZ47-22-2020-TDR-2050-016370-3800m_END-20210517_C-20220120.nc';
%     files{3} = 'IMOS_DWM-SOTS_AEPV_20200815_SAZ47_FV00_SAZ47-22-2020-Aquadopp-2-MHz-AQD-9820-1200m_END-20210428_C-20210513.nc';

    
    files{1} = 'IMOS_DWM-SOTS_CPST_20210401_SAZ47_FV01_SAZ47-23-2021-SBE37-SM-4906-1000m_END-20220513_C-20220527.nc';
    files{2} = 'IMOS_DWM-SOTS_PT_20210416_SAZ47_FV01_SAZ47-23-2021-TDR-2050-016371-2000m_END-20220401_C-20220530.nc';
    files{3} = 'IMOS_DWM-SOTS_CPST_20210401_SAZ47_FV01_SAZ47-23-2021-SBE37-SM-4907-3800m_END-20220513_C-20220527.nc';
    files{4} = 'IMOS_DWM-SOTS_AETVZ_20210424_SAZ47_FV01_SAZ47-23-2021-Aquadopp-Current-Meter-AQD-9897-1200m_END-_C-20220530.nc';

dep_start = ncreadatt(files{1}, '/', 'time_deployment_start');
dep_end = ncreadatt(files{1}, '/', 'time_deployment_end');

datetime_start = datetime(dep_start, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''');
datetime_end = datetime(dep_end, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''');
    
figure (1); clf; hold on
axis 'ij'; grid on

format short g

fileno = 1;
for fn = files

    file = fn{1};
    disp(file);
    
    try
        pres = ncread(file, 'PRES');
    catch
        pres = ncread(file, 'PRES_REL');
    end
    time = ncread(file, 'TIME') + datetime(1950,1,1);
    instrument = ncreadatt(file, '/', 'instrument');
    
    msk = time > datetime_start & time < datetime_end;
      
    mn = mean(pres(msk));
    md = mode(pres(msk));
    
    plot(time(msk), pres(msk), 'DisplayName', sprintf('mode pres %4.0f %s' ,md,instrument));
    
    disp([mn md])

    %cur = sqrt(ncread(file, 'UCUR').^2 + ncread(file, 'VCUR').^2);
    %legend('Orientation','vertical','Location','bestoutside')
    legend('Location','best')
end
depl = ncreadatt(files{1},'/','deployment_code');

fig = figure(1);
figurename = [depl '_pressure'];

figure_path = 'C:\Users\cawynn\OneDrive - University of Tasmania\Documents\GitHub\saz-data-processing\figures';
cd(figure_path)

print(figurename, '-dpng');



