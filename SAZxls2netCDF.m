
% read the deployment information
deployment_data = readtable('deployment-data.csv');

% read the xlsx data
data_file = '2018_saz20_47_sed_CWE_ver4.xlsx';
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
traps_u = cell2mat(traps(depths_u_idx));

% add global attributes:
glob_att = netcdf.getConstant('NC_GLOBAL');

%netcdf.putAtt(ncid, glob_att, 'abstract', 'Sediment traps (IMOS platform code:SAZOTS) are cones which intercept and store falling marine particles in collection cups.\nThe particles consist of a range of material including phytoplankton, zooplankton, faecal pellets, and dust. Each trap collects a time series of samples.\nThe sediment traps are from deep moorings in the Southern Ocean, typically at 47S, 54S, and 61S and at around 140 degrees East.\nEach mooring typically has 2-3 traps between 800m and 3800m below sea-level.');
netcdf.putAtt(ncid, glob_att, 'abstract', 'Oceanographic and meteorological data from the Southern Ocean Time Series observatory in the Southern Ocean southwest of Tasmania.');

netcdf.putAtt(ncid, glob_att, 'acknowledgement', 'Any users of IMOS data are required to clearly acknowledge the source of the material derived from IMOS in the format: \"Data was sourced from the Integrated Marine Observing System (IMOS) - IMOS is a national collaborative research infrastructure, supported by the Australian Government.\" If relevant, also credit other organisations involved in collection of this particular datastream (as listed in credit in the metadata record).');
netcdf.putAtt(ncid, glob_att, 'author', 'Peter Jansen');
netcdf.putAtt(ncid, glob_att, 'author_email', 'peter.jansen@csiro.au');
netcdf.putAtt(ncid, glob_att, 'cdm_data_type', 'Station');
netcdf.putAtt(ncid, glob_att, 'citation', 'Integrated Marine Observing System. [year-of-data-download], [Title], [Data access URL], accessed [date- of-access]');

netcdf.putAtt(ncid, glob_att, 'comment_archive', 'zooplankton > 1mm archived, photos avaliable on request, 3/10 of sample archived');
netcdf.putAtt(ncid, glob_att, 'comment_instrument', 'trap area, paraflux = 0.5 m^2, IRS = 0.16 m^2');
netcdf.putAtt(ncid, glob_att, 'comment_time', 'time is sample mid point');

netcdf.putAtt(ncid, glob_att, 'Conventions', 'CF-1.6,IMOS-1.4');
netcdf.putAtt(ncid, glob_att, 'data_centre', 'Australian Ocean Data Network (AODN)');
netcdf.putAtt(ncid, glob_att, 'data_centre_email', 'info@aodn.org.au');
netcdf.putAtt(ncid, glob_att, 'data_mode', 'D');
netcdf.putAtt(ncid, glob_att, 'deployment_code', this_deployment.cmdddname{1});
netcdf.putAtt(ncid, glob_att, 'deployment_number', '6');
netcdf.putAtt(ncid, glob_att, 'disclaimer', 'Data, products and services from IMOS are provided \"as is\" without any warranty as to fitness for a particular purpose.');
netcdf.putAtt(ncid, glob_att, 'distribution_statement', 'Data may be re-used, provided that related metadata explaining the data has been reviewed by the user, and the data is appropriately acknowledged\nData, products and services from IMOS are provided as is without any warranty as to fitness for a particular purpose.');
netcdf.putAtt(ncid, glob_att, 'file_version', 'Level 1 - Quality Controlled Data');
netcdf.putAtt(ncid, glob_att, 'geospatial_lat_max', str2double(this_deployment.cmdddlatitude));
netcdf.putAtt(ncid, glob_att, 'geospatial_lat_min', str2double(this_deployment.cmdddlatitude));
netcdf.putAtt(ncid, glob_att, 'geospatial_lat_units', 'degrees_north');
netcdf.putAtt(ncid, glob_att, 'geospatial_lon_max', str2double(this_deployment.cmdddlongitude));
netcdf.putAtt(ncid, glob_att, 'geospatial_lon_min', str2double(this_deployment.cmdddlongitude));
netcdf.putAtt(ncid, glob_att, 'geospatial_lon_units', 'degrees_east');
netcdf.putAtt(ncid, glob_att, 'geospatial_vertical_max', max(depth_nominal));
netcdf.putAtt(ncid, glob_att, 'geospatial_vertical_min', min(depth_nominal));
netcdf.putAtt(ncid, glob_att, 'geospatial_vertical_positive', 'down');
netcdf.putAtt(ncid, glob_att, 'geospatial_vertical_units', 'metres');
netcdf.putAtt(ncid, glob_att, 'institution', 'CSIRO; Antarctic Climate & Ecosystem Cooperative Research Centre');
netcdf.putAtt(ncid, glob_att, 'institution_address', 'CSIRO Marine Laboratories, Castray Esp, Hobart, Tasmania 7001, Australia; 20 Castray Esplanade, Hobart Tasmania 7000, Australia');

netcdf.putAtt(ncid, glob_att, 'instrument', 'McLane-PARFLUX Mark78H-21');
netcdf.putAtt(ncid, glob_att, 'instrument_serial_number', strjoin(traps(depths_u_idx), ' ; '));
netcdf.putAtt(ncid, glob_att, 'keywords', 'Oceans->Ocean Chemistry->Biogeochemical Cycles; moles_of_nitrate_and_nitrite_per_unit_mass_in_sea_water; moles_of_phosphate_per_unit_mass_in_sea_water; sea water parctical salinity; sample_number; moles_of_silicate_per_unit_mass_in_sea_water; moles_of_inorganic_carbon_per_unit_mass_in_sea_water; sea water temperature; recovered_bag_contents_mass');

netcdf.putAtt(ncid, glob_att, 'license', 'http://creativecommons.org/licenses/by/4.0/');
netcdf.putAtt(ncid, glob_att, 'Metadata_Conventions', 'Unidata Dataset Discovery v1.0');
netcdf.putAtt(ncid, glob_att, 'Mooring', 'SAZ mooring');
netcdf.putAtt(ncid, glob_att, 'naming_authority', 'IMOS');
netcdf.putAtt(ncid, glob_att, 'platform_code', 'SAZ');
netcdf.putAtt(ncid, glob_att, 'principal_investigator', 'Tom Trull');
netcdf.putAtt(ncid, glob_att, 'principal_investigator_email', 'tom.trull@csiro.au');
netcdf.putAtt(ncid, glob_att, 'project', 'Integrated Marine Observing System (IMOS)');
netcdf.putAtt(ncid, glob_att, 'quality_control_set', '2');
netcdf.putAtt(ncid, glob_att, 'references', 'http://www.imos.org.au');
netcdf.putAtt(ncid, glob_att, 'site_code', 'SOTS');
netcdf.putAtt(ncid, glob_att, 'source', 'Moorings');
netcdf.putAtt(ncid, glob_att, 'standard_name_vocabulary', 'NetCDF Climate and Forecast (CF) Metadata Convention Standard Name Table 67');

netcdf.putAtt(ncid, glob_att, 'time_coverage_start', datestr(min(mid_times), time_fmt));
netcdf.putAtt(ncid, glob_att, 'time_coverage_end', datestr(max(mid_times), time_fmt));
netcdf.putAtt(ncid, glob_att, 'time_deployment_start', datestr(this_deployment.cmddddeploymentdate(1), time_fmt));
netcdf.putAtt(ncid, glob_att, 'time_deployment_end', datestr(this_deployment.cmdddrecoverydate(1), time_fmt));

netcdf.putAtt(ncid, glob_att, 'title', 'Oceanographic and meteorological data from the Southern Ocean Time Series observatory in the Southern Ocean southwest of Tasmania.');
netcdf.putAtt(ncid, glob_att, 'uncertainty', '+/- 95% ci');
netcdf.putAtt(ncid, glob_att, 'voyage_deployment', 'http://www.cmar.csiro.au/data/trawler/survey_details.cfm?survey=SS2009_V04');
netcdf.putAtt(ncid, glob_att, 'voyage_recovery', 'http://www.cmar.csiro.au/data/trawler/survey_details.cfm?survey=SS2010_V02');

now_char = char(datetime('now','TimeZone','UTC+0','Format','y-MM-d HH:mm:ss'));
netcdf.putAtt(ncid, glob_att, 'history', [now_char ' : created from ' data_file]);
netcdf.putAtt(ncid, glob_att, 'date_created', now_char);

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

instrument_type_id = netcdf.defVar(ncid, 'instrument_type', 'char', [str_dimID, instance_dimID]);
netcdf.putAtt(ncid, instrument_type_id, 'long_name', 'deployment ; source instrument make ; model ; serial_number');

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
