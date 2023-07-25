clear

filepath_matlab = "data\eyes_010.mat";
load(filepath_matlab,"results")

datas = results.dataMat;

validation = datas(:,7);

datas_value = datas(validation==1,:);

index = datas(:,1);
precision = datas(:,3);
correction = datas(:,6);
confidence = datas(:,8);
orientation = datas(:,9);

index = index(validation==1);
precision = precision(validation==1);
correction = correction(validation==1);
confidence = confidence(validation==1);
orientation = orientation(validation==1);

border_1_15 = precision==15;
border_1_25 = precision==25;
border_2 = index>68;
border_15 = border_1_15 .* border_2;
border_15 = logical(border_15);
border_25 = border_1_25 .* border_2;
border_25 = logical(border_25);

or_15= orientation(border_15);
or_25= orientation(border_25);
[h,p] = ttest(or_15,or_25);
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
