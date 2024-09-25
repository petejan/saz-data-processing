%%%% Plot mass flux sediment trap data for quick look plots,
%%%% including all data, with their associated flags

files = dir('IMOS*PARFLUX*.nc');

close all;

fig = figure(1);
cl = get(groot,'defaultAxesColorOrder');

%qc_color = [[0 0 0];[0 0 1];[1 0 1];[1 0 0]];

pn = 1;
clear p
for k = 1:length(files)
    
    fn = files(k);
    file = [fn.folder '/' fn.name];
    
    plotVar = 'mass_flux';
    
    try
        var = ncread(file, plotVar);
        var_unit = ncreadatt(file, plotVar, 'units');
        var_name = ncreadatt(file, plotVar, 'long_name');

        varQCname = strsplit(ncreadatt(file, plotVar, 'ancillary_variables'), ' ');
        varQC = ncread(file, varQCname{2});

        time = ncread(file, 'TIME') + datetime(1950,1,1);
        deployment_code = ncreadatt(file, '/', 'deployment_code');
        nominal_depth = ncread(file, 'NOMINAL_DEPTH');

        timestart = datetime(ncreadatt(file, '/', 'time_deployment_start'), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''');
        timeend = datetime(ncreadatt(file, '/', 'time_deployment_end'), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''');

        % plot the data with line through good data
        p(pn) = plot(time(varQC <= 2), var(varQC <= 2),'.-','MarkerSize',5,'LineWidth',0.9,'DisplayName',num2str(nominal_depth), 'Color', cl(k,:));

        % plot the QC info
        hold on
        Q2 = plot(time(varQC == 2), var(varQC == 2), 'o', 'MarkerSize',6, 'MarkerFaceColor', cl(k,:), 'Color', cl(k, :));

        Q3 = plot(time(varQC == 3), var(varQC == 3),'d','MarkerSize',6,'MarkerFaceColor', cl(k,:), 'Color', cl(k, :));

        Q4 = plot(time(varQC == 4), var(varQC == 4),'s','MarkerSize', 6, 'MarkerFaceColor', cl(k,:), 'Color', cl(k, :));
        
        pn = pn + 1;
    catch
    end
    
end
grid on
ylabel([var_name ' (' var_unit ')'], 'Interpreter', 'none')
%t = title(['QC flag 1 = \cdot-, {\color[rgb]{', num2str(qc_color(2,:)), '}QC flag 2 = blue dots, \color[rgb]{', num2str(qc_color(3,:)), '}QC flag 3 = magenta \diamondsuit, \color[rgb]{', num2str(qc_color(4,:)), '}QC flag 4 = red \wedge}'],'Interpreter','tex');
t = title({deployment_code ;'\rmQC flag 1 = line, QC flag 2 = circle, QC flag 3 = diamond, QC flag 4 = square'},'Interpreter','tex');
set(get(get(Q2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
h= legend(p,'Orientation','horizontal','Location', 'southoutside');
set(h, 'FontSize', 10)
xlim([timestart-10 timeend+10]);
set = gca;
set.FontSize = 12;
hold off

print( fig, '-dpng', [files(1).folder '/' deployment_code '-report_plot.png'])
