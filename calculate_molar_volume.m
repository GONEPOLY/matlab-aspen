%% 计算气体的摩尔体积
function Vm = calculate_molar_volume(T, P, a, b)
    R = 8.314;  % J/mol·K
    A = a * P / (R^2 * T^2);
    B = b * P / (R * T);
    
    % 求解立方方程
    coeff = [1, -(1 - B), A - 2*B - 3*B^2, -(A*B - B^2 - B^3)];
    Z_roots = roots(coeff);  % 求解压缩因子 Z 的根
    Z = max(Z_roots);  % 选择最大的根作为实际压缩因子
    
    % 计算摩尔体积
    Vm = Z * R * T / P;  % 摩尔体积公式
end