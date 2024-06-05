
% read the deployment information
deployment_data = readtable('deployment-data.csv');

% read the xlsx data
data_file = '2012_saz15_47_sed_CWE_ver5.xls';
data = readtable(data_file, 'Sheet', 'netcdf_format');

deployment = data.deploymentYearStart(3);
dep_info_size = ~cellfun(@isempty,strfind(deployment_data.cmdddname, deployment));
dep_info_idx = find(dep_info_size(:,1)==1);
this_deployment = deployment_data(dep_info_idx,:);

% get some netcdf helpers
cmode = netcdf.getConstant('NETCDF4');
cmode = bitor(cmode, netcdf.getConstant('CLASSIC_MODEL'));

% get the number of samples
sample_msk = ~isnan(data.sample_qc);
len_time = sum(sample_msk);

% get metedata rows
metadata_msk = ~cellfun(@isempty, data.metadata);

% get the sample timestamp
mid_times = datetime(data.sampleMid_point(sample_msk));
open_times = datetime(data.sampleOpen(sample_msk));
close_times = datetime(data.sampleClose(sample_msk));

[B, I] = sort(mid_times);

time_fmt = 'yyyy-mm-ddTHH:MM:SSZ';

% create the netCDF file
% file name
% example IMOS_ABOS-SOTS_KF_20150410_SAZ47_FV01_SAZ47-17-2015-PARFLUX-Mark78H-21-11741-01-2000m_END-20160312_C-20171110.nc
fn = ['IMOS_ABOS-SOTS_KF_' datestr(min(mid_times), 'yyyymmdd') '_SAZ47_FV01_' deployment{1} '_PARFLUX-Mark78H-21_END-' datestr(min(mid_times), 'yyyymmdd') '_C-' datestr(datetime(), 'yyyymmdd') '.nc'];
ncid = netcdf.create(fn, cmode);

% get depth_nominal
depth_nominal = str2double(data.depth_nominal(sample_msk));

% trap serial numbers
depths = data.depth_nominal(sample_msk);
[depths_unique, depths_u_idx, m] = unique(depths);
traps = data.trap(sample_msk);
traps_max_len = max(cellfun(@(x) size(x,2), traps(depths_u_idx), 'UniformOutput', true));
traps_u = cell2mat(pad(traps(depths_u_idx)));

% add global attributes:
glob_att = netcdf.getConstant('NC_GLOBAL');
global_attrs = readtable('global_attribute_table.xlsx');

now_char = char(datetime('now','TimeZone','UTC+0','Format','y-MM-dd HH:mm:ss'));

% add variable (this file specific) attributes
var_names = {'deployment', 'name', 'type', 'value'};
glob_all = [global_attrs; cell2table({deployment, 'history', 'STRING', [now_char ' : created from ' data_file]}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'date_created', 'STRING', now_char}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'geospatial_lat_max', 'DOUBLE', str2double(this_deployment.cmdddlatitude)}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'geospatial_lat_min', 'DOUBLE', str2double(this_deployment.cmdddlatitude)}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'geospatial_lon_max', 'DOUBLE', str2double(this_deployment.cmdddlongitude)}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'geospatial_lon_min', 'DOUBLE', str2double(this_deployment.cmdddlongitude)}, 'VariableNames', var_names)];

glob_all = [glob_all; cell2table({deployment, 'geospatial_vertical_max', 'DOUBLE', max(depth_nominal)}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'geospatial_vertical_min', 'DOUBLE', min(depth_nominal)}, 'VariableNames', var_names)];

glob_all = [glob_all; cell2table({deployment, 'instrument_serial_number', 'STRING', strjoin(traps(depths_u_idx), ' ; ')}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'time_coverage_start', 'STRING', datestr(min(mid_times), time_fmt)}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'time_coverage_end', 'STRING', datestr(max(mid_times), time_fmt)}, 'VariableNames', var_names)];

glob_all = [glob_all; cell2table({deployment, 'time_deployment_start', 'STRING', datestr(this_deployment.cmddddeploymentdate(1), time_fmt)}, 'VariableNames', var_names)];
glob_all = [glob_all; cell2table({deployment, 'time_deployment_end', 'STRING', datestr(this_deployment.cmdddrecoverydate(1), time_fmt)}, 'VariableNames', var_names)];

glob_all = [glob_all; cell2table({deployment, 'deployment_code', 'STRING', this_deployment.cmdddname{1}}, 'VariableNames', var_names)];

[a, gl_idx] = sort(lower(glob_all.name));

for j = 1:size(gl_idx, 1)
    i = gl_idx(j);
    add_this = false;
    if strcmp(glob_all.deployment{i}, '*')
        add_this = true;
    elseif strcmp(glob_all.deployment{i}, deployment)
        add_this = true;
    end
    %if strcmp(glob_all.type{i}, 'STRING')
        netcdf.putAtt(ncid, glob_att, glob_all.name{i}, glob_all.value{i});
    %end
end

% add the OBS dimension, this allows the three traps to be in the one file
time_dimID = netcdf.defDim(ncid, 'OBS', len_time);

%
% add variables
%

% add the time variable
time_id = netcdf.defVar(ncid, 'TIME', 'double', time_dimID);
netcdf.putAtt(ncid, time_id, 'name', 'time');
netcdf.putAtt(ncid, time_id, 'standard_name', 'time');
netcdf.putAtt(ncid, time_id, 'long_name', 'time of measurement');
netcdf.putAtt(ncid, time_id, 'units', 'days since 1950-01-01T00:00:00 UTC');
netcdf.putAtt(ncid, time_id, 'axis', 'T');
netcdf.putAtt(ncid, time_id, 'valid_min', 10957);
netcdf.putAtt(ncid, time_id, 'valid_max', 54787.);
netcdf.putAtt(ncid, time_id, 'calendar', 'gregorian');
netcdf.putAtt(ncid, time_id, 'ancillary_variables', 'TIME_bnds');

bnds_dimID = netcdf.defDim(ncid, 'bnds', 2);

% time bounds
time_bnds_id = netcdf.defVar(ncid, 'TIME_bnds', 'double', [bnds_dimID time_dimID]);
netcdf.putAtt(ncid, time_bnds_id, 'name', 'time open, closed');
netcdf.putAtt(ncid, time_bnds_id, 'long_name', 'time sample open, closed');
netcdf.putAtt(ncid, time_bnds_id, 'units', 'days since 1950-01-01T00:00:00 UTC');
netcdf.putAtt(ncid, time_bnds_id, 'axis', 'T');
netcdf.putAtt(ncid, time_bnds_id, 'valid_min', 10957);
netcdf.putAtt(ncid, time_bnds_id, 'valid_max', 54787.);
netcdf.putAtt(ncid, time_bnds_id, 'calendar', 'gregorian');

%         byte instrument_index(OBS) ;
%                 instrument_index:long_name = "which instrument this obs is for" ;
%                 instrument_index:instance_dimension = "instrument" ;
%         char instrument_type(instrument, strlen) ;
%                 instrument_type:long_name = "deployment ; source instrument make ; model ; serial_number" ;
%         double NOMINAL_DEPTH(instrument) ;
%                 NOMINAL_DEPTH:axis = "Z" ;
%                 NOMINAL_DEPTH:long_name = "nominal depth" ;
%                 NOMINAL_DEPTH:positive = "down" ;
%                 NOMINAL_DEPTH:reference_datum = "sea surface" ;
%                 NOMINAL_DEPTH:standard_name = "depth" ;
%                 NOMINAL_DEPTH:units = "m" ;
%                 NOMINAL_DEPTH:valid_max = 12000.f ;
%                 NOMINAL_DEPTH:valid_min = -5.f ;

instance_dimID = netcdf.defDim(ncid, 'instrument', size(depths_unique, 1));
str_dimID = netcdf.defDim(ncid, 'strlen', size(traps_u, 2));

instrument_index_id = netcdf.defVar(ncid, 'instrument_index', 'byte', time_dimID);
netcdf.putAtt(ncid, instrument_index_id, 'long_name', 'which instrument this obs is for');
netcdf.putAtt(ncid, instrument_index_id, 'instance_dimension', 'instrument');

instrument_type_id = netcdf.defVar(ncid, 'instrument_type', 'char', [str_dimID, instance_dimID]);
netcdf.putAtt(ncid, instrument_type_id, 'long_name', 'deployment ; source instrument make ; model ; serial_number');
netcdf.putAtt(ncid, instrument_type_id, 'cf_role', 'timeseries_id');

nomial_depth_id = netcdf.defVar(ncid, 'NOMINAL_DEPTH', 'double', instance_dimID);
netcdf.putAtt(ncid, nomial_depth_id, 'axis', 'Z');
netcdf.putAtt(ncid, nomial_depth_id, 'long_name', 'nominal depth');
netcdf.putAtt(ncid, nomial_depth_id, 'positive', 'down');
netcdf.putAtt(ncid, nomial_depth_id, 'reference_datum', 'sea surface');
netcdf.putAtt(ncid, nomial_depth_id, 'standard_name', 'depth');
netcdf.putAtt(ncid, nomial_depth_id, 'units', 'm');
netcdf.putAtt(ncid, nomial_depth_id, 'valid_max', 12000);
netcdf.putAtt(ncid, nomial_depth_id, 'valid_min', -5);

% latitude, longitude
lat_id = netcdf.defVar(ncid, 'LATITUDE', 'double', []);
netcdf.putAtt(ncid, lat_id, 'standard_name', 'latitude');
netcdf.putAtt(ncid, lat_id, 'long_name', 'latitude of anchor');
netcdf.putAtt(ncid, lat_id, 'units', 'degrees_north');
netcdf.putAtt(ncid, lat_id, 'axis', 'Y');
netcdf.putAtt(ncid, lat_id, 'valid_min', -90);
netcdf.putAtt(ncid, lat_id, 'valid_max', 90);
netcdf.putAtt(ncid, lat_id, 'reference_datum', 'WGS84 coordinate reference system') ;
netcdf.putAtt(ncid, lat_id, 'coordinate_reference_frame', 'urn:ogc:crs:EPSG::4326') ;

lon_id = netcdf.defVar(ncid, 'LONGITUDE', 'double', []);
netcdf.putAtt(ncid, lon_id, 'standard_name', 'longitude');
netcdf.putAtt(ncid, lon_id, 'long_name', 'longitude of anchor');
netcdf.putAtt(ncid, lon_id, 'units', 'degrees_east');
netcdf.putAtt(ncid, lon_id, 'axis', 'Y');
netcdf.putAtt(ncid, lon_id, 'valid_min', -180);
netcdf.putAtt(ncid, lon_id, 'valid_max', 180);
netcdf.putAtt(ncid, lon_id, 'reference_datum', 'WGS84 coordinate reference system') ;
netcdf.putAtt(ncid, lon_id, 'coordinate_reference_frame', 'urn:ogc:crs:EPSG::4326') ;

% loop through variables, and create them in netCDF, creating the quality_control variables also
use_vars = [4 13:size(data.Properties.VariableNames,2)]; % TODO: find the start of variable names, 13 is a bit of a hack

next_qc = 0;        
var_ids = [];
var_n = 1;
for var_name = data.Properties.VariableNames(use_vars) 
    disp(var_name)
    if ~endsWith(var_name, 'qc', 'IgnoreCase',true)
        varid = netcdf.defVar(ncid, var_name{1}, 'float', time_dimID);
        
        % need to add metadata from sheet to the variable
        
		var_ids(var_n) = varid;
        
        % save name for if next variable is a QC variable
        next_qc = 1;
        vn = var_name{1};
        
        % add metedata
        for i = 1:size(data.metadata,1)
            if ~isempty(data.metadata{i}) 
                if (~isempty(data.(var_name{1}){i}))
                    if (~isempty(data.(var_name{1}){i}) || ~isnan(data.(var_name{1}){i}))
                        %disp(data.(var_name{1}){i})
                        netcdf.putAtt(ncid, varid, data.metadata{i}, data.(var_name{1}){i});
                    end
                end
            end
        end
        
    else
        if (next_qc == 1)
            netcdf.putAtt(ncid, varid, 'ancillary_variables', [vn '_quality_control']);
            
            varid_qc = netcdf.defVar(ncid, [vn '_quality_control'], 'byte', time_dimID);
            netcdf.defVarFill(ncid, varid_qc, false, 127);
            
            netcdf.putAtt(ncid, varid_qc, 'long_name', ['quality flag for ' vn]);
            netcdf.putAtt(ncid, varid_qc, 'quality_control_conventions', 'IMOS standard flags');
            netcdf.putAtt(ncid, varid_qc, 'quality_control_set', 1);
            netcdf.putAtt(ncid, varid_qc, 'valid_min', int8(0)) ;
            netcdf.putAtt(ncid, varid_qc, 'valid_max', int8(9));
            netcdf.putAtt(ncid, varid_qc, 'flag_values', int8([0, 1, 2, 3, 4, 9]));
            netcdf.putAtt(ncid, varid_qc, 'flag_meanings', 'unknown good_data probably_good_data probably_bad_data bad_data missing_value');

            % need to add default QC data to variables
            
			var_ids(var_n) = varid_qc;
        end
        next_qc = 0;
    end % if (variable ends with qc)
    disp(var_ids(var_n))
	var_n = var_n + 1;
end

%
% end netCDF define mode
%

netcdf.endDef(ncid);

%
% add data to file
%

% time
mid_days_since_1950 = datenum(mid_times(I)) - datenum(1950,1,1);
netcdf.putVar(ncid, time_id, mid_days_since_1950);

open_close_days_since_1950 = datenum([open_times(I) close_times(I)]) - datenum(1950,1,1);
netcdf.putVar(ncid, time_bnds_id, open_close_days_since_1950);

% instrument info
netcdf.putVar(ncid, nomial_depth_id, cell2mat(cellfun(@str2num, depths_unique, 'UniformOutput', false)));
netcdf.putVar(ncid, instrument_type_id, traps_u');
netcdf.putVar(ncid, instrument_index_id, m(I));

% latitude, longitude
netcdf.putVar(ncid, lat_id, str2double(this_deployment.cmdddlatitude));
netcdf.putVar(ncid, lon_id, str2double(this_deployment.cmdddlongitude));

% data variables
next_qc = 0;     
var_n = 1;   
for var_name = data.Properties.VariableNames(use_vars)
    disp(var_name)
    vn = var_name{1};
    var_data_raw = data.(vn)(sample_msk);
    if iscell(var_data_raw)
        % might have got a cell array, convert to number,
        % NaNs need to be indicated with 'NaN' in excel sheet
        var_data_raw = cell2mat(cellfun(@str2double, var_data_raw, 'UniformOutput', false));
    end
    var_data_raw_sort = var_data_raw(I);
    netcdf.putVar(ncid, var_ids(var_n), var_data_raw_sort);
    
	var_n = var_n + 1;
end

%
% all done finish file
%

netcdf.close(ncid)
