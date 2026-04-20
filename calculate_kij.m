function k_ij = calculate_kij(Tc_i, Tc_j, Pc_i, Pc_j, omega_i, omega_j)
    % 使用简单的公式估算k_ij
    T_ij = (Tc_i + Tc_j) / 2;  % 临界温度的平均值
    P_ij = (Pc_i + Pc_j) / 2;  % 临界压力的平均值
    k_ij = 0.37464 + 1.54226 * (1 - sqrt(T_ij / (Tc_i * Tc_j))) - 0.26992 * omega_i * omega_j;
end