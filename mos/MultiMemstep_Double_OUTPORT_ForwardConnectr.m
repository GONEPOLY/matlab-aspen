    clear
    clc

     
      Index    = 125;
%       t_feed   = 54.5;  
%       Recovery = 0; 
%       Purity   = 0;
      Area     = 6000;
      adi      = 0.1;
     
%   
%       Parameter_Project_Hybird = zeros(1,11);  
   for  A1 =  1000:100:4000
%          A1  =  3000;
         A2  =  A1/1.25;
            
       for S1 = 70:5:80
            for S2 =  30:5:80
   
   
    N  = 2000;
    G1 = 120; 
%     S1 = 30;
%     Membrane_Parameter1 =zeros(8,1);
    P_Memfeed_Origin = 800;
     %% Membrane first
    F_feed1 = 573.1397;
    y_feed1 = 0.904;
    
    Membrane_Parameter1 = Call_MembraneSolution(G1, S1, A1, F_feed1,P_Memfeed_Origin , y_feed1, N);
    %% Output value of membrane1
    t_feed = Membrane_Parameter1(6);
    P_resd_out1 = Membrane_Parameter1(5);
    f_resd_1    = Membrane_Parameter1(1);
    FracP_py1   = Membrane_Parameter1(3);
    FracP_pa1   = Membrane_Parameter1(4);
    FracR_py1   = Membrane_Parameter1(6);
    FracR_pa1   = Membrane_Parameter1(7);
    f_perm_Sum1 = Membrane_Parameter1(2);
    Outputdata1 = [P_resd_out1,f_perm_Sum1,FracP_py1,FracP_pa1,f_resd_1,FracR_py1,FracR_pa1];
   
    %% Increase the pressure by hysys
%     [T_out, P_out, F_out, Frac1, Frac2]=Conpressure(t_feed1, P_resd_out1, f_resd_1 , FracR_py1, FracR_pa1); %% Increase the pressure
    
    %% Membrane second [f_resd1 , f_perm_sum1, FracP_py1, FracP_pa1, P_resdN , FracR_py1 , FracR_pa1 , t_feed]
    
    G2 = 120;
    
    N  = 2000; 
%     S2 = 30;
    F_feed2 = f_resd_1;
    y_feed2 = FracR_py1;
    P_Memfeed_Sec = 800;
    Membrane_Parameter2 = Call_MembraneSolution(G2 ,S2 ,A2 ,F_feed2 ,P_Memfeed_Sec ,y_feed2 ,N );
    P_resd_out2   = Membrane_Parameter2(5);
    f_resd_2      = Membrane_Parameter2(1);
    FracP_py2     = Membrane_Parameter2(3);
    FracP_pa2     = Membrane_Parameter2(4);
    FracR_py2     = Membrane_Parameter2(6);
    FracR_pa2     = Membrane_Parameter2(7);
    f_perm_Sum2   = Membrane_Parameter2(2);
    f_resd_second = Membrane_Parameter2(3);
    Outputdata2   = [P_resd_out2,f_perm_Sum2,FracP_py2,FracP_pa2,f_resd_2,FracR_py2,FracR_pa2];
    
    %% forward_connect parameter input
    P_resd_connect     =  P_resd_out2;
    f_resd_py_connect  =  FracR_py2*f_resd_2;
    f_resd_pa_connect  =  FracR_pa2*f_resd_2;
    f_perm_pa_connect  =  (f_perm_Sum2*FracP_pa2  + f_perm_Sum1*FracP_pa1);
    f_perm_py_connect  =  (f_perm_Sum2*FracP_py2  + f_perm_Sum1*FracP_py1);
    
    Parameter_Project_Hybird  =  ForwordConnect(P_resd_connect ,P_resd_connect , f_resd_py_connect , f_resd_pa_connect ,f_perm_pa_connect,f_perm_py_connect);
    Draw_Dist                 =  Parameter_Project_Hybird(1);
    C101                      =  Parameter_Project_Hybird(2);
    K101A                     =  Parameter_Project_Hybird(3);
    K101B                     =  Parameter_Project_Hybird(4);
    K102                      =  Parameter_Project_Hybird(5);
    E101                      =  Parameter_Project_Hybird(6);
    E102                      =  Parameter_Project_Hybird(7);
    E103                      =  Parameter_Project_Hybird(8);
    E104                      =  Parameter_Project_Hybird(9);
    E105                      =  Parameter_Project_Hybird(10); 
    E106                      =  Parameter_Project_Hybird(11);
    
    Outputdata_Hybrid         = [K101A,K101B,K102,C101,E101,E102,E103,E104,E105,E106];
    
    
    Recovery         = 100*(f_perm_Sum1*FracP_py1+ f_perm_Sum2*FracP_py2) / (F_feed1*y_feed1);
    Purity           = 100*(f_perm_Sum1*FracP_py1+ f_perm_Sum2*FracP_py2) / (f_perm_Sum1+ f_perm_Sum2);
    RE1              = 100*(f_perm_Sum1*FracP_py1) / (F_feed1*y_feed1);
    RE2              = 100*(f_perm_Sum2*FracP_py2) / (F_feed1*y_feed1); 
    Outputdata_RY    = [Purity,Recovery];
    Outputdata       = [A1,A2];   
    Outputdata_R1R2  = [RE1,RE2];
    
    
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',[G1,G2]   ,'sheet3',['A' ,num2str(Index),':B' ,num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',[A1,A2]   ,'sheet3',['C' ,num2str(Index),':D' ,num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',[S1,S2]   ,'sheet3',['E' ,num2str(Index),':F' ,num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',Draw_Dist ,'sheet3',['G' ,num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',K101A     ,'sheet3',['Y' ,num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',K101B     ,'sheet3',['AB',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',K102      ,'sheet3',['AE',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',C101      ,'sheet3',['AH',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',E101      ,'sheet3',['AK',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',E102      ,'sheet3',['AM',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',E103      ,'sheet3',['AO',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',E104      ,'sheet3',['AQ',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',E105      ,'sheet3',['AS',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx',E106      ,'sheet3',['AU',num2str(Index)]);
%     xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata1    ,'sheet2',['F',num2str(Index),':L',num2str(Index)]);
%     xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata2    ,'sheet2',['M',num2str(Index),':S',num2str(Index)]);
%     xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata_RY  ,'sheet2',['T',num2str(Index),':U',num2str(Index)]);
%     xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata_R1R2,'sheet2',['W',num2str(Index),':X',num2str(Index)]);
    Index = Index + 1; 
    
            end
       end
   end
