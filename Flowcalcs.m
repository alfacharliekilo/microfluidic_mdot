%Run SyrPumpCal before running this code. 
%Flowcalcs.m requires variables filled by SyrPumpCal
hold on
%Load File Structures
direc= uigetdir('/Users/ANDREW_WK/Dropbox/MTFL/Data/Tif Files/100 uL syringe/Mineral Oil 2 Repeatability Test 2 mg min final/1_000 uLmin/Data');
flows_direc = uigetdir('/Users/ANDREW_WK/Dropbox/MTFL/Data/Flowrate Calibration/Chip Calibration/100 uL syringe/Oil','Select Flow Uncertainties');
mfn_f = [direc,'/Flow Data/'];
fnames_f = dir([mfn_f,'*.txt']);
mfn_d = [direc,'/Duty Data/'];
fnames_d = dir([mfn_d,'*.txt']);
mfn_s = [direc,'/Signal Data/'];
fnames_s = dir([mfn_s,'*.txt']);



%Constants
m_dot     = 2; %mg/min
rho_w     = 0.999; %mg/uL
del_rho_w = 0.01; %del_rho_water/rho_water (Percentage error)
del_rho_o = 0.01; %del_rho_oil/rho_oil (Percentage error)
rho_o     = 0.8611; %Si - 0.951 Mineral - 0.8400
A         = 0.0300; %mm^2
delta_A   = 0.01; %Delta_A/A (Percentage error)
t_val     = 2.1; %Student's Critical T value. N ranges from 10-30 droplets per vid

water_set   = [0.2;0.4;0.6;0.8;1];
oil_set     = (m_dot-rho_w*water_set)/rho_o;
delta_table = csvread([flows_direc,'/Export for Matlab.csv']); %Trial No.% %Setpoint% %Setpoint Error% %Rho Error%
delta_flows = polyfit(delta_table(:,2),delta_table(:,3),2);

delta_oil   = (delta_flows(1).*oil_set.^2 + delta_flows(2).*oil_set + delta_flows(3))./oil_set;
delta_water = (delta_flows(1).*water_set.^2 + delta_flows(2).*water_set + delta_flows(3))./water_set;

delta_m_dot = sqrt(2*(0.01)^2+ (delta_oil).^2 + (delta_water).^2); %Percentage Error, delta_m_dot/m_dot
delta_vel   = sqrt((delta_m_dot).^2+(delta_A).^2);


%Symbols
syms sym_vel sym_duty

sym_vel = (m_dot)/(((rho_w-rho_o)*sym_duty + rho_o)*A);

%Populate Structures
for k = 1:length(fnames_f)
    struc_flow(k).name = fnames_f(k).name;
    flow_stor = dlmread([mfn_f,fnames_f(k).name]);
    flow_count = length(flow_stor(flow_stor(:,1)~=0));
    struc_flow(k).data = flow_stor(1:flow_count,:);
    
    struc_duty(k).name = fnames_d(k).name;
    duty_stor = dlmread([mfn_d,fnames_d(k).name]);
    duty_count = length(duty_stor(duty_stor(:,1)~=0));
    struc_duty(k).data = duty_stor(1:duty_count,:);
    
    struc_signal(k).name = fnames_s(k).name;
    signal_stor = dlmread([mfn_s,fnames_s(k).name]);
    signal_count = length(signal_stor(signal_stor(:,1)~=0));
    struc_signal(k).data = signal_stor(1:signal_count,:);
end

% plotStyle = {'bo','ro','ko','mo','go','co'};
% for k = 1:length(struc_duty)
%     hold on
%     plot(struc_duty(k).data,struc_flow(k).data(:,5),plotStyle{k})
% end
% xlabel('Duty Cycle')
% ylabel('Flow Velocity (mm/sec)')
% title('Raw Duty vs. Channel Velocity')
% hold off

for k = 1:length(struc_duty)
    struc_duty(k).mean  = mean(struc_duty(k).data);
    struc_duty(k).uncrt = t_val*std(struc_duty(k).data)./sqrt(length(struc_duty(k).data));
    struc_flow(k).mean  = mean(struc_flow(k).data(:,5));
    struc_flow(k).uncrt = t_val*std(struc_flow(k).data(:,5))./sqrt(length(struc_duty(k).data));
    
    
%     errorbar(struc_duty(k).mean,struc_flow(k).mean,...
%              struc_flow(k).uncrt,'bo','LineStyle','none') 
%          
%     herrorbar(struc_duty(k).mean,struc_flow(k).mean,...
%              struc_duty(k).uncrt,'bo')
    
end
%Plot Model on Scatter


for k = 1:length(struc_duty)
    duty_vec_val(k) = struc_duty(k).mean;
    flow_vec_val(k) = struc_flow(k).mean;    
end

mean_duty = mean(duty_vec_val);
mean_flow = mean(flow_vec_val);
unct_duty = 2*std(duty_vec_val)/sqrt(10);
unct_flow = 2*std(flow_vec_val)/sqrt(10);

hold on
errorbar(mean_duty,mean_flow,unct_flow,'b*','LineStyle','none') 
herrorbar(mean_duty,mean_flow,unct_duty,'b*')
ezplot(sym_vel,[0.0,0.6]);
xlabel('Duty Cycle')
ylabel('Flow Velocity (mm/min)')
title('Duty Cycle vs. Channel Velocity')

%Add Uncertainty Data to Theoretical Line%

theory_vel = (m_dot)/(((rho_w-rho_o)*mean_duty + rho_o)*A);
errorbar(mean_duty,theory_vel,theory_vel*delta_vel(5),'ro')
