%% 计算Peng-Robinson方程的a和b参数
function [a_mix, b_mix, kij] = PR_mix_params(Tc, Pc, omega, components)
    n = length(components);  % 组分个数
    a_mix = 0;
    b_mix = 0;
    
    % 计算二元交互作用参数 k_ij
    kij = zeros(n, n);  % 初始化交互作用矩阵
    for i = 1:n
        for j = 1:n
            if i ~= j
                % 根据气体间的临界温度和临界压力计算k_ij
                k_ij = calculate_kij(Tc(i), Tc(j), Pc(i), Pc(j), omega(i), omega(j));
                kij(i, j) = k_ij;
            else
                kij(i, j) = 0;  % 对角线上的交互作用系数设为0
            end
        end
    end
end