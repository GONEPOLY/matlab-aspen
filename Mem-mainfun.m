

    % 基本参数
    T = 273.15 + 15;        % 温度 (K)
    P_feed = 20e5;          % 进料压力 (Pa)
    P_perm = 1e5;           % 渗透侧压力 (Pa)
    n = 100;                % 分段数
    dz = 1 / n;             % 归一化长度段

    % 初始摩尔分率 (feed)
    y0 = [0.15; 0.84; 0.01]; % [N2, CH4, He]
    P = linspace(P_feed, P_perm, n);

    % PR参数
    R = 8.314; % J/(mol·K)
    Tc = [126.2; 190.6; 5.2];     % K
    Pc = [3.39e6; 4.60e6; 0.23e6];% Pa
    omega = [0.04; 0.011; -0.39]; % 偏心因子

    % 渗透率 (mol/(m²·s·Pa))，假设值
    permeance = [1e-7; 5e-8; 2e-7]; % N2, CH4, He

    % 初始化
    x = y0;
    y_perm = zeros(3, n);
    flux = zeros(3, n);

    for i = 1:n
        % 当前压力
        P_i = P(i);

        % 计算PR状态系数Z
        Z = PR_Z(T, P_i, x, Tc, Pc, omega, R);

        % 计算每组分的分压和通量
        for j = 1:3
            pi_feed = x(j) * P_i;
            pi_perm = y0(j) * P_perm; % 假设渗透侧摩尔分率不变
            flux(j, i) = permeance(j) * (pi_feed - pi_perm);
        end

        % 更新渗透侧摩尔分率（简化模型：稳态）
        total_flux = sum(flux(:, i));
        if total_flux > 0
            y_perm(:, i) = flux(:, i) / total_flux;
        else
            y_perm(:, i) = [0; 0; 0];
        end
    end

    % 绘图
    figure;
    plot(linspace(0, 1, n), y_perm(1, :), 'r', 'LineWidth', 2); hold on;
    plot(linspace(0, 1, n), y_perm(2, :), 'b', 'LineWidth', 2);
    plot(linspace(0, 1, n), y_perm(3, :), 'g', 'LineWidth', 2);
    legend('N_2', 'CH_4', 'He');
    xlabel('膜位置 (归一化)');
    ylabel('渗透侧摩尔分率');
    title('膜分离渗透侧组分分布');
    grid on;
end

function Z = PR_Z(T, P, y, Tc, Pc, omega, R)
    % Peng-Robinson 状态方程混合物的 Z 系数计算 (近似)
    ncomp = length(y);
    Tr = T ./ Tc;
    kappa = 0.37464 + 1.54226 .* omega - 0.26992 .* omega.^2;
    alpha = (1 + kappa .* (1 - sqrt(Tr))).^2;
    a = 0.45724 * R^2 .* Tc.^2 ./ Pc .* alpha;
    b = 0.07780 * R .* Tc ./ Pc;

    % 混合物参数
    amix = 0;
    bmix = 0;
    for i = 1:ncomp
        bmix = bmix + y(i) * b(i);
        for j = 1:ncomp
            aij = sqrt(a(i) * a(j));
            amix = amix + y(i) * y(j) * aij;
        end
    end

    A = amix * P / (R^2 * T^2);
    B = bmix * P / (R * T);

    % 求解 Z：三次方程 Z^3 + c2*Z^2 + c1*Z + c0 = 0
    coeff = [1, -1 + B, A - 3*B^2 - 2*B, -A*B + B^2 + B^3];
    rootsZ = roots(coeff);
    Z = max(real(rootsZ)); % 取最大实根
