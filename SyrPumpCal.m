mfn = 'F:\ME130L\Flowrate Calib\Chip Calibration\Oil\';

%Import Oil Calibration Data
Oil_0_25_ul_min = importdata([mfn,'0_25 uL_min oil.txt']);
Oil_0_50_ul_min = importdata([mfn,'0_50 uL_min oil.txt']);
Oil_0_75_ul_min = importdata([mfn,'0_75 uL_min oil.txt']);
Oil_1_00_ul_min = importdata([mfn,'1_00 uL_min oil.txt']);
Oil_1_25_ul_min = importdata([mfn,'1_25 uL_min oil.txt']);
Oil_1_50_ul_min = importdata([mfn,'1_50 uL_min oil.txt']);
Oil_1_75_ul_min = importdata([mfn,'1_75 uL_min oil.txt']);
Oil_2_00_ul_min = importdata([mfn,'2_00 uL_min oil.txt']);
Oil_2_50_ul_min = importdata([mfn,'2_50 uL_min oil.txt']);
Oil_3_00_ul_min = importdata([mfn,'3_00 uL_min oil.txt']);
Oil_3_50_ul_min = importdata([mfn,'3_50 uL_min oil.txt']);
Oil_4_00_ul_min = importdata([mfn,'4_00 uL_min oil.txt']);

mfn = 'F:\ME130L\Flowrate Calib\Chip Calibration\Water\';

%Import Water Calibration Data
Water_0_25_ul_min = importdata([mfn,'0_25 uL_min water.txt']);
Water_0_50_ul_min = importdata([mfn,'0_50 uL_min water.txt']);
Water_0_75_ul_min = importdata([mfn,'0_75 uL_min water.txt']);
Water_1_00_ul_min = importdata([mfn,'1_00 uL_min water.txt']);
Water_1_25_ul_min = importdata([mfn,'1_25 uL_min water.txt']);
Water_1_50_ul_min = importdata([mfn,'1_50 uL_min water.txt']);
Water_1_75_ul_min = importdata([mfn,'1_75 uL_min water.txt']);
Water_2_00_ul_min = importdata([mfn,'2_00 uL_min water.txt']);
Water_2_50_ul_min = importdata([mfn,'2_50 uL_min water.txt']);
Water_3_00_ul_min = importdata([mfn,'3_00 uL_min water.txt']);
Water_3_50_ul_min = importdata([mfn,'3_50 uL_min water.txt']);
Water_4_00_ul_min = importdata([mfn,'4_00 uL_min water.txt']);


%Structure of Oil_Array and Water_Array

startcut = 1;
endcut   = 600;

col_space = numel(startcut:1:endcut);

Oil_Array = zeros(col_space,2,12);
Water_Array = zeros(col_space,2,12);

Oil_Array(:,:,1) = Oil_0_25_ul_min(1:col_space,1:2); 
Oil_Array(:,:,2) = Oil_0_50_ul_min(1:col_space,1:2);
Oil_Array(:,:,3) = Oil_0_75_ul_min(1:col_space,1:2);
Oil_Array(:,:,4) = Oil_1_00_ul_min(1:col_space,1:2);
Oil_Array(:,:,5) = Oil_1_25_ul_min(1:col_space,1:2);
Oil_Array(:,:,6) = Oil_1_50_ul_min(1:col_space,1:2);
Oil_Array(:,:,7) = Oil_1_75_ul_min(1:col_space,1:2);
Oil_Array(:,:,8) = Oil_2_00_ul_min(1:col_space,1:2);
Oil_Array(:,:,9) = Oil_2_50_ul_min(1:col_space,1:2);
Oil_Array(:,:,10) = Oil_3_00_ul_min(1:col_space,1:2);
Oil_Array(:,:,11) = Oil_3_50_ul_min(1:col_space,1:2);
Oil_Array(:,:,12) = Oil_4_00_ul_min(1:col_space,1:2);

Water_Array(:,:,1) = Water_0_25_ul_min(1:col_space,1:2); 
Water_Array(:,:,2) = Water_0_50_ul_min(1:col_space,1:2);
Water_Array(:,:,3) = Water_0_75_ul_min(1:col_space,1:2);
Water_Array(:,:,4) = Water_1_00_ul_min(1:col_space,1:2);
Water_Array(:,:,5) = Water_1_25_ul_min(1:col_space,1:2);
Water_Array(:,:,6) = Water_1_50_ul_min(1:col_space,1:2);
Water_Array(:,:,7) = Water_1_75_ul_min(1:col_space,1:2);
Water_Array(:,:,8) = Water_2_00_ul_min(1:col_space,1:2);
Water_Array(:,:,9) = Water_2_50_ul_min(1:col_space,1:2);
Water_Array(:,:,10) = Water_3_00_ul_min(1:col_space,1:2);
Water_Array(:,:,11) = Water_3_50_ul_min(1:col_space,1:2);
Water_Array(:,:,12) = Water_4_00_ul_min(1:col_space,1:2);


m_comb   = 103.26; %grams
m_beaker = 59.06;  %grams
v_beaker = 50;     %mL

m_oil     = (m_comb - m_beaker);      
v_oil     = (v_beaker);           
rho_oil   = m_oil/v_oil;        %g/mL == mg/uL
rho_water = 0.999;

Oil_Mass_Array = Oil_Array;
Water_Mass_Array = Water_Array;

Oil_Mass_Array(:,2,:) = Oil_Array(:,2,:);
Water_Mass_Array(:,2,:) = Water_Array(:,2,:);

Oil_Mass_Array(:,1,:) = Oil_Array(:,1,:)/60;   %Oil_Mass_Array and Water_Mass_Array have units of minutes and uL
Water_Mass_Array(:,1,:) = Water_Array(:,1,:)/60;

figure(1)
[slope_oil,intercept_oil,SEE_oil,vec_oil] = LinearFit(Oil_Mass_Array,rho_oil);
xlabel('Setpoint Mass Flowrate (mg/min)')
ylabel('Measured Mass Flowrate (mg/min)')
title('Silicone Oil Mass Flow Rate Calibration Curve')
Str_oil_slope = num2str(slope_oil);
Str_oil_int   = num2str(intercept_oil);
Str_oil_SEE   = num2str(SEE_oil);
text(0.5,4.2,'Y = ax + b')
text(0.5,4,['a =',Str_oil_slope]);
text(0.5,3.8,['b =',Str_oil_int]);
text(0.5,3.6,['SEE (mg/min) =',Str_oil_SEE]);
dlmwrite('F:\ME130L\Flowrate Calib\Chip Calibration\Oil\OilCalib.txt',vec_oil);

figure(2)
[slope_water,intercept_water,SEE_water,vec_water] = LinearFit(Water_Mass_Array,rho_water);
xlabel('Setpoint Mass Flowrate (mg/min)')
ylabel('Measured Mass Flowrate (mg/min)')
title('Water/Dye Mass Flow Rate Calibration Curve')
Str_water_slope = num2str(slope_water);
Str_water_int   = num2str(intercept_water);
Str_water_SEE   = num2str(SEE_water);
text(0.5,4.2,'Y = ax + b')
text(0.5,4,['a =',Str_water_slope]);
text(0.5,3.8,['b =',Str_water_int]);
text(0.5,3.6,['SEE (mg/min) =',Str_water_SEE]);
dlmwrite('F:\ME130L\Flowrate Calib\Chip Calibration\Water\WaterCalib.txt',vec_water);