%% 计算PR方程的压力

function P = PR_pressure(T, Vm, a, b)
    R = 8.314;  % J/mol·K
    P = (R*T)/(Vm - b) - a / (Vm^2 + 2*b*Vm - b^2);
 end