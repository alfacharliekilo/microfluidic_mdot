function [ regress_slope, regress_intercept, SEE,...
           calib_vec ] = LinearFit( Mass_Array, rho )

p = zeros(10,2,12);
slopes = zeros(10,12);
mass_rate = ones(10,1,12);
setp_rate = ones(10,1,12);
Q_setpoint = [0.25;0.5;0.75;1.00;1.25;1.5;1.75;2;2.5;3;3.5;4];
mdot_setpoint = Q_setpoint.*rho;

a = 0;
b = 1;
index = 60;

for j = 1:10
    Mass_Array_Trunc = Mass_Array((a*index+1):b*index,:,:);
    

    n = 1;
    for k = 1:12

        p(b,:,k)    = polyfit(Mass_Array_Trunc(:,1,n),Mass_Array_Trunc(:,2,n),1);
        slopes(b,k) = p(b,1,k);

      n = n+1;
    end
    a = a+1;
    b = b+1;
end
hold on
for m = 1:12
   setp_rate(:,1,m) = setp_rate(:,1,m).*mdot_setpoint(m);
   mass_rate(:,1,m) = slopes(:,m);
end

setp_vec = squeeze(setp_rate);
mass_vec = squeeze(mass_rate);
dims = size(setp_vec);
calib_vec(:,1) = reshape(setp_rate,dims(1)*dims(2),1);
calib_vec(:,2) = reshape(mass_vec,dims(1)*dims(2),1);

hold on
plot(calib_vec(:,1),calib_vec(:,2),'ro')
q    = polyfit(calib_vec(:,1),calib_vec(:,2),1);
regress_slope = q(1);
regress_intercept = q(2);
yfit = polyval(q,calib_vec(:,1));
plot(calib_vec(:,1),yfit,'b')

yresid  = calib_vec(:,2) - yfit;
SEE     = sqrt(sum(yresid.^2)./(length(calib_vec)-2));
x_ave   = mean(calib_vec(:,1));
Sxx     = sum((calib_vec(:,1)-x_ave).^2);

for k = 1:length(calib_vec)
    delta_y(k) = SEE*sqrt(1+(1/length(calib_vec))+(calib_vec(k,1)-x_ave)^2/Sxx);
end
delta_y = transpose(delta_y);

end

