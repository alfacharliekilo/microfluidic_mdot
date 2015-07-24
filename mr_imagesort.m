function [ mr_matrix, trigger_vec, Vel_vec, Duty_vec] = mr_imagesort( Signal, dt, D_Width)
%mr_imagesort The purpose of this function is to detect, demarcate, and
%sort dye/water droplets as they pass thru the FOV of the camera. The first
%column of the returned matrix 
%is the frame index. This column steps from the first frame to the
%last frame in the TIF file. Subsequent columns demarcate individual
%droplets. Data in these columns indicate fluid volume (in pixels).

%In addition, the final two rows in the matrix will contain data about
%droplet velocity. The upper row will contain maximum velocity detected
%for the given droplet, while the lower row will contain the frame in which
%maximim velocity was detected.

% The inputs to this function are:
%
% FPS: Scalar. The frame rate of the camera. An estimate for the number of
% datapoints per droplet
%
% tif_length: Scalar. Total # of frames in the tif file. FPS*tif_length is an
% estimated 
%
% Signal: Vector. Signal value returned from the script Oil_Water_Slug.m
% 
% dydt: Vector. Measures the point-to-point change of the vector Signal.
% Effectively a numeric derivative of Signal wrt time.

%Trigger_vec return a matrix that spans the length of the number of
% %non-zero elements in the Signal. The first column indiciates the frame
% %number, the second indicates the size (the mean of scope_dat) of change in
% signal from zero to rise, the third indicates the size 
% the mean of scope_dat) of the change in signal from rise to steady-state
% i.e. full droplet exposure. 

mr_matrix  = zeros(length(Signal)+1,round(length(Signal)/80));
Detector_width = D_Width;
start = 1;
inc = 1;
n   = 1;
p   = 1;
q   = 1;
m   = 1;
r   = 1;
d   = 1;

%Signal Detection Variables
det_cond_1 = 0;
det_cond_2 = 0;
det_cond_3 = 0;

Duty_On = 0;
Duty_Off = 0;

%Mr_Matrix Variables
mr_matrix(1:length(Signal),1) = 1:length(Signal);
vector = find(Signal);
frames = length(Signal);
det_fm_1 = 0;
det_fm_2 = 0;
det_fm_3 = 0;
det_fm_4 = 0;
det_fm_5 = 0;
max_Sig = max(Signal);

q = q+1;

%Calculate 1st Difference Vector
diff_stor = diff(Signal);
dydt = zeros(1,length(Signal));
for k=start:inc:frames-1
    dydt(k+1)=diff_stor(k);
end

%Calculate 2st Difference Vector
diff_stor = diff(dydt);
sec_dydt = zeros(1,length(Signal));
for k=start:inc:frames-1
    sec_dydt(k+1)=diff_stor(k);
end

%Populate Matrix Data

trigger_vec = zeros(length(vector),6);
trigger_vec(1:length(Signal),1) = 1:numel(Signal);
diff_vec = diff(vector);

Drop_count = 1;
for k = start:inc:(length(find(Signal))-1)

    if (diff_vec(n) == 1)
        mr_matrix(p,q) = Signal(vector(n));
        
        p = p+1;
        
    else
        mr_matrix(p,q) = Signal(vector(n));
        Drop_count = Drop_count + 1;
        
        if vector(n) == vector(length(vector))
            p = p;
            q = q;
        else
            p = vector(n+1);
            q = q+1;
        end
    end
    
    n = n+1;
end

Vel_vec  = zeros(Drop_count,4);
Duty_vec = zeros(Drop_count,1);

for k = start:inc:length(Signal)
    if (Signal(m) == 0)
        Drop_frame = 0;
    else
        Drop_frame = 1;
    end
    if(m ~= length(Signal))
    
        if (Drop_frame == 1 && m ~=1 )

            if(sec_dydt(m) > 0 && Signal(m-1)==0)
                det_fm_1 = m-1;
                det_cond_1 = 1;
                trigger_vec(m,2) = 1;
            end

            if(det_cond_1 == 1)

                if(dydt(m) == 0 || Signal(m) == max_Sig)
                    det_fm_2 = m;
                    det_cond_1 = 0;
                    det_cond_2 = 1;
                    trigger_vec(m,3) = Signal(m);
                end
            end

            if(det_cond_2 == 1)
                if(dydt(m) == 0 && dydt(m+1) < 0)
                    det_fm_3= m;
                    det_cond_2 = 0;
                    det_cond_3 = 1;
                    trigger_vec(m,4) = Signal(m);
                end
            end
        end

        if (Drop_frame == 0 && m ~=1)
            if (det_cond_3 == 1 && m ~= length(Signal))
                if (Signal(m) == 0 && Signal(m-1) ~=0)
                    det_fm_4 = m;
                    trigger_vec(m,5) = 1;
                end
                if (Signal(m) == 0 && Signal(m+1) ~=0)
                    det_fm_5 = m;
                    det_cond_3 = 0;
                    trigger_vec(m,6) = 1;
                end
            end
        end

        if (det_fm_3 ~= 0 && det_fm_5 ~=0)
           Duty_On  = (det_fm_3 - det_fm_1)*dt;
           Duty_Length = (det_fm_5 - det_fm_1)*dt;
           Duty_vec(r) = Duty_On/Duty_Length;
           
           Transit_time = (det_fm_2 - det_fm_1)*dt;
           Transit_chk  = (det_fm_4 - det_fm_3)*dt;
           t_chksm      = abs(Transit_time-Transit_chk)/dt;
           Drop_vel     = Detector_width/Transit_time;
           Drop_chk     = Detector_width/Transit_chk;
           Vel_vec(r,1) = mean([Drop_vel,Drop_chk]); %Pixels/second
           Vel_vec(r,2) = Drop_vel;
           Vel_vec(r,3) = Drop_chk;
           Vel_vec(r,4) = t_chksm;
           
           %Use of t_chksm assumes that each velocity is accurate within
           %1 frame, i.e. error can be equal to +-1 OR 0 frames. Since 
           %t_chksm compares two variables, the effect is additive, i.e. 
           %t_chksm can equal 0, 1, or 2. No difference in velocity if this
           %criteria holds true.
           
           r = r+1;
         
           d = d+1;
           det_fm_1 = 0;
           det_fm_2 = 0;
           det_fm_3 = 0;
           det_fm_4 = 0;
           det_fm_5 = 0;
        end
         m = m+1;
    end
end
end

