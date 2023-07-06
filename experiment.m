clear; % clear existing variables
close all; % close all open figures

main();

function main()
    % subject information 
    prompt = {'subject ID' 'age' 'gender'};
    name = 'subject info';
    info = inputdlg(prompt, name);
    
    % open window
    Screen('Preference', 'SkipSyncTests', 1); % shorten sync test
    ScrNum = Screen('Screens'); % read screen number
    [w, rect] = Screen('OpenWindow', max(ScrNum), 128); % open window
    
    [centerX, centerY] = RectCenter(rect); % coordinate of window center
    Priority(MaxPriority(w)); % set maximum priority for the window
    HideCursor; % hide cursor
    ListenChar(2); % characters typed do not show up in command window
    KbName('UnifyKeyNames'); % cross-platform compatibility of keynaming
    
    center= [centerX-centerX/2-20, centerY-centerX/2-20, centerX+centerX/2+20, centerY+centerX/2+20];
    center_dots = [centerX, centerY];
    keys = [KbName('LeftArrow'), KbName('RightArrow'), KbName('escape')];
    
    nDots = 1100;
    r = centerX/2;
    dot_step = 3;
    fix_time = 0.5;
    stim_time = 0.25;
    
    xy = gen_dots();

    Screen('FillOval', w, 0, center);
    Screen('DrawDots', w, xy, 6, [255, 255, 255], center_dots, 1);
    Screen('DrawDots', w, [0,0], 16, [255, 0, 0], center_dots, 1);
    Screen('FrameOval', w, 0, center, 30);
    Screen('Flip', w);
    
    MeanOrientation = 10;
    Precision = 25;

    move_dots();

    function move_dots()
        dots_property = rand(nDots,1);
        dots_property = round(14*dots_property);
        dots_clock = zeros(nDots,1);
        while 1
            % 𝐷𝑜𝑡 𝐷𝑖𝑟𝑒𝑐𝑡𝑖𝑜𝑛𝑠 ~ 𝑁(𝐿𝑒𝑓𝑡|𝑅𝑖𝑔ℎ𝑡 × 𝑀𝑒𝑎𝑛 𝑂𝑟𝑖𝑒𝑛𝑎𝑡𝑖𝑜𝑛, 𝐺𝑎𝑢𝑠𝑠𝑖𝑎𝑛 𝑁𝑜𝑖𝑠𝑒 × 1/𝑃𝑟𝑒𝑐𝑖𝑠𝑖𝑜𝑛)
            DotDirections = MeanOrientation + randn(nDots, 1) * sqrt(1/Precision);
            
            xy_tmp = gen_dots();
            xy(:,dots_clock == dots_property) = xy_tmp(:,dots_clock == dots_property);
            dots_clock(dots_clock==dots_property) = 0;
            %Left
            %x = x + dot_step * sin(DotDirections);
            x = xy(1,:);
            y = xy(2,:);

            x = x - dot_step * sin(DotDirections');
            y = y + dot_step * cos(DotDirections');
            
            border = x.*x + y.*y;
            x(border >= r*r) = -x(border >= r*r);
            y(border >= r*r) = -y(border >= r*r);

            xy = [x;y];
            Screen('FillOval', w, 0, center);
            Screen('DrawDots', w, xy, 6, [255, 255, 255], center_dots, 1);
            Screen('DrawDots', w, [0,0], 16, [255, 0, 0], center_dots, 1);
            Screen('FrameOval', w, 0, center, 30);
            Screen('Flip', w);
            
            [resp_time, resp_key] = Check_Press(keys,0);
            if resp_key(37)
                response = 1;
            elseif resp_key(39)
                response = 2;
            elseif resp_key(27)
                close_ptb();
                break;
            end
            WaitSecs(1/60);
            dots_clock = dots_clock + 1;
        end
    end

    function xy = gen_dots()
        rho = rand([nDots,1])*(r-40); 
        rho = rho + 20;
        theta = rand([nDots,1])*2*pi;
        x=rho.*cos(theta); y=rho.*sin(theta);
        xy = [x'; y'];
    end

    function close_ptb()
        ListenChar(0); % characters typed do show up in command window
        Priority(0); % reset window priority
        ShowCursor; % show cursor
        Screen('CloseAll'); % close window
    end

    function [responseTime, keyCode] = Check_Press(keys, timeOut)
        t0=GetSecs;t=0;
        responseTime=nan;
        keyCode=zeros(1,256);
        
        if timeOut == 0
            [~,t,keyCode] = KbCheck;
        else
            while ~any(keyCode(keys)) && ((t-t0) < timeOut)
                [~,t,keyCode] = KbCheck;
            end
        end

        if any(keyCode(keys))
            responseTime = t-t0;
        end
    end
end
