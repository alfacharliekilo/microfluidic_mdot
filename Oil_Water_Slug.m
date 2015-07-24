function [  ] = Oil_Water_Slug( direc )
    tic

    %Constants 
    FPS = 44;
    dt  = 1/FPS;
    Obj_mag = 10;
    Camera_mag = 1/10;
    um_per_pix = 3.2;
    Resolution = Obj_mag*Camera_mag*um_per_pix;
    Chan_dep = 0.100; %In milimeters
    Chan_wid = 0.300; %In milimeters
    Chan_area = Chan_dep*Chan_wid;

    %File Structure
    wd = direc;
    wd = [wd,'/'];
    fn = dir([wd,'*.tif']);

    %Delete Detector_Area.tif from File Structure
    for k = 1:length(fn)
        bool = strcmp(fn(k).name,'Detector_Area.tif');
        if bool == 1
            fn(k) = [];
        end
    end
    
    
    %Signal structure
        SigStruc.Signal = [];
        SigStruc.trigger_data_A = [];
        SigStruc.trigger_data_B = [];
        SigStruc.trigger_data_C = [];
        SigStruc.trigger_data_D = [];
        SigStruc.trigger_data_E = [];
        
    %Iterate Oil_Water_Slug for all files in directory

    for iter = 1:length(fn)
        
        %File Name
        mfn = [wd,fn(iter).name];

        %Detectors
        start = 1;
        info = imfinfo(mfn);
        frames = numel(info);
        threshold = 10/255;
        Detector = im2double(imread([wd,'Detector_Area.tif']));
        Detector = im2bw(Detector,threshold);
        Detector_Width = Detector_Sizer(Detector);

        % Image Data
        inc=1;
        n = 0;
        for k=start:inc:frames
            n = n+1;
            Mix_Image = im2double(imread(mfn,k)); %Read current frame
            Mix_Image = im2bw(Mix_Image,threshold); %Convert to binary
            Signal(n) = length(find(Mix_Image.*Detector)); %Find remaing pixels that are unity
            clear Mix_Image New_Image count;
        end

        %Calculate 1st Difference Vector
        diff_stor = diff(Signal);
        dydt = zeros(1,length(Signal));
            for k=start:inc:frames-1
                dydt(k+1)=diff_stor(k);
            end

        %Calculate 2nd Difference Vector
        diff_stor = diff(dydt);
        sec_dydt = zeros(1,length(Signal));
            for k=start:inc:frames-1
                sec_dydt(k+1)=diff_stor(k);
            end

        %Data
        time = 0:dt:(n-1)*dt;
        x = transpose(time);
        y = transpose(Signal);
        z = transpose(dydt);
        sec_z = transpose(sec_dydt);



        %Export Sorted Data
        [mr_matrix,trigger_vec,Vel_vec,Duty_vec] = mr_imagesort(Signal,dt,Detector_Width);
        Flow_out = Vel_vec*Resolution*60/1000; %In mm/min
        Data = [x,y,z,sec_z,trigger_vec];

        SigStruc(iter).Signal         = Signal;
        SigStruc(iter).trigger_data_A = trigger_vec(1:1:length(trigger_vec),2);
        SigStruc(iter).trigger_data_B = trigger_vec(1:1:length(trigger_vec),3);
        SigStruc(iter).trigger_data_C = trigger_vec(1:1:length(trigger_vec),4);
        SigStruc(iter).trigger_data_D = trigger_vec(1:1:length(trigger_vec),5);
        SigStruc(iter).trigger_data_E = trigger_vec(1:1:length(trigger_vec),6);

        FlowData = [Vel_vec,Flow_out];
        dlmwrite([wd,'\Data\Signal Data\',fn(iter).name,'_SignalData.txt'],Data);
        dlmwrite([wd,'\Data\Flow Data\',fn(iter).name,'_FlowData.txt'],FlowData);
        dlmwrite([wd,'\Data\Duty Data\',fn(iter).name,'_DutyData.txt'],Duty_vec);

        clear Signal
    end
    
    %Plot Data from Signal Structure
    for iter=1:length(fn)
        figure()
        hold on
        plot(SigStruc(iter).Signal)
        plot(find(SigStruc(iter).trigger_data_A),SigStruc(iter).trigger_data_A(find(SigStruc(iter).trigger_data_A)),'ro');
        plot(find(SigStruc(iter).trigger_data_B),SigStruc(iter).trigger_data_B(find(SigStruc(iter).trigger_data_B)),'bo');
        plot(find(SigStruc(iter).trigger_data_C),SigStruc(iter).trigger_data_C(find(SigStruc(iter).trigger_data_C)),'go');
        plot(find(SigStruc(iter).trigger_data_D),SigStruc(iter).trigger_data_D(find(SigStruc(iter).trigger_data_D)),'co');
        plot(find(SigStruc(iter).trigger_data_E),SigStruc(iter).trigger_data_E(find(SigStruc(iter).trigger_data_E)),'ko');
        legend('Data','Trigger1','Trigger2','Trigger3','Trigger4','Trigger5',...
               'Location','NorthOutside','Orientation','horizontal')
        xlabel('Frame')
        ylabel('Signal Intensity (pixels)')
        title(fn(iter).name)
    end

    toc
end


