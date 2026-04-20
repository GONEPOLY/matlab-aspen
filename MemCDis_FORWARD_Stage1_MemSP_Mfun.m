clc
clear
%%------------------------------------------------------------------------------%%
%% 参数设定
   
   
    NStage = 1;
    pi = [10, 15 ,20];
    y_feed = [0.80, 0.196, 0.004];        % 进料摩尔分率% 对应 CH4, N2, He
    F_feed = 500;                         % 进料流量，kmol/h
    T = 25 + 273.15;                      % 温度，K（25°C）
    A_TES = 500;
    tick = 1;
    
  % 预分配数组
    A = zeros(1,NStage);
    database = zeros(10000,30);
    Selectivity = zeros(1,20);
    R_He1 = zeros(1,20);
    R_He2 = zeros(1,20);
    R_He3 = zeros(1,20);
    nComp  = length(y_feed);
    y_perm = zeros(NStage,nComp);
    y_resd = zeros(NStage,nComp);
    F_perm = zeros(NStage,nComp);
    F_resd = zeros(NStage,nComp);

    R_He   = zeros(1,NStage);
    P_He   = zeros(1,NStage);
    A_used = zeros(15,NStage);

    Total_COM_DUTY = zeros(1,4);
    Total_col_DUTY = zeros(1,7);
    Total_reb_DUTY = zeros(1,3); 
    piL =  1:1:20;
    %% 二分法求解预设
                    lower_bound = [2 ,1 , 1];
                    upper_bound = [7, 8 , 4.5];
                    tolerance = [1e-3 , 0.01 ,5*1e-3];
                    target_value = [0.97 ,1.9,0.90];
                    DT_Ratio_Value = zeros(1,3);
    %%
   %%------------------------------------------------------------------------------%%
    %%Aspen 链接和显示
    % 获取当前时间（datetime 类型，带格式）
            Current_Time = datetime('now','Format','yyyy_MM_dd_HH_mm');
            
            % 转换成字符串（用于文件名）
            Current_Time_str = datestr(Current_Time,'yyyy_mm_dd_HH_MM');
           
            

            % 拼接文件名
            filename = ['C:\Users\91087\Downloads\Forgu-backup1.3\mem_forward_connect_Onlydis_result_' Current_Time_str '.xlsx'];
            % cacheFile = 'C:\Users\91087\Downloads\Forgu-backup1.3\Mem model\CacheFile\mem_forward_connect_Onlydis_OpRatioCached.mat';
            

    Aspen = actxserver('Apwn.Document.41.0');
    % Aspen = actxGetRunningServer('Apwn.Document');
    Aspen.invoke('InitFromArchive2','C:\Users\91087\Downloads\Forgu-backup1.3\Backup-AspenFile\dist-HE2-FORWARD.apw');
    % filename = Aspen.Tree.FindNode('C:\Users\91087\Downloads\Forgu-backup1.3\Backup-AspenFile\dist-HE2-FORWARD.apw').Value;
    Aspen.visible = 1;
    
   




  for i_1 = 1:3
  
    P_feed = pi(i_1)*1e5;                         % 进料压力，Pa (1 bar)
    P_perm = 1;                                   % 渗透侧压力，Pa (1 bar)
                                                  % 膜面积，m²
       for A_1 = 100 :100 :1000
                  A_2 = 5;
                  A_3 = 1;
                  Z =  [A_1,A_2,A_3];
                  A = Z(1,1:NStage);
       % 第一阶段
        [y_perm(1,:),y_resd(1,:),F_perm(1,:),F_resd(1,:),A_used(pi(i_1),1),S1] = spice_unit(y_feed,F_feed,P_feed,P_perm,A(1));
        R_He(1) = F_perm(1,3) / (F_feed * y_feed(3));
        P_He(1) = y_perm(1,3);
        % 后续阶段
           
       for i = 2:NStage
        F_perm_sum = sum(F_perm(i-1,:));
        [y_perm(i,:),y_resd(i,:),F_perm(i,:),F_resd(i,:),A_used(pi(i_1),i),S1] =spice_unit(y_perm(i-1,:),F_perm_sum,P_feed,P_perm,A(i));
        R_He(i) = F_perm(i,3) / (F_feed *y_feed(3));
        P_He(i) = y_perm(i,3);
       end
        
              
                Selectivity(pi(i)) = S1;
                input1 = sum(F_resd(NStage,:));
                input2 = sum(F_perm(NStage,:));
                %% 膜下游参数给定至塔
                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\TOTFLOW\MIXED').value =  input1;  
                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\FLOW\MIXED\HELIU-02').value = y_resd(NStage,3); 
                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\FLOW\MIXED\NITRO-01').Value = y_resd(NStage,2); 
                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\FLOW\MIXED\METHA-01').Value = y_resd(NStage,1);
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\TOTFLOW\MIXED').Value        =  input2;  
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\FLOW\MIXED\HELIU-02').Value  = y_perm(NStage,3);
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\FLOW\MIXED\NITRO-01').Value  = y_perm(NStage,2);
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\FLOW\MIXED\METHA-01').Value  = y_perm(NStage,1);
             
                %% DT1_Ratio
                    lb = lower_bound(1); ub = upper_bound(1);
                    purity_1 = 0.5;
                    dt_ratio =  round((lb+ub)/2,4);
                    t1 = tic;
                       
                        
                    while  purity_1 < target_value(1)  && abs(purity_1 - target_value(1)) > tolerance(1)
                        Aspen.Application.Tree.FindNode('\Data\Blocks\DT1\Input\BASIS_RR').value = dt_ratio;
                        Run2(Aspen.Engine);
                        purity_1 = Aspen.Application.Tree.FindNode('\Data\Streams\DT1S\Output\MOLEFRAC\MIXED\METHA-01').value;
                        
                        % if  abs(purity - target_value(1)) < best_diff
                        %     best_diff = abs(purity - target_value(1));
                        %     DT_Ratio_Value(1) = dt_ratio;
                        % end
                        % 二分法更新上下界
                        if purity_1 < target_value(1)
                          dt_ratio =  lb + 0.01;
                        end
                      
                       DT_Ratio_Value(1) = dt_ratio;
                       if  dt_ratio <1
                            break
                       end 
                    end
                        celapsed_time_t1 = toc(t1);  % 存到变量
                        fprintf('t1运行时长: %.4f 秒\n', celapsed_time_t1);
                    %% DT2_Ratio
                    lb = lower_bound(2); ub = upper_bound(2);
                    flow_HE2 = 0.5;
                    dt_ratio =  round((lb+ub)/2,3);
                       t2 = tic;
                    while flow_HE2 < target_value(2) && abs(flow_HE2- target_value(2)) > tolerance(1)
                        Aspen.Application.Tree.FindNode('\Data\Blocks\DT2\Input\BASIS_RR').value = dt_ratio;
                        Run2(Aspen.Engine);
                        flow_HE2 = Aspen.Application.Tree.FindNode('\Data\Streams\DT2G\Output\MOLEFLOW\MIXED\HELIU-02').value;
                        
                        % if  abs(flow - target_value(2)) < best_diff
                        %     best_diff = abs(flow - target_value(2));
                        %     DT_Ratio_Value(2) = dt_ratio;
                        % end
                        % 二分法更新上下界
                        if  flow_HE2 > target_value(2)
                            ub = dt_ratio;
                        else
                            lb = dt_ratio;
                        end
                        dt_ratio =  round((lb+ub)/2,3);
                        DT_Ratio_Value(2) = dt_ratio;
                        if  dt_ratio <=1
                            break
                        end
                    end
                        celapsed_time_t2 = toc(t2);  % 存到变量
                        fprintf('t2运行时长: %.4f 秒\n', celapsed_time_t2);
                    %% DT3_Ratio
                    lb = lower_bound(3); ub = upper_bound(3);
                    purity_3 =0.5;
                    dt_ratio =  round((lb+ub)/2,4);
                    t3 = tic;
                     DT_Ratio_Value(3) = 1.2;
                     while  purity_3< target_value(3)  && abs(purity_3 - target_value(3)) > tolerance(3)
                               if  DT_Ratio_Value(3) < 1
                                  DT_Ratio_Value(3) = 1 ;
                                   break
                               end
                        Aspen.Application.Tree.FindNode('\Data\Blocks\DT3\Input\BASIS_RR').value = dt_ratio;
                        Run2(Aspen.Engine);
                        purity_3 = Aspen.Application.Tree.FindNode('\Data\Streams\DT3G\Output\MOLEFRAC\MIXED\HELIU-02').value;
                        
                        % if  abs(purity - target_value(3)) < best_diff
                        %     best_diff = abs(purity - target_value(3));
                        %     DT_Ratio_Value(3) = dt_ratio;
                        % end
                        % 二分法更新上下界
                        if purity_3 < target_value(3)
                              dt_ratio  = dt_ratio + 0.01 ;
                       
                        end
                        % dt_ratio =  round((lb+ub)/2,3);
                        DT_Ratio_Value(3) = dt_ratio;
                       
                    end
                     celapsed_time_t3 = toc(t3);  % 存到变量
                        fprintf('t3运行时长: %.4f 秒\n', celapsed_time_t3);
                    %% 回流比计算数值输入至流程模拟
                    Aspen.Application.Tree.FindNode('\Data\Blocks\DT1\Input\BASIS_RR').value = DT_Ratio_Value(1);
                    Aspen.Application.Tree.FindNode('\Data\Blocks\DT2\Input\BASIS_RR').value = DT_Ratio_Value(2);
                    Aspen.Application.Tree.FindNode('\Data\Blocks\DT3\Input\BASIS_RR').value = DT_Ratio_Value(3);
                   
                    range = 0.2;  % 容差

                    % 初始化 lower_bound 和 upper_bound 数组
                    lower_bound = DT_Ratio_Value - range;  % 直接减去容差
                    upper_bound = DT_Ratio_Value + range;  % 直接加上容差
                            
                    Run2(Aspen.Engine);
                   
                    
                            %%% 读取所需的结果数值
                            COM_names = {'N2-COM1','N2-COM2','N2-COM3','F2-M-COM'};
                            Total_COM_DUTY = zeros(1,numel(COM_names));
                            for k = 1:numel(COM_names)
                                Total_COM_DUTY(k) = Aspen.Application.Tree.FindNode(['\Data\Blocks\', COM_names{k}, '\Output\BRAKE_POWER']).Value;
                            end
                            
                            % Cooler / Column
                            COL_names = {'N2-COL1','N2-COL2','N2-COL3','DT1','DT2','DT2','COLP4'};
                            COL_fields = {'QNET','QNET','QNET','COND_DUTY','COND_DUTY','COND_DUTY','QNET'};
                            Total_col_DUTY = zeros(1,numel(COL_names));
                            for k = 1:numel(COL_names)
                                Total_col_DUTY(k) = Aspen.Application.Tree.FindNode(['\Data\Blocks\', COL_names{k}, '\Output\', COL_fields{k}]).Value;
                            end
                            
                            % Reboiler
                            REB_names = {'DT1','DT2','DT3'};
                            Total_reb_DUTY = zeros(1,numel(REB_names));
                            for k = 1:numel(REB_names)
                                Total_reb_DUTY(k) = Aspen.Application.Tree.FindNode(['\Data\Blocks\', REB_names{k}, '\Output\REB_DUTY']).Value;
                            end

           
                   
                    N2_Cycel_Condensor = sum(Total_col_DUTY([1 ,2 ,3 ,7]));

                    Oput_HE_R = Aspen.Application.Tree.FindNode('\Data\Streams\DT3G\Output\MOLEFLOW\MIXED\HELIU-02').value / (F_feed*y_feed(3));
                    Oput_HE_P = Aspen.Application.Tree.FindNode('\Data\Streams\DT3G\Output\MOLEFRAC\MIXED\HELIU-02').value;
                    
                    % --- 汇总 ---
                    Oput_HE_RP = [Oput_HE_R,Oput_HE_P];
                    Total_DUTY_sum     = [sum(Total_COM_DUTY), sum(Total_col_DUTY),sum(Total_reb_DUTY)];
                    Distill_col_reb    = [Total_col_DUTY(4) ,Total_reb_DUTY(1),Total_col_DUTY(5) ,Total_reb_DUTY(2),Total_col_DUTY(6) ,Total_reb_DUTY(3)];
                    % --- 保存到 database ---
                    database(tick,:) = [pi(i_1), A, R_He, P_He, Total_DUTY_sum, Oput_HE_RP, Total_COM_DUTY, Total_col_DUTY, Total_reb_DUTY...
                    N2_Cycel_Condensor , Distill_col_reb];
                    tick = tick + 1;
                    Call_WriteCell(database ,tick, NStage,filename);
                    disp(['当前 tick = ', num2str(tick)]);
        end 
       
  end          
        
                   
                            
                   
            
           
                   
                    
                 

    
