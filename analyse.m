clear

filepath_matlab = "data\eyes_010.mat";
filepath_eyetracker = "Project1_glasses Data export.xlsx";

load(filepath_matlab,"results")
eye_tracker_data = readtable(filepath_eyetracker);

tmp = eye_tracker_data{1,["RecordingDate","RecordingStartTime"]};
start_timestamp = [tmp{1} ' ' tmp{2}];
start_time = datetime(start_timestamp,"InputFormat","yyyy/M/dd HH:mm:ss.SSS");

eye_tracker_data = eye_tracker_data{:,["RecordingTimestamp","PupilDiameterFiltered"]};

t_stamp_conv = 86400000000;
datetime_list = start_time + eye_tracker_data(:,1)/t_stamp_conv;
samples = zeros(size(datetime_list));
samples_pre = zeros(size(datetime_list));
samples_post = zeros(size(datetime_list));

time_list = zeros(size(datetime_list));
time_list_pre = time_list(2:length(time_list));
time_list_post = time_list_pre;

n_trials = size(results.dataMat);
n_trials = n_trials(1);
pupil_diameter = eye_tracker_data(:,2);

datas = results.dataMat;

validation = datas(:,7);

datas_value = datas(validation==1,:);

index = datas(:,1);
precision = datas(:,3);
rt = datas(:,4);
correction = datas(:,6);
confidence = datas(:,8);
orientation = datas(:,9);

index = index(validation==1);
n_trial_valid = size(index);
n_trial_valid = n_trial_valid(1);
index_eye = zeros(n_trial_valid,1);
rt = rt(validation==1);
precision = precision(validation==1);
correction = correction(validation==1);
confidence = confidence(validation==1);
orientation = orientation(validation==1);
interaction = precision.*confidence;

ii = 1;

for i = 1:n_trials
    if validation(i) == 0
        continue
    end
    t_1 = results.timestamp_start{i,1};

    border_1 = datetime_list > results.timestamp_start{i,1};
    border_2 = datetime_list < results.timestamp_end{i,1};
    border = border_1 .* border_2;
    border = logical(border);
    index_eye(ii) = sum(border);
    ii = ii + 1;

    samples(border) = i;

    tmp = seconds(datetime_list - t_1);
    time_list(border) = tmp(border);
    
    if i < n_trials
        t_2 = results.timestamp_end{i,1};
        tmp_pre = seconds(datetime_list - t_2);
        time_list_pre(border) = tmp_pre(border);
        samples_pre(border) = i;
    end

    if i >= 2
        t_2 = results.timestamp_start{i-1,1};
        tmp_post = seconds(datetime_list - t_2);
        time_list_post(border) = tmp_post(border);
        samples_post(border) = i;
    end

end

y = pupil_diameter(samples~=0);
time_list = time_list(samples~=0);
y_pre = pupil_diameter(samples_pre~=0);
time_list_pre = time_list_pre(samples_pre~=0);
y_post = pupil_diameter(samples_post~=0);
time_list_post = time_list_post(samples_post~=0);

samples = samples(samples~=0);
n_samples = size(samples);
n_samples = n_samples(1);
X = zeros(n_samples,6);

tmp = 1;
for i = 1:n_trial_valid
    array_tmp = [precision(i), confidence(i), interaction(i), orientation(i), rt(i), correction(i)];
    n_times = index_eye(i);
    X(tmp:n_times+tmp-1,:) = multiply(array_tmp,n_times);
    tmp = tmp + n_times;
end

X = [ones(size(y)), X];

tmp = 1;
for i = 2:n_trial_valid
    array_tmp = [precision(i), confidence(i), interaction(i), orientation(i), rt(i), correction(i)];
    n_times = index_eye(i-1);
    X_pre(tmp:n_times+tmp-1,:) = multiply(array_tmp,n_times);
    tmp = tmp + n_times;
end

X_pre = [ones(size(y_pre)), X_pre];

tmp = 1;
for i = 1:n_trial_valid-1
    array_tmp = [precision(i), confidence(i), interaction(i), orientation(i), rt(i), correction(i)];
    n_times = index_eye(i+1);
    X_post(tmp:n_times+tmp-1,:) = multiply(array_tmp,n_times);
    tmp = tmp + n_times;
end

X_post = [ones(size(y_post)), X_post];

%[b,bint,r,rint,stats] = regress(y,X);
time_border_pre = 0.02*(0:50) - 1;
time_border = 0.02*(0:153);
time_border_post = 0.02*(0:47) + 3.06;

time_plot_pre = time_border_pre(1:50) + 0.01;
time_plot = time_border(1:153) + 0.01;
time_plot_post = time_border_post(1:47) + 0.01;

time_plot_list = [time_plot_pre,time_plot,time_plot_post];
beta_list = zeros(250,7);
bint_list = cell(250,1);

for i = 1:50
    border_1 = time_list_pre > time_border_pre(i);
    border_2 = time_list_pre < time_border_pre(i+1);
    border = border_1 .* border_2;
    border = logical(border);
    y_tmp = y_pre(border);
    X_tmp = X_pre(border,:);
    [b,bint,r,rint,stats] = regress(y_tmp,X_tmp);
    beta_list(i,:) = b;
    bint_list{i} = bint;
end

for i = 1:153
    border_1 = time_list > time_border(i);
    border_2 = time_list < time_border(i+1);
    border = border_1 .* border_2;
    border = logical(border);
    y_tmp = y(border);
    X_tmp = X(border,:);
    [b,bint,r,rint,stats] = regress(y_tmp,X_tmp);
    beta_list(i+50,:) = b;
    bint_list{i+50} = bint;
end

for i = 1:47
    border_1 = time_list_post > time_border_post(i);
    border_2 = time_list_post < time_border_post(i+1);
    border = border_1 .* border_2;
    border = logical(border);
    y_tmp = y_post(border);
    X_tmp = X_post(border,:);
    [b,bint,r,rint,stats] = regress(y_tmp,X_tmp);
    beta_list(i+203,:) = b;
    bint_list{i+203} = bint;
end

figure(1)
plot(time_plot_list,beta_list(:,2))
figure(2)
plot(time_plot_list,beta_list(:,3))
figure(3)
plot(time_plot_list,beta_list(:,4))
figure(4)
plot(time_plot_list,beta_list(:,5))
figure(5)
plot(time_plot_list,beta_list(:,6))
figure(6)
plot(time_plot_list,beta_list(:,7))

function array_duo = multiply(array,n_times)
    tmp = size(array);
    array_duo = zeros(n_times,tmp(2));
    for i = 1:n_times
        array_duo(i,:) = array;
    end
end
