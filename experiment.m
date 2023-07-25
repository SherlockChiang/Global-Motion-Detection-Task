clear; % clear existing variables
close all; % close all open figures

main();

function main()
    datetime.setDefaultFormats('default',"yyyy/MM/dd HH:mm:ss:SSS")
    time_start = datetime("now");

    % subject information 
    prompt = {'subject ID' 'age' 'gender'};
    name = 'subject info';
    info = inputdlg(prompt, name);
    
    % open window
    Screen('Preference', 'SkipSyncTests', 1); % shorten sync test
    ScrNum = Screen('Screens'); % read screen number
    [w, rect] = Screen('OpenWindow', max(ScrNum), 128); % open window
    Screen('TextFont',w,'Microsoft YaHei'); % choose a Chinese font type
    Screen('TextSize',w,76); % set font size

    [centerX, centerY] = RectCenter(rect); % coordinate of window center
    Priority(MaxPriority(w)); % set maximum priority for the window
    HideCursor; % hide cursor
    ListenChar(2); % characters typed do not show up in command window
    KbName('UnifyKeyNames'); % cross-platform compatibility of keynaming
    
    center= [centerX-centerX/2-20, centerY-centerX/2-20, centerX+centerX/2+20, centerY+centerX/2+20];
    center_dots = [centerX, centerY];
    keys = [KbName('LeftArrow'), KbName('RightArrow'), KbName('escape')];
    
    filename = ['eyes_',info{1},'.mat']; 
    filename = fullfile(pwd,'data',filename);
    results = struct;%create a structure 
    results.info = info; 
    results.start_time = time_start;

    nDots = 1100;
    r = centerX/2;
    dot_step = 3;
    %fix_time = 0.5;
    %stim_time = 0.25;
    choice_time = 0.8;
    conf_time = 2;
    
    trials = 60;
    nblock = 8;
    ntrials = trials*nblock;
    index_trials = 1:ntrials;
    resp_time_list = zeros(ntrials,1);
    choice_list = zeros(ntrials,1);
    correct_list = zeros(ntrials,1);
    valid_list = zeros(ntrials,1);
    confidence_list = zeros(ntrials,1);
    timestamp_start_list = cell(ntrials,1);
    timestamp_end_list = cell(ntrials,1);
    orientation_list = zeros(ntrials,1);
    condition_list = zeros(ntrials,1);
    condition_Precision_list = zeros(ntrials,1);
    
    pre_signs = [0,0];
    MeanOrientation = [8,8];
    % Precision = 25;
    
    rng('shuffle')
    
    repeatLoop = 1;
    repeatUpperLimit = 4;
    while repeatLoop
        repeatLoop = 0;
        % 0:left 1:right
        condition = [zeros(1,100/2),ones(1,100/2)];
        condition = condition(randperm(length(condition)));
        % count the number of repeated trials
        repeatCount = 1;
        for i = 2:length(condition)
            if condition(i)==condition(i-1)
                repeatCount = repeatCount + 1;
                if repeatCount > repeatUpperLimit
                    repeatLoop = 1;
                end
            else
                repeatCount = 1;
            end
        end
    end

    repeatLoop = 1;
    while repeatLoop
        repeatLoop = 0;
        
        condition_Precision = [15*ones(1,100/2),25*ones(1,100/2)];
        condition_Precision = condition_Precision(randperm(length(condition_Precision)));
        % count the number of repeated trials
        repeatCount = 1;
        for i = 2:length(condition_Precision)
            if condition_Precision(i)==condition_Precision(i-1)
                repeatCount = repeatCount + 1;
                if repeatCount > repeatUpperLimit
                    repeatLoop = 1;
                end
            else
                repeatCount = 1;
            end
        end
    end

    %% pre-trial
    for i = 1:100
        t0 = GetSecs();t = 0;
        move_direction = condition(i);
        Precision = condition_Precision(i);

        %show_fixation();
        show_stimulus();
        [~, ~, correct, valid] = show_choice(keys, choice_time);
        staircase(correct, valid);
    end

    %% block
    for iblock = 1:nblock
        repeatLoop = 1;
        repeatUpperLimit = 4;
        while repeatLoop
            repeatLoop = 0;
            % 0:left 1:right
            condition = [zeros(1,trials/2),ones(1,trials/2)];
            condition = condition(randperm(length(condition)));
            % count the number of repeated trials
            repeatCount = 1;
            for i = 2:length(condition)
                if condition(i)==condition(i-1)
                    repeatCount = repeatCount + 1;
                    if repeatCount > repeatUpperLimit
                        repeatLoop = 1;
                    end
                else
                    repeatCount = 1;
                end
            end
        end
        condition_list(trials*iblock-trials+1:trials*iblock) = condition;
    
        repeatLoop = 1;
        while repeatLoop
            repeatLoop = 0;
            
            condition_Precision = [15*ones(1,trials/2),25*ones(1,trials/2)];
            condition_Precision = condition_Precision(randperm(length(condition_Precision)));
            % count the number of repeated trials
            repeatCount = 1;
            for i = 2:length(condition_Precision)
                if condition_Precision(i)==condition_Precision(i-1)
                    repeatCount = repeatCount + 1;
                    if repeatCount > repeatUpperLimit
                        repeatLoop = 1;
                    end
                else
                    repeatCount = 1;
                end
            end
        end
        condition_Precision_list(trials*iblock-trials+1:trials*iblock) = condition_Precision;
    
        for i = 1:trials
            tmp = datetime("now");
            t0 = GetSecs();t = 0;
            timestamp_start_list{i+trials*(iblock-1)} = tmp;
            orientation_list(i+trials*(iblock-1)) = MeanOrientation([15,25]==condition_Precision(i));
            move_direction = condition(i);
            Precision = condition_Precision(i);
    
            %show_fixation();
            show_stimulus();
            [resp_time, choice, correct, valid] = show_choice(keys, choice_time);
            confidence = show_confidence();

            resp_time_list(i+trials*(iblock-1)) = resp_time;
            choice_list(i+trials*(iblock-1)) = choice;
            correct_list(i+trials*(iblock-1)) = correct;
            valid_list(i+trials*(iblock-1)) = valid;
            confidence_list(i+trials*(iblock-1)) = confidence;
    
            staircase(correct, valid);
            
            tmp = datetime("now");
            timestamp_end_list{i+trials*(iblock-1)} = tmp;
    
            results.dataMat = [index_trials',condition_list,condition_Precision_list,resp_time_list,choice_list,correct_list,valid_list,confidence_list,orientation_list];
            results.timestamp_start = timestamp_start_list;
            results.timestamp_end = timestamp_end_list;
            save(filename,'results');
            % close_ptb();
        end
    end

    close_ptb();
    %% functions
    % function show_fixation()
    %     Screen('DrawDots', w, [0,0], 16, [255, 0, 0], center_dots, 1);
    %     Screen('Flip', w);
    %     WaitSecs(fix_time)
    % end

    function show_stimulus()
        xy = gen_dots();
        move_dots(xy);
    end

    function move_dots(xy)
        dots_property = rand(nDots,1);
        dots_property = round(14*dots_property);
        dots_clock = zeros(nDots,1);
        end_flag = 0;
        %t01 = GetSecs();
        while 1
            % 𝐷𝑜𝑡 𝐷𝑖𝑟𝑒𝑐𝑡𝑖𝑜𝑛𝑠 ~ 𝑁(𝐿𝑒𝑓𝑡|𝑅𝑖𝑔ℎ𝑡 × 𝑀𝑒𝑎𝑛 𝑂𝑟𝑖𝑒𝑛𝑎𝑡𝑖𝑜𝑛, 𝐺𝑎𝑢𝑠𝑠𝑖𝑎𝑛 𝑁𝑜𝑖𝑠𝑒 × 1/𝑃𝑟𝑒𝑐𝑖𝑠𝑖𝑜𝑛)
            DotDirections = MeanOrientation([15,25]==condition_Precision(i)) + randn(nDots, 1) * sqrt(1/Precision);
            
            xy_tmp = gen_dots();
            xy(:,dots_clock == dots_property) = xy_tmp(:,dots_clock == dots_property);
            dots_clock(dots_clock==dots_property) = 0;
            x = xy(1,:);
            y = xy(2,:);

            if ~move_direction
                x = x - dot_step * sin(DotDirections'/180*pi);
            else
                x = x + dot_step * sin(DotDirections'/180*pi);
            end
            y = y - dot_step * cos(DotDirections'/180*pi);
            
            border = x.*x + y.*y;
            x(border >= r*r) = -x(border >= r*r);
            y(border >= r*r) = -y(border >= r*r);

            xy = [x;y];
            Screen('DrawDots', w, xy, 8, 0, center_dots, 1);
            Screen('DrawDots', w, [0,0], 16, [255, 0, 0], center_dots, 1);
            Screen('FrameOval', w, 0, center, 30);
            Screen('Flip', w);

            dots_clock = dots_clock + 1;
            end_flag = end_flag + 1;            
            
            while 1
                t = GetSecs();
                if t-t0>=1/60
                    break;
                end
            end

            if end_flag == 15
                break;
            end

            t0 = GetSecs();
        end
    end

    function xy = gen_dots()
        rho = rand([nDots,1])*(r-40); 
        rho = rho + 20;
        theta = rand([nDots,1])*2*pi;
        x=rho.*cos(theta); y=rho.*sin(theta);
        xy = [x'; y'];
    end

    function [resp_time, choice, correct, valid] = show_choice(keys, choice_time)
        valid = 1;
        xy = gen_dots();
        Screen('DrawDots', w, xy, 8, 0, center_dots, 1);
        Screen('FrameOval', w, 0, center, 30);
        DrawFormattedText(w,double('左 or 右？'),'center','center',0)
        Screen('Flip',w); % flip

        [resp_time, keyCode] = Check_Press(keys, choice_time);
        
        if keyCode(37)
            choice = 1;
        elseif keyCode(39)
            choice = 2;
        elseif keyCode(27)
            close_ptb();
        else 
            choice = 0;
        end
        if choice == move_direction + 1
            correct = 1;
        else
            correct = 0;
        end

        if resp_time < 0.1
            valid = 0;
            Screen('DrawDots', w, xy, 8, 0, center_dots, 1);
            Screen('FrameOval', w, 0, center, 30);
            DrawFormattedText(w,double('太快了！'),'center','center',0)
            Screen('Flip',w); % flip
            WaitSecs(0.5)
            t = GetSecs();
        elseif isnan(resp_time)
            valid = 0;
            Screen('DrawDots', w, xy, 8, 0, center_dots, 1);
            Screen('FrameOval', w, 0, center, 30);
            DrawFormattedText(w,double('太慢了！'),'center','center',0)
            Screen('Flip',w); % flip
            WaitSecs(0.5)
            t = GetSecs();
        end
    end

    function confidence = show_confidence()
        xy = gen_dots();
        t0 = GetSecs();
        x_dot = centerX + 0.15*(1-2*rand(1))*centerX/2;
        while 1
            [~, keyCode] = Check_Press(keys, 0);
            Screen('DrawLine', w, 0, 3*centerX/4, centerY, 5*centerX/4, centerY, 10);
            short_line = centerX/6;
            Screen('DrawLine', w, 0, 3*centerX/4, centerY-15, 3*centerX/4, centerY+5, 8);
            Screen('DrawLine', w, 0, 3*centerX/4+short_line, centerY-15, 3*centerX/4+short_line, centerY+15, 8);
            Screen('DrawLine', w, 0, 3*centerX/4+2*short_line, centerY-15, 3*centerX/4+2*short_line, centerY+15, 8);
            Screen('DrawLine', w, 0, 3*centerX/4+3*short_line, centerY-15, 3*centerX/4+3*short_line, centerY+15, 8);

            Screen('DrawDots', w, xy, 8, 0, center_dots, 1);
            Screen('FrameOval', w, 0, center, 30);
            
            if keyCode(37)
                x_dot = x_dot - 15;
            elseif keyCode(39)
                x_dot = x_dot + 15;
            elseif keyCode(27)
                close_ptb();
            end

            if x_dot < 3*centerX/4
                x_dot = 3*centerX/4;
            end
            if x_dot > 5*centerX/4
                x_dot = 5*centerX/4;
            end

            Screen('DrawLine', w, 0, x_dot, centerY, x_dot+20, centerY+20*sqrt(3), 5);
            Screen('DrawLine', w, 0, x_dot-20, centerY+20*sqrt(3), x_dot+20, centerY+20*sqrt(3), 5);
            Screen('DrawLine', w, 0, x_dot-20, centerY+20*sqrt(3), x_dot, centerY, 5);

            confidence_tmp = round(100*(x_dot-3*centerX/4)/centerX*2);

            Screen('Flip',w); % flip
            
            t_tmp = GetSecs();
            t=t_tmp-t0;
            if t >= conf_time
                confidence = confidence_tmp;
                break;
            end
        end
    end

    function staircase(sign,valid)
        if valid
            tmp_orientation = MeanOrientation([15,25]==condition_Precision(i));
            pre_sign = pre_signs([15,25]==condition_Precision(i));
            if pre_sign == 1 && sign == 1
                tmp_orientation = tmp_orientation - 0.1;
                pre_sign = 0;
            elseif sign == 0
                tmp_orientation = tmp_orientation + 0.1;
            end
            if sign == 1
                pre_sign = 1;
            end
            if sign == 0
                pre_sign = 0;
            end
            if (tmp_orientation-0.1) < 0.01
                tmp_orientation = 0.2;
            end
            MeanOrientation([15,25]==condition_Precision(i)) = tmp_orientation;
            pre_signs([15,25]==condition_Precision(i)) = pre_sign;
        end
    end

    function close_ptb()
        ListenChar(0); % characters typed do show up in command window
        Priority(0); % reset window priority
        ShowCursor; % show cursor
        Screen('CloseAll'); % close window
    end

    function [responseTime, keyCode] = Check_Press(keys, timeOut)
        %t0=GetSecs;
        t=0;
        responseTime=nan;
        keyCode=zeros(1,256);
        
        if timeOut == 0
            [~,t,keyCode] = KbCheck;
        else
            keyPressed = 0;
            t_tmp = 0;
            while (t_tmp-t0) < timeOut
                [~,t_tmp,keyCode_tmp] = KbCheck;
                if keyPressed == 0
                    if any(keyCode_tmp(keys))
                        keyPressed = 1;
                        t = t_tmp;
                        keyCode = keyCode_tmp;
                    end
                end
            end
        end

        if any(keyCode(keys))
            responseTime = t-t0;
        end
    end
end
