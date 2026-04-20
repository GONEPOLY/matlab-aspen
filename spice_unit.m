
function [y_perm,y_resd,F_perm,F_resd,A_used] = spice_unit(y_feed,F_feed,P_feed,P_perm,A,components,PERMEANCE_GPU)
    
    % 各组分的临界常数
    n_components = components;
    %% 初始化变量
    y_perm = zeros(1,n_components);             % 渗透端各组分摩尔分率
    y_resd = zeros(1,n_components);
    F_perm = zeros(1,n_components);             % 渗透端每个微元流量
    F_resd = zeros(1,n_components);             % 截流端每个微元流量
    perm_coeff = PERMEANCE_GPU;                 % 对应组分渗透

    %% 计算每个微元的渗透流量和状态方程
    deltaP = (P_feed - P_perm) ;  % 压力差均匀分布
       
    % 计算当前微元的压力（根据PR方程）
    % [a_mix, b_mix, kij] = PR_mix_params(Tc, Pc, omega, components );
    % Vm = calculate_molar_volume(T, P_feed, a_mix, b_mix);  % 计算摩尔体积
    % P  = PR_pressure(T, Vm, a_mix, b_mix);  % 使用 PR 方程计算压力（渗余侧的压力）
  
    %% 调整膜面积，确保不过滤过量
      % A_used = adjust_area(y_feed, F_feed, perm_coeff, P_feed, P_perm , A, A_TES);
       A_used = A;
        % 计算渗透流量 J_i 基于渗透侧和渗余侧的压力差
        
        for j = 1:n_components
           
            F_perm(j) = 3.348*1e-10 * 3600 * perm_coeff(1,j) * A_used * deltaP * y_feed(1,j)/1000;  % 单位：kmol/h
            
            F_resd(j) = F_feed*y_feed(j) - F_perm(j);
           
        end
             
          % ===== 渗余组成 =====
    if sum(F_resd) > 0
        y_resd = F_resd / sum(F_resd);
    end

    % ===== 渗透组成 =====
    if sum(F_perm) > 0
        y_perm = F_perm / sum(F_perm);
    end
         
  end
