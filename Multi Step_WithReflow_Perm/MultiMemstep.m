    clear
    clc
    Area = 10000;
    
%     GPUValue = [30, 40, 50, 60, 70, 80, 90, 100, 110, 120];
    num_sheet = 1 ;
    Select = 90;
    
      G1 = 120;
      G2 = 120;
      Index = 68;
        
%       A1 = Area+400;
%       A2 = Area-400;
%         
%     for i = 1:length(Select)
     for j = 1:20  
%         G1 = GPUValue(i);
     
      A1 = 6000 - j*60; 
      A2 = 4000 - j*40; 
      t_feed = 54.5;
      y_feed1 = 0.904;
      N = 3000;
   
   
      S_1 = Select;
      S_2 = Select;
      P_Memfeed0_one = 800;
    
    %% Membrane first
    f_first = 573.1397;
    [f_resd1 , f_perm_sum1, FracP_py1, FracP_pa1, P_resdN1 , FracR_py1 , FracR_pa1 , t_feed1] = Call_MembraneSolution(G1, S_1, A1, f_first, P_Memfeed0_one, y_feed1, N, t_feed);
    Membrane_Parameter1 = [f_resd1 , f_perm_sum1, FracP_py1, FracP_pa1, P_resdN1 , FracR_py1 , FracR_pa1 , t_feed1] ;
    
    %% Output value of membrane1

    
    P_resd_out1 = Membrane_Parameter1(5);
    f_resd_1    = Membrane_Parameter1(1);
    FracP_py1   = Membrane_Parameter1(3);
    FracP_pa1   = Membrane_Parameter1(4);
    FracR_py1   = Membrane_Parameter1(6);
    FracR_pa1   = Membrane_Parameter1(7);
    f_perm_Sum1 = Membrane_Parameter1(2);
   
    %% Increase the pressure by hysys
%     [T_out, P_out, F_out, Frac1, Frac2] = Conpressure(t_feed1, P_resd_out1, f_resd_1 , FracR_py1, FracR_pa1); %% Increase the pressure
     T_out = t_feed1;
     P_out = 800;
     F_out = f_resd_1;
     Frac1 = FracR_py1;
     Frac2 = FracR_pa1;
     
    %% Membrane second [f_resd1 , f_perm_sum1, FracP_py1, FracP_pa1, P_resdN , FracR_py1 , FracR_pa1 , t_feed]
    [f_resd2 , f_perm_sum2 , FracP_py2, FracP_pa2, P_resdN2 , FracR_py2 , FracR_pa2 , t_feed2] = Call_MembraneSolution(G2 ,S_2 ,A2 ,F_out ,P_out ,Frac1 ,N ,T_out );
    Membrane_Parameter2 =  [f_resd2 , f_perm_sum2 , P_resdN2 , FracR_py2 , FracR_pa2 , t_feed2] ;
    
    f_resd_second = Membrane_Parameter2(3);
  
    P_resd_out2 = P_resdN2;
    
    %% output to excel
    Outputdata=[P_resd_out1, f_perm_Sum1 , FracP_py1, FracP_pa1, F_out, FracR_py1, FracR_pa1, P_resd_out2, f_perm_sum2 , FracP_py2, FracP_pa2, f_resd2, FracR_py2, FracR_pa2];
    
 
      Index = Index + 1; 
      SHEET = ['sheet',num2str(num_sheet)];
      xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two stage Mem', Outputdata, SHEET, ['F',num2str(Index),':S',num2str(Index)]);
%      sendmail('2485796062@qq.com', 'COMPLETE!', 'COMPLETE!');
      end 



