
    %% 参数设定
    components = {'CH4', 'N2', 'He'};
    n_components = length(components);
    y_feed = [0.80, 0.195, 0.005];        % 进料摩尔分率
    z_feed = 500;                         % 进料流量，kmol/h
    T = 25 + 273.15;                      % 温度，K（25°C）
    P_feed = 1e6;                         % 进料压力，Pa (1 MPa)
    P_perm = 1e5;                         % 渗透侧压力，Pa (1 bar)
    A = 10;                               % 膜面积，m²
    n_elements = 1000;                    % 将膜分为1000个微元

    % 各组分的临界常数
    Tc = [190.6, 126.2, 132.6];   % 临界温度 (K)
    Pc = [4599000, 3380000, 2285000];   % 临界压力 (Pa)
    omega = [0.037, 0.037, 0.030];  % 气体偏心因子

    % 渗透选择性（相对于N2，示意值）
    alpha = [2.5, 1.0, 10.0];  % 假设 CH4 相对 N2 为 2.5，He 为 10.0
    
    % 渗透系数（单位：kmol/m²·h·Pa），可根据实验数据来设定
    P_perm_coeff = [0.5, 0.2, 1.5];  % 对应 CH4, N2, He
    
    %% 初始化变量
    P = zeros(1, n_elements);  % 初始化每个微元的压力
    y_perm = zeros(3, n_elements);             % 渗透端各组分摩尔分率
    F_perm = zeros(3, n_elements);             % 渗透端每个微元流量
    total_perm_flow = 0;

    %% 计算每个微元的渗透流量和状态方程
    deltaP = (P_feed - P_perm) / (n_elements - 1);  % 压力差均匀分布

    % 设置第一个微元的入口压力（渗余侧初始压力等于进料压力）
    P(1) = P_feed;  
    
    %% 计算每个微元的渗透流量
    for i = 2:n_elements
        % 计算当前微元的压力（根据PR方程）
        [a_mix, b_mix, kij] = PR_mix_params(Tc, Pc, omega, components );
        Vm = calculate_molar_volume(T, P(i-1), a_mix, b_mix);  % 计算摩尔体积
        P(i) = PR_pressure(T, Vm, a_mix, b_mix);  % 使用 PR 方程计算压力（渗余侧的压力）

        % 计算渗透流量 J_i 基于渗透侧和渗余侧的压力差
        for j = 1:3
            flux = P_perm_coeff(j) * A * (P(i-1) - P_perm) * y_feed(j);  % 单位：kmol/m²·h·Pa
            F_perm(j, i) = flux;  % 计算每个微元的渗透流量
            total_perm_flow = total_perm_flow + F_perm(j, i);  % 累加总渗透流量
        end
        % 计算渗透端各组分组成
        y_perm(:, i) = F_perm(:, i) / total_perm_flow;
    end

% 计算a_mix和b_mix
               for i = 1:n_components
                       for j = 1:n_components
                                a_i = 0.45724 * (8.314^2) * Tc(i)^2 / Pc(i);
                                b_i = 0.07780 * 8.314 * Tc(i) / Pc(i);
                                a_j = 0.45724 * (8.314^2) * Tc(j)^2 / Pc(j);
                                b_j = 0.07780 * 8.314 * Tc(j) / Pc(j);
            
                               a_mix = a_mix + x(i)^2 * a_i + 2 * x(i) * x(j) * sqrt(a_i * a_j) * (1 - kij(i, j));
                               b_mix = b_mix + x(i) * b_i;
                      end
                end







