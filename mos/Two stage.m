
%     Area = [500 ,1000];
%     while i<=length(Area)
    clear  
    t_feed = 54.5;
    A1 = 1000;
    A2 = A1;
    y_feed1 = 0.904;
    N = 200;
    G1 = 80;
    G2 = G1;
    S1 = 30;
    P_Memfeed0_one = 800;
     %% Membrane first
    f_first = 573.1397;
    [f_resd1 , f_perm_sum1, FracP_py1, FracP_pa1, P_resdN1 , FracR_py1 , FracR_pa1 , t_feed1] = Call_MembraneSolution(G1, S1, A1, f_first, P_Memfeed0_one, y_feed1, N, t_feed);
    Membrane_Parameter1 = [f_resd1 , f_perm_sum1, FracP_py1, FracP_pa1, P_resdN1 , FracR_py1 , FracR_pa1 , t_feed1] ;
    
    %% Output value of membrane1
%     t_feed = Membrane_Parameter1(6);
    
    P_resd_out1 = Membrane_Parameter1(5);
    f_resd_1 = Membrane_Parameter1(1);
    FracP_py1 = Membrane_Parameter1(3);
    FracP_pa1 = Membrane_Parameter1(4);
    FracR_py1 = Membrane_Parameter1(6);
    FracR_pa1 = Membrane_Parameter1(7);
    f_perm_Sum1 = Membrane_Parameter1(2);
   
    %% Increase the pressure by hysys
    [T_out, P_out, F_out, Frac1, Frac2]=Conpressure(t_feed1, P_resd_out1, f_resd_1 , FracR_py1, FracR_pa1); %% Increase the pressure
    
    %% Membrane second [f_resd1 , f_perm_sum1, FracP_py1, FracP_pa1, P_resdN , FracR_py1 , FracR_pa1 , t_feed]
    [f_resd2 , f_perm_sum2 , FracP_py2, FracP_pa2, P_resdN2 , FracR_py2 , FracR_pa2 , t_feed2] = Call_MembraneSolution(G2 ,S1 ,A2 ,F_out ,P_out ,Frac1 ,N ,T_out );
    Membrane_Parameter2 =  [f_resd2 , f_perm_sum2 , P_resdN2 , FracR_py2 , FracR_pa2 , t_feed2] ;
    
    f_resd_second = Membrane_Parameter2(3);
    f_perm_Sum2 = f_resd_first-f_resd_second;
    P_resd_out2 = P_resdN2;
    
    %% output to excel
    Outputdata=[P_resd_out1, f_perm_Sum1 , FracP_py1, FracP_pa1, F_out, FracR_py1, FracR_pa1, P_resd_out2, f_perm_Sum2 , FracP_py2, FracP_pa2, P_resd_out2, f_resd2, FracR_py2, FracR_pa2];
    
    xlRange = ['D3:Q3','D4:Q4','D5:Q5','D6:Q6','D7:Q7','D8:Q8'];
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two stage Mem',Outputdata,'sheet1','D3:Q3');
%     i=i+1;
%     end 
   
