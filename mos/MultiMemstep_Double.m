    clear
    clc

%       Mem_Selectivity  = [8, 11, 15, 18];
%       Mem_Permeability = [12.99, 22.98, 31.98, 43.97];
      Index    = 306;
      t_feed   = 54.5;  
      Recovery = 0; 
      Purity   = 0;
      Area     = 6000;
      adi      = 0.1;
   for  A2  = 3000:100:10000
  
         
      
        
            
       A1 = 1.25*A2;
  %% S/GPU = 80/12
   
   
    N  = 2000;
    G1 = 120; 
    S1 = 90;
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
    S2 = 90;
    F_feed2 = f_resd_1;
    y_feed2 = FracR_py1;
    P_Memfeed_Sec = 800;
    Membrane_Parameter2 = Call_MembraneSolution(G2 ,S2 ,A2 ,F_feed2 ,P_Memfeed_Sec ,y_feed2 ,N );
    P_resd_out2 = Membrane_Parameter2(5);
    f_resd_2    = Membrane_Parameter2(1);
    FracP_py2   = Membrane_Parameter2(3);
    FracP_pa2   = Membrane_Parameter2(4);
    FracR_py2   = Membrane_Parameter2(6);
    FracR_pa2   = Membrane_Parameter2(7);
    f_perm_Sum2 = Membrane_Parameter2(2);
    f_resd_second = Membrane_Parameter2(3);
    Outputdata2 = [P_resd_out2,f_perm_Sum2,FracP_py2,FracP_pa2,f_resd_2,FracR_py2,FracR_pa2];
    

    G3 = 44;
    
    N  = 2000; 
    S3 = 18;
    F_feed3 = f_perm_Sum2;
    y_feed3 = FracP_py1;
    P_Memfeed_third = 800;
    Membrane_Parameter3 = Call_MembraneSolution(G3 ,S3 ,A3 ,F_feed3 ,P_Memfeed_third ,y_feed3 ,N );
    P_resd_out3 = Membrane_Parameter3(5);
    f_resd_3    = Membrane_Parameter3(1);
    FracP_py3   = Membrane_Parameter3(3);
    FracP_pa3   = Membrane_Parameter3(4);
    FracR_py3   = Membrane_Parameter3(6);
    FracR_pa3   = Membrane_Parameter3(7);
    f_perm_Sum3 = Membrane_Parameter3(2);
    f_resd_third = Membrane_Parameter2(3);
    Outputdata3 = [P_resd_out3,f_perm_Sum3,FracP_py3,FracP_pa3,f_resd_3,FracR_py3,FracR_pa3];
    
    
    
    Recovery    = 100*(f_perm_Sum1*FracP_py1+ f_perm_Sum2*FracP_py2) / (F_feed1*y_feed1);
    Purity      = 100*(f_perm_Sum1*FracP_py1+ f_perm_Sum2*FracP_py2) / (f_perm_Sum1+ f_perm_Sum2);
    RE1         = 100*(f_perm_Sum1*FracP_py1) / (F_feed1*y_feed1);
    RE2         = 100*(f_perm_Sum2*FracP_py2) / (F_feed1*y_feed1); 
%     Outputdata_RY    = [Purity,Recovery];
%     Outputdata       = [A1,A2];   
    Outputdata_R1R2  = [RE1,RE2]; 
    if Recovery >= 98.7044664
              break
    end
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',[G1,G2]        ,'sheet2',['A',num2str(Index),':B',num2str(Index)]); 
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',[A1,A2]        ,'sheet2',['C',num2str(Index),':D',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',[S1,S2]        ,'sheet2',['E',num2str(Index),':F',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata1    ,'sheet2',['G',num2str(Index),':M',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata2    ,'sheet2',['N',num2str(Index),':T',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata_RY  ,'sheet2',['U',num2str(Index),':V',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata_R1R2,'sheet2',['X',num2str(Index),':Y',num2str(Index)]);
    Index = Index + 1; 
    
 end 



