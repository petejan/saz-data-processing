
% 'C:\Users\cawynn\cloudstor\Shared\SAZ'

clear files
% search_path = 'netCDF';
% cd(search_path)
    
% 	files{1} = 'IMOS_DWM-SOTS_CPST_20200829_SAZ47_FV01_SAZ47-22-2020-SBE37-SM-3124-2000m_END-20210426_C-20220120.nc';
%     files{2} = 'IMOS_DWM-SOTS_PT_20200815_SAZ47_FV01_SAZ47-22-2020-TDR-2050-016370-3800m_END-20210517_C-20220120.nc';
%     files{3} = 'IMOS_DWM-SOTS_AEPV_20200815_SAZ47_FV00_SAZ47-22-2020-Aquadopp-2-MHz-AQD-9820-1200m_END-20210428_C-20210513.nc';

    
    files{1} = 'netCDF\IMOS_DWM-SOTS_CPST_20230510_SAZ47_FV01_SAZ47-25-2023-SBE37-SM-4906-1000m_END-20240411_C-20240506.nc';
    files{2} = 'netCDF\IMOS_DWM-SOTS_PT_20230510_SAZ47_FV01_SAZ47-25-2023-TDR-2050-016371-2000m_END-20240412_C-20240627.nc';
    files{3} = 'netCDF\IMOS_DWM-SOTS_CPST_20230406_SAZ47_FV01_SAZ47-25-2023-SBE37-SM-4907-3800m_END-20240411_C-20240506.nc';
    %files{3} = 'netCDF\IMOS_DWM-SOTS_CPST_20220317_SAZ47_FV01_SAZ47-24-2022-SBE37-SM-2971-4500m_END-20220914_C-20230802.nc';
    files{4} = 'netCDF\IMOS_DWM-SOTS_AETVZ_20230518_SAZ47_FV01_SAZ47-25-2023-Aquadopp-Current-Meter-1200_END-20240410_C-20240702.nc';

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
figurename = ['figures\' depl '_pressure'];

%figure_path = 'figures';
% cd(figure_path)

% print(figurename, '-dpng');



