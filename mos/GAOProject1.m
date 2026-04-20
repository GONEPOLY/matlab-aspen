format long g
hh = 1;
y_feed2(1) = 0.5;
kk = 1;
while hh  > 0.001
%% 导入MATLAB数据
    hysys = hyconnect;                               % Create a connection to Hysys.
    spreadb = hyspread(hysys, 'SPRDSHT-CONP1');          % Create a connection to a spreadsheet.
    m = hycell(spreadb, {'c1','c2','c3'}); % Connect to the cells  in the spreadsheet.
    mm = hyvalue(m);
    f_feed = mm(1);
    P_feed = mm(2);%kpa
    y_feed1 = mm(3);
    y_feed2(kk + 1) = mm(4);
    t_feed = mm(5);
    hh = abs(y_feed2(kk+1) - y_feed2(kk))/ y_feed2(kk);
    if hh <  0.001
        break
    end
    %% 渗透侧程序嵌入 
    J1 = 120 * 3.35 * 10^(-10) * 3600; % 渗透率 kmol/(m2·h·kPa) C3H6
    S12 = 50; %选择性
    A = 80; %膜面积 m2
    %f_feed = 574.2557831; %进料量 kmol/h
    %P_feed = 800; %初始压力 kPa
    %y_feed1 = 0.904; %初始A组分进料 C3H6
    %y_feed2 = 0.096; %初始B组分进料 C3H8
    N = 106; %切割单元数
    y_feed3 = y_feed2(2);
    kk = kk + 1;
    [f_c3h6_resd, f_c3h8_resd, f_c3h6_perm, f_c3h8_perm, P_resdN] = Mem_Sep1(J1, S12, A, f_feed, P_feed, y_feed1, y_feed3, N, t_feed);
    f_resd = [f_c3h6_resd, f_c3h8_resd]; % 渗余侧组分流量kmol/h
    f_perm = [f_c3h6_perm, f_c3h8_perm]; % 渗透侧组分流量kmol/h
    P_perm = 0.001 * 100;%kpa

    %% 导出MATLAB数据
    hysys = hyconnect;                              % Create a connection to Hysys.
    spreada = hyspread(hysys, 'SPRDSHT-1');         % Create a connection to a spreadsheet

    %% 渗余气参数输入
    %d_resd = hycell(spreada, {'B4', 'B3'});                % Connect to the cells in the spreadsheet. 
    %hyset(d_resd(1), f_resd(1));                           % Change the value
    %hyset(d_resd(2), f_resd(2));

    %% 渗透气参数输入
    d_perm = hycell(spreada, {'B5', 'B6'});                % Connect to the cells in the spreadsheet. 
    hyset(d_perm(1), f_perm(1));                           % Change the value
    hyset(d_perm(2), f_perm(2));

    %% 压力参数输入
    %d_resd = hycell(spreada, {'B7', 'B8'});                % Connect to the cells in the spreadsheet. 
    %hyset(d_resd(1), P_perm);                           % Change the value
    %hyset(d_resd(2), P_perm);

    %d_resd = hycell(spreada, {'B8', 'B7'});                % Connect to the cells in the spreadsheet. 
    %hyset(d_resd(1), P_resdN);                           % Change the value
    %hyset(d_resd(2), P_resdN);

    while hyissolving(hysys)==1      % Check if the solver is running.
    end
end


