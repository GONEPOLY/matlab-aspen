 
    Selectivity = zeros(1,20);
R_He1 = zeros(1,20);
R_He2 = zeros(1,20);
R_He3 = zeros(1,20);

 % for pi = 1:20
 pi = 5;
    y_feed = [0.80, 0.196, 0.004];        % 进料摩尔分率% 对应 CH4, N2, He
    F_feed = 500;                         % 进料流量，kmol/h
    T = 25 + 273.15;                      % 温度，K（25°C）
    P_feed = pi*1e5;                         % 进料压力，Pa (1 bar)
    P_perm = 1;                           % 渗透侧压力，Pa (1 bar)
                              % 膜面积，m²
    piL =  1:1:20;
    A =  [200,20,5];
    NStage = 3;
    
  % 预分配数组
    nComp  = length(y_feed);
    y_perm = zeros(NStage,nComp);
    y_resd = zeros(NStage,nComp);
    F_perm = zeros(NStage,nComp);
    F_resd = zeros(NStage,nComp);
    R_He   = zeros(1,NStage);
    P_He   = zeros(1,NStage);
    A_used = zeros(1,NStage);


    deltaP = (P_feed - P_perm) ;  % 压力差均匀
He_GPU  = 163.8256/(0.73058 +P_feed/1e5) + 130.16985;
    N2_GPU  = 2.22501/(0.54359 + P_feed/1e5)  + 9.33397;
    CH4_GPU = 0.55625/(0.54359 + P_feed/1e5) + 2.33349;

F_perm = 3.348*1e-10 * 3600 * He_GPU  * 1500 * deltaP * y_feed(3)/1000;  % 单位：kmol/h