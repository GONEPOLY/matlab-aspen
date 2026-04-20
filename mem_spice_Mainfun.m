clc
clear
        %% 参数设定
           %%Aspen 链接和显示
            % 获取当前时间（datetime 类型，带格式）
            Current_Time = datetime('now','Format','yyyy_MM_dd_HH_mm');
            
            % 转换成字符串（用于文件名）
            Current_Time_str = datestr(Current_Time,'yyyy_mm_dd_HH_MM');

        filename = ['C:\Users\91087\Downloads\Forgu-backup1.3\mem_result_' Current_Time_str '.xlsx'];
        Selectivity = zeros(1,20);
        R_He1 = zeros(1,20);
        R_He2 = zeros(1,20);
        R_He3 = zeros(1,20);
            y_feed = [0.80, 0.196, 0.004];        % 进料摩尔分率% 对应 CH4, N2, He
            F_feed = 500;                         % 进料流量，kmol/h
            T = 25 + 273.15;                      % 温度，K（25°C） 
            % A =  [200,20,5];
            NStage = 1;
            A_TES = 500;
   
          % 预分配数组
            nComp  = length(y_feed);
            y_perm = zeros(NStage,nComp);
            y_resd = zeros(NStage,nComp);
            F_perm = zeros(NStage,nComp);
            F_resd = zeros(NStage,nComp);
        
            R_He    = zeros(1,NStage);
            P_He    = zeros(1,NStage);
            R_CH4   = zeros(1,NStage);
            P_CH4   = zeros(1,NStage);
        
            A_used = zeros(15,NStage);
            pi = [10, 15 ,20];
            Total_COM_DUTY = zeros(1,4);
            Total_col_DUTY = zeros(1,5);
            Total_reb_DUTY = zeros(1,1);
            database = zeros(10000,6*NStage);
            tick = 1;
            A = zeros(1,NStage);
  for i_1 = 1:3
   
 
    P_feed = pi(i_1)*1e5;                         % 进料压力，Pa (1 bar)
    P_perm = 1;                           % 渗透侧压力，Pa (1 bar)
                              % 膜面积，m²
    piL =  1:1:20;

    for A_1 = 50 :50 :1500
         % for  A_2 = 5:5:100
         %    for A_3 = 1:1:20
                  % Z =  [A_1,A_2,A_3];
                  % A = Z(1,1:NStage);
                  A = A_1;
                  disp(A);
 % for A_TES = 500:2:5000
   % 第一阶段
    [y_perm(1,:),y_resd(1,:),F_perm(1,:),F_resd(1,:),A_used(pi(i_1),1),S1] = spice_unit(y_feed,F_feed,P_feed,P_perm,A(1));
    R_He(1) = F_perm(1,3) / (F_feed * y_feed(3));
    P_He(1) = y_perm(1,3);
    R_CH4(1) = F_resd(1,1) / (F_feed * y_feed(1));
    P_CH4(1) = y_resd(1,1);
    % if abs( R_He(pi(i),1) - 0.93) <= 0.001
    %     break
    % end

    % 后续阶段
                   
                           for i = 2:NStage
                            F_perm_sum = sum(F_perm(i-1,:));
                            [y_perm(i,:),y_resd(i,:),F_perm(i,:),F_resd(i,:),A_used(pi(i_1),i),S1] =spice_unit(y_perm(i-1,:),F_perm_sum,P_feed,P_perm,A(i));
                            R_He(i) = F_perm(i,3) / (F_feed *y_feed(3));
                            P_He(i) = y_perm(i,3);
                            R_CH4(i) = F_resd(i,1) / (F_feed *y_feed(1));
                            P_CH4(i) = y_resd(i,1);
                          end
       
              
                Selectivity(pi(i)) = S1;
               
                database(tick,:) = [P_feed , A , R_He, P_He,R_CH4, P_CH4];
                tick = tick + 1;
        %     end
        % end
    end
  end 
       
      
        
        
        
        headers_pres =  '上游压力' ;
        headers_A = arrayfun(@(x) sprintf('第%d级膜面积', x), 1:NStage, 'UniformOutput', false);
        % Step 2: 生成 R_He 的表头
        headers_HE2_R = arrayfun(@(x) sprintf('He回收率%d',x), 1:NStage, 'UniformOutput', false);
        % Step 3: 生成 P_He 的表头
        headers_HE2_P = arrayfun(@(x) sprintf('He纯度%d',x), 1:NStage, 'UniformOutput', false);
        % Step 2: 生成 R_CH4 的表头
        headers_CH4_R = arrayfun(@(x) sprintf('CH4回收率%d',x), 1:NStage, 'UniformOutput', false);
        % Step 3: 生成 P_CH4 的表头
        headers_CH4_P = arrayfun(@(x) sprintf('CH4纯度%d',x), 1:NStage, 'UniformOutput', false);
        % Step last: 合并成完整表头
        headers = [headers_pres,headers_A, headers_HE2_R, headers_HE2_P,headers_CH4_R,headers_CH4_P];
        writecell(headers, filename, 'Sheet',NStage, 'Range','A1');
        database = database(1:tick-1,:);
        writematrix(database, filename,'Sheet',NStage, 'Range','A2');

   
  

    
