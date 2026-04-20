clc
clear
%%------------------------------------------------------------------------------%%
  %% 模型基础参数设定=====================================================================================================
    tick = 1;
    NStage = 2;
   
  % 预分配数组和变量声明===================================================================================================
   
    lown = 300;
    database = zeros(lown, 8); 
    Selectivity = zeros(1,20);
    y_feed =  zeros(1,2);
    nComp  = length(y_feed);
    y_perm = zeros(NStage,nComp);
    y_resd = zeros(NStage,nComp);
    F_perm = zeros(NStage,nComp);
    F_resd = zeros(NStage,nComp);
    R =  zeros(lown,nComp); %% Recovery  回收率
    P =  zeros(lown,nComp); %% Purity 纯度
   %%=====================================================================================================================
    % 读取每组数据为矩阵 %%====================================================================================================%%
    % 获取当前时间（datetime 类型，带格式）
            Current_Time = datetime('now','Format','yyyy_MM_dd_HH_mm');

    % 转换成字符串（用于文件名）
            Current_Time_str = datestr(Current_Time,'yyyy_mm_dd_HH_MM');

    % %%====================================================================================================%%
  
   

    % %%参数写入EXCEL 路径说明==============================================================================================%%
    filename_Data = sprintf('C:\\Users\\AIBOOM\\OneDrive\\Documents\\Graduate level documents\\Master thesis\\SEP C7H14-C7H8\\Data output File\\OutputData_%s.xlsx', Current_Time_str);
    filename = 'C:\Users\AIBOOM\OneDrive\Documents\Graduate level documents\Master thesis\SEP C7H14-C7H8\single componet cal.xlsx';
   %%============================================================================================================================




    % %%初始参数要求规定======================================================================================%%
    MCH_feed = 0.5;   % 输入浓度
    membrane_id = 1;  % 膜编号（1/2/3）
    PERMEANCE_GPU1 = Flux_model(filename, membrane_id, MCH_feed); %% 拟合模型，计算渗透率
    Write_Sheet  =  membrane_id;
    y_feed = [ MCH_feed, 1-MCH_feed];        % 进料摩尔分率% 对应 mch/tol
    F_feed = 181.44;                         % 进料流量，kmol/h
    T = 25 + 273.15;                         % 温度，K（25°C）
    P_feed = 1*1e5;                          % 进料压力，Pa (1 bar)
    P_perm = 0.00001;                           % 渗透侧压力，Pa (1 bar)
                                             % 膜面积
    components = 2;                          % 组分数
    A2 = 0;
    A1_list = 1000:1000:20000;                  % 一级膜面积扫描
    A2_list = 50:50:500;                     % 二级膜面积扫描（可选）
   
    target_purity = 0.99;                    % 目标纯度

    %%========================================================================================================%%
   
    
    %%% ASPEN CALL
    %%% ACTIVIATE============================================================================================================================
    Aspen = actxserver('Apwn.Document.41.0');
    Aspen.invoke('InitFromArchive2','C:\Users\AIBOOM\OneDrive\Documents\Graduate level documents\Master thesis\SEP C7H14-C7H8\simu sep Toluene&Methylcyclohexane\COOLVCCU-DUTY.apw');
    Aspen.visible = 1;

    %%========================================================================================================================================
   
    %%膜程序调用和结果计算======================================================================================================================
   
    
    for A1 = A1_list
     
        NStage_Fill = 1;

           % 第一阶段
            [y_perm(NStage_Fill,:),y_resd(NStage_Fill,:),F_perm(NStage_Fill,:),F_resd(NStage_Fill,:),A_used] = spice_unit(y_feed,F_feed,P_feed,P_perm,A1,components,PERMEANCE_GPU1);
            F_resd_sum(NStage_Fill) =  sum(F_resd(NStage_Fill,:)); 
            F_perm_sum(NStage_Fill) =  sum(F_perm(NStage_Fill,:)); 
           
           
            %% Aspen 参数预设写入
            Aspen.Application.Tree.FindNode('\Data\Streams\F1\Input\FLOW\MIXED\METHY-01').Value = y_perm(NStage_Fill,1);
            Aspen.Application.Tree.FindNode('\Data\Streams\F1\Input\FLOW\MIXED\TOLUE-01').Value = y_perm(NStage_Fill,2);
            Aspen.Application.Tree.FindNode('\Data\Streams\F1\Input\TOTFLOW\MIXED').Value       = F_perm_sum(NStage_Fill);     
            Run2(Aspen.Engine);

            %%% Aspen 计算结果获取 
            VCCU_DUTY(1,NStage_Fill) = Aspen.Application.Tree.FindNode('\Data\Blocks\VCCU1\Output\BRAKE_POWER').Value;
            COOL_DUTY(1,NStage_Fill) = Aspen.Application.Tree.FindNode('\Data\Blocks\COOL1\Output\QNET').Value;
            %%  参数计算和汇总

            COOL_DUTY_Total          = sum(COOL_DUTY);
            VCCU_DUTY_Total          = sum(VCCU_DUTY);
            database(tick,:) = [A1, A2, R(tick,1 ), R(tick,2 ), P(tick,1), P(tick,2),  VCCU_DUTY_Total, COOL_DUTY_Total];
            
            
      
      %% 二级和多级膜计算

      
         
        
          for A2 = A2_list
              NStage_Fill = 2;
              %% 计算第二级膜上渗透性
              PERMEANCE_GPU2 = Flux_model(filename, membrane_id, y_resd(NStage_Fill-1,1));
            
            [y_perm(NStage_Fill,:),y_resd(NStage_Fill,:),F_perm(NStage_Fill,:),F_resd(NStage_Fill,:),A_used] = spice_unit(y_resd(NStage_Fill-1,:), F_resd_sum(NStage_Fill-1),P_feed,P_perm,A2,components,PERMEANCE_GPU2);
            
             % 一级膜回收率与纯度
            R(tick,NStage_Fill-1)     =  (y_resd(NStage_Fill-1,1)*F_resd_sum(NStage_Fill-1))/(F_feed * y_feed(1));  %% MCH Recovery  回收率
            P(tick,NStage_Fill-1)     =  y_resd(NStage_Fill-1,1);        %% MCH Purity 纯度
            % 二级膜回收率与纯度
            F_resd_sum(NStage_Fill)     =  sum(F_resd(NStage_Fill,:)); 
            F_perm_sum(NStage_Fill)     =  sum(F_perm(NStage_Fill,:)); 
            R(tick,NStage_Fill)         =  (y_resd(NStage_Fill,1) * F_resd_sum(NStage_Fill))/(F_resd_sum(NStage_Fill-1) * y_resd(NStage_Fill-1,1));      %% MCH Recovery  回收率
            P(tick,NStage_Fill)         =  y_resd(NStage_Fill,1);                                                           %% MCH Purity    纯度
            
      
        %% Aspen 参数预设写入
        Aspen.Application.Tree.FindNode('\Data\Streams\F2\Input\FLOW\MIXED\METHY-01').Value = y_perm(NStage_Fill,1);
        Aspen.Application.Tree.FindNode('\Data\Streams\F2\Input\FLOW\MIXED\TOLUE-01').Value = y_perm(NStage_Fill,2);
        Aspen.Application.Tree.FindNode('\Data\Streams\F2\Input\TOTFLOW\MIXED').Value       = F_perm_sum(NStage_Fill);
        Run2(Aspen.Engine);
        
        %%% Aspen 计算结果获取
        VCCU_DUTY(1,NStage_Fill)   = Aspen.Application.Tree.FindNode('\Data\Blocks\VCCU2\Output\BRAKE_POWER').Value;
        COOL_DUTY(1,NStage_Fill)   = Aspen.Application.Tree.FindNode('\Data\Blocks\COOL2\Output\QNET').Value;
        %%  参数计算和汇总
        COOL_DUTY_Total              = sum(COOL_DUTY);
        VCCU_DUTY_Total              = sum(VCCU_DUTY);
        database(tick,:) = [A1, A2, R(tick,1 ), R(tick,2 ), P(tick,1), P(tick,2) ,VCCU_DUTY_Total, COOL_DUTY_Total];
        
        tick = tick + 1;
       

      end
       
       
    end
        
        %%% 表头编制==============================================================================
        headers_A = arrayfun(@(x) sprintf('第%d级膜面积', x), 1:NStage, 'UniformOutput', false);
        % Step 2: 生成 R_He 的表头
        headers_R = arrayfun(@(x) sprintf('MCH回收率%d',x), 1:NStage, 'UniformOutput', false);
        % Step 3: 生成 P_He 的表头
        headers_P = arrayfun(@(x) sprintf('MCH纯度%d',x), 1:NStage, 'UniformOutput', false);
        % Step 4: 生成 duty 的表头
        headers_eduty = arrayfun(@(x) sprintf('总电耗%d',x), 1, 'UniformOutput', false);
        headers_cduty = arrayfun(@(x) sprintf('总冷耗%d',x), 1, 'UniformOutput', false);
        % Step last:
        % 合并成完整表头===========================================================================
        headers = [headers_A, headers_R, headers_P, headers_eduty, headers_cduty];
       
        %%% 写入表头===============================================================================
        writecell(headers, filename_Data, 'Sheet', Write_Sheet , 'Range','A1');
       
        %%% 写入数据===============================================================================
        database = database(1:tick-1,:);
        writematrix(database, filename_Data,'Sheet', Write_Sheet , 'Range','A2');
   