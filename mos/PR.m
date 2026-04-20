function [P_resd] = PR(y_resd, f_resd, T, P_resd0, f_resd0, y_resd0)
%% 求解参数
R = 8.314 * 10^3; %J/(kmol*K)
TC1 = 364.85; %临界温度A K
TC2 = 369.83; %临界温度B K
TB1 = 225.45; %沸点温度A K
TB2 = 231.11; %沸点温度B K
TR1 = T / TC1; %对比温度A K
TR2 = T / TC2; %对比温度A K

PC1 = 4.6 * 10^3; %临界压力A KPa
PC2 = 4.2 * 10^3; %临界压力B KPa

Q1 = TB1 / TC1;  
Q2 = TB2 / TC2;

z1 = 3 / 7  * (Q1 / (1 - Q1)) * log10(PC1) - 1; %压缩因子A
z2 = 3 / 7  * (Q2 / (1 - Q2)) * log10(PC2) - 1; %压缩因子B 

m1 = 0.37464 + 1.54226 * z1 - 0.26992 * z1^2; %偏心因子A
m2 = 0.37464 + 1.54226 * z2 - 0.26992 * z2^2; %偏心因子B
 
a1 = 0.457 * R^2 * TC1^2 *(1 - m1 * (1 - (T / TC1)^0.5))^2 / PC1; %排斥参数A
a2 = 0.457 * R^2 * TC2^2 *(1 - m2 * (1 - (T / TC2)^0.5))^2 / PC2; %排斥参数B
b1 = 0.0778 * R * TC1 / PC1; %吸引参数A
b2 = 0.0778 * R * TC2 / PC2; %吸引参数B

k12 = 1 - b2 * sqrt(a1 / a2) / (2 * b1) - b1 * sqrt(a2 / a1) / (2 * b2) - b2 * R * T * Q1 / (2 * sqrt(a2 * a1) * (T / TC1)^Q2); %二元相互作用参数

am1 = y_resd(1) * (1 - k12) * sqrt(a1); %混合排斥参数A
am2 = y_resd(2) * (1 - k12) * sqrt(a2); %混合排斥参数B
am = am1 + am2;
bm1 = y_resd(1) * b1; %混合吸引参数A
bm2 = y_resd(2) * b2; %混合吸引参数B
bm = bm1 + bm2;
%% 求解参数Vm0
am0 = y_resd0(1) * (1 - k12) * sqrt(a1) + y_resd0(2) * (1 - k12) * sqrt(a2);
bm0 = y_resd0(1) * b1 + y_resd0(2) * b2;
X = @(x) P_resd0 - R * T / (x - bm0) + am0 / (x^2 + 2 * x^2 * bm0 - bm0^2);
Vm0 = fsolve(@(x) X(x), 100);
%% 求解P_resd
f_v_resd = f_resd0 * Vm0;
P_resd = R * T / (f_v_resd / f_resd - bm) - am / ((f_v_resd / f_resd)^2 + 2 * (f_v_resd / f_resd) * bm - bm^2);

end

