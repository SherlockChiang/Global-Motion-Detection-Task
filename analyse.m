clear

pupil_diameter_list = analyse_onesample("data\eyes_003.mat","Project003_glasses Data export.xlsx");

function pupil_diameter_list = analyse_onesample(filepath_matlab,filepath_eyetracker)
    load(filepath_matlab,"results")
    eye_tracker_data = readtable(filepath_eyetracker);
    
    tmp = eye_tracker_data{1,["RecordingDate","RecordingStartTime"]};
    start_timestamp = [tmp{1} ' ' tmp{2}];
    start_time = datetime(start_timestamp,"InputFormat","yyyy/M/dd HH:mm:ss.SSS");
    
    eye_tracker_data = eye_tracker_data{:,["RecordingTimestamp","PupilDiameterFiltered"]};
    
    t_stamp_conv = 86400000000;
    datetime_list = start_time + eye_tracker_data(:,1)/t_stamp_conv;
    n_trials = size(results.dataMat);
    n_trials = n_trials(1);
    
    pupil_diameter = eye_tracker_data(:,1);
    pupil_diameter_list = zeros(n_trials,1);
    
    for i = 1:n_trials
        pupil_diameter_list(i) = nanmean(pupil_diameter(datetime_list > results.timestamp_start(i) && datetime_list < results.timestamp_end(i)));
    end
end