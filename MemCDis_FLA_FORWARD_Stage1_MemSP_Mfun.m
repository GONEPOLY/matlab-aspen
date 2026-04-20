clc
clear
%% 参数设定
    Aspen = actxserver('Apwn.Document.41.0');
    Aspen.invoke('InitFromArchive2','C:\Users\91087\Downloads\Forgu-backup1.3\Backup-AspenFile\FLASH-HE2-FORWARD.apw');
    Aspen.visible = 1;


filename = 'C:\Users\91087\Downloads\Forgu-backup1.3\mem_forward_connect_dis-fla_result.xlsx';
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

    R_He   = zeros(1,NStage);
    P_He   = zeros(1,NStage);
    A_used = zeros(15,NStage);
    pi = [10, 15 ,20];
    Total_COM_DUTY = zeros(1,4);
    Total_col_DUTY = zeros(1,5);
    Total_reb_DUTY = zeros(1,1);
    database = zeros(10000,3+6*NStage);
    tick = 1;
    A = zeros(1,NStage);
  for i_1 = 1:3
   
 
    P_feed = pi(i_1)*1e5;                         % 进料压力，Pa (1 bar)
    P_perm = 1;                           % 渗透侧压力，Pa (1 bar)
                              % 膜面积，m²
    piL =  1:1:20;

    for A_1 = 50 :50 :1500
          A_2 = 5;
            A_3 = 1;
                  Z =  [A_1,A_2,A_3];
                  A = Z(1,1:NStage);
 % for A_TES = 500:2:5000
   % 第一阶段
    [y_perm(1,:),y_resd(1,:),F_perm(1,:),F_resd(1,:),A_used(pi(i_1),1),S1] = spice_unit(y_feed,F_feed,P_feed,P_perm,A(1));
    R_He(1) = F_perm(1,3) / (F_feed * y_feed(3));
    P_He(1) = y_perm(1,3);
    % if abs( R_He(pi(i),1) - 0.93) <= 0.001
    %     break
    % end

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
                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\TOTFLOW\MIXED').value =  input1;  

                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\FLOW\MIXED\HELIU-02').value = y_resd(NStage,3); 
                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\FLOW\MIXED\NITRO-01').Value = y_resd(NStage,2); 
                Aspen.Application.Tree.FindNode('\Data\Streams\FEED1\Input\FLOW\MIXED\METHA-01').Value = y_resd(NStage,1);
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\TOTFLOW\MIXED').Value =  input2;  
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\FLOW\MIXED\HELIU-02').Value  = y_perm(NStage,3);
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\FLOW\MIXED\NITRO-01').Value  = y_perm(NStage,2);
                Aspen.Application.Tree.FindNode('\Data\Streams\F2-M\Input\FLOW\MIXED\METHA-01').Value  = y_perm(NStage,1);
                % pause(1);
                Run2(Aspen.Engine);

                % pause(1);
                %% read duty
                Total_COM_DUTY(1) = Aspen.Application.Tree.FindNode('\Data\Blocks\N2-COM1\Output\BRAKE_POWER').Value; %Duty of N2-compressor 
                Total_COM_DUTY(2) = Aspen.Application.Tree.FindNode('\Data\Blocks\N-COM2\Output\BRAKE_POWER').Value;
                Total_COM_DUTY(3) = Aspen.Application.Tree.FindNode('\Data\Blocks\N2-COM3\Output\BRAKE_POWER').Value;
                Total_COM_DUTY(4) = Aspen.Application.Tree.FindNode('\Data\Blocks\F2-M-COM\Output\BRAKE_POWER').Value;
                Total_col_DUTY(1) = Aspen.Application.Tree.FindNode('\Data\Blocks\N2-COL1\Output\QNET').value;        %Duty of N2-Cooler
                Total_col_DUTY(2) = Aspen.Application.Tree.FindNode('\Data\Blocks\N2-COL2\Output\QNET').value;
                Total_col_DUTY(3) = Aspen.Application.Tree.FindNode('\Data\Blocks\N2-COL3\Output\QNET').Value;

                Total_col_DUTY(4) = Aspen.Application.Tree.FindNode('\Data\Blocks\DT1\Output\COND_DUTY').value;         %Duty of N2-column
                Total_reb_DUTY(1) = Aspen.Application.Tree.FindNode('\Data\Blocks\DT1\Output\REB_DUTY').value;
                Total_col_DUTY(5) = Aspen.Application.Tree.FindNode('\Data\Blocks\COL-FLA1\Output\QNET').value;
                Oput_HE_R         = (Aspen.Application.Tree.FindNode('\Data\Streams\HE-PRO\Output\MOLEFLOW\MIXED\HELIU-02').value /(F_feed*y_feed(3)));
                Oput_HE_P         = Aspen.Application.Tree.FindNode('\Data\Streams\HE-PRO\Output\MOLEFRAC\MIXED\HELIU-02').value;

                Total_COM_DUTY_sum = sum(Total_COM_DUTY);
                Total_col_DUTY_sum = sum(Total_col_DUTY);
                Total_reb_DUTY_sum = sum(Total_reb_DUTY); 
                database(tick,:)  = [pi(i_1),A,R_He,P_He,Total_COM_DUTY_sum,Total_col_DUTY_sum,Total_reb_DUTY_sum,Oput_HE_R,Oput_HE_P];
               tick =  tick + 1;
            end
        % end
    % end
  end 
       
      
        
        
        
        headers_pres =  '上游压力' ;
        headers_A = arrayfun(@(x) sprintf('第%d级膜面积', x), 1:NStage, 'UniformOutput', false);
        % Step 2: 生成 R_He 的表头
        headers_R = arrayfun(@(x) sprintf('He回收率%d',x), 1:NStage, 'UniformOutput', false);
        % Step 3: 生成 P_He 的表头
        headers_P = arrayfun(@(x) sprintf('He纯度%d',x), 1:NStage, 'UniformOutput', false);
        % Step 4: 生成 duty 的表头
        headers_eduty = arrayfun(@(x) sprintf('总电耗%d',x), 1, 'UniformOutput', false);
        headers_cduty = arrayfun(@(x) sprintf('总冷耗%d',x), 1, 'UniformOutput', false);
        headers_hduty = arrayfun(@(x) sprintf('总热耗%d',x), 1, 'UniformOutput', false);
       % Step 4: 生成 P-R 的表头
        headers_oputHE1_R = arrayfun(@(x) sprintf('塔出口HE回收率%d',x), 1, 'UniformOutput', false);
        headers_oputHE1_P = arrayfun(@(x) sprintf('塔出口HE纯度%d',x), 1, 'UniformOutput', false);
        % Step last: 合并成完整表头
        headers = [headers_pres,headers_A, headers_R, headers_P, headers_eduty, headers_cduty, headers_hduty,headers_oputHE1_R,headers_oputHE1_P];
        writecell(headers, filename, 'Sheet',NStage, 'Range','A1');
        database = database(1:tick-1,:);
        writematrix(database, filename,'Sheet',NStage, 'Range','A2');

   
  

    
