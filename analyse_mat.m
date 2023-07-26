clear

filepath_matlab = "data\eyes_010.mat";
load(filepath_matlab,"results")

datas = results.dataMat;

validation = datas(:,7);

datas_value = datas(validation==1,:);

index = datas(:,1);
condition = datas(:,2);
precision = datas(:,3);
rt = datas(:,4);
resp = datas(:,5)-1;
correction = datas(:,6);
confidence = datas(:,8);
orientation = datas(:,9);

index = index(validation==1);
condition = condition(validation==1);
precision = precision(validation==1);
rt = rt(validation==1);
resp = resp(validation==1);
correction = correction(validation==1);
confidence = confidence(validation==1);
orientation = orientation(validation==1);

confidence_4 = round(confidence/100*3)+1;

border_1_15 = precision==15;
border_1_25 = precision==25;
border_2 = index>68;
border_15 = border_1_15 .* border_2;
border_15 = logical(border_15);
border_25 = border_1_25 .* border_2;
border_25 = logical(border_25);

or_15= orientation(border_15);
or_25= orientation(border_25);
[h_or,p_or] = ttest(or_15,or_25);

cor_15= correction(border_15);
cor_25= correction(border_25);
[h_corr,p_corr] = ttest(cor_15,cor_25);

confi_15= confidence(border_15);
confi_25= confidence(border_25);
[h_confi,p_confi] = ttest(confi_15,confi_25);

aver_15 = mean(orientation(border_15));
aver_25 = mean(orientation(border_25));
std_15 = std(orientation(border_15));
std_25 = std(orientation(border_25));

rt_15 = rt(border_15);
rt_25 = rt(border_25);
[h_rt,p_rt] = ttest(rt_15,rt_25);
d = (mean(rt_25)-mean(rt_15))/std(rt);

condition_15 = condition(border_15);
condition_25 = condition(border_25);
resp_15 = resp(border_15);
resp_25 = resp(border_25);
confidence_15 = confidence_4(border_15);
confidence_25 = confidence_4(border_25);
[nR_S1, nR_S2] = trials2counts(condition_15',resp_15',confidence_15',4);
fit_15 = fit_meta_d_mcmc(nR_S1,nR_S2);
[nR_S1, nR_S2] = trials2counts(condition_25',resp_25',confidence_25',4);
fit_25 = fit_meta_d_mcmc(nR_S1,nR_S2);
