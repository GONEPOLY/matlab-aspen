
%     Area = [500 ,1000];
%     while i<=length(Area)
    clear  
    clc
    Index = 4;
    
    
    %%parameter set
     Ncell = 10000;
%      ReFlow           = zeros(1, Ncell) ;
%      ReFlow_Frac      = zeros(1, Ncell); 
     ReFlow           = 30;
     ReFlow_Frac      = 0.9;
     ReFlow_Ratio_Interval     = 0.1:0.1:0.9;  
     
     A2               = 3000;
     A1               = A2 ;
       
     F_feed           = 573.1397; 
     y_feed           = 0.904;
     t_feed           = 54.5;
     i                = 1;
     hh               = 1;
 for k = 1 : 1 : length(ReFlow_Ratio_Interval)
    
         
    ReFlow_Ratio = ReFlow_Ratio_Interval(k);
    
    for i = 1:1:1000
        
  
         
     
    N = 2000;
    G1 = 120; 
    S1 = 90;
%     Membrane_Parameter1 =zeros(8,1);
    P_Memfeed_Origin = 800;
     %% Membrane first
    F_feed1 =  ReFlow + F_feed ; 
   
    y_feed1 = (y_feed*F_feed + ReFlow *ReFlow_Frac)/F_feed1 ;
    Membrane_Parameter1 = Call_MembraneSolution(G1, S1, A1, F_feed1,P_Memfeed_Origin , y_feed1, N, t_feed);
  
   
    %% Output value of membrane1
    t_feed      = Membrane_Parameter1(6);
    P_resd_out1 = Membrane_Parameter1(5);
    f_resd_1    = Membrane_Parameter1(1);
    FracP_py1   = Membrane_Parameter1(3);
    FracP_pa1   = Membrane_Parameter1(4);
    FracR_py1   = Membrane_Parameter1(6);
    FracR_pa1   = Membrane_Parameter1(7);
    f_perm_Sum1 = Membrane_Parameter1(2);
    Outputdata1 = [P_resd_out1,f_perm_Sum1,FracP_py1,FracP_pa1,f_resd_1,FracR_py1,FracR_pa1];
    
   
    
    G2            = 120;
    N             = 2000; 
    S2            = 90;
    F_feed2       = f_resd_1;
    y_feed2       = FracR_py1;
    P_Memfeed_Sec = 800;
    Membrane_Parameter2 = Call_MembraneSolution(G2 ,S2 ,A2 ,F_feed2 ,P_Memfeed_Sec ,y_feed2 ,N ,t_feed );
    P_resd_out2   = Membrane_Parameter2(5);
    f_resd_2      = Membrane_Parameter2(1);
    FracP_py2     = Membrane_Parameter2(3);
    FracP_pa2     = Membrane_Parameter2(4);
    FracR_py2     = Membrane_Parameter2(6);
    FracR_pa2     = Membrane_Parameter2(7);
    f_perm_Sum2   = Membrane_Parameter2(2);
   
    Outputdata2   = [P_resd_out2,f_perm_Sum2,FracP_py2,FracP_pa2,f_resd_2,FracR_py2,FracR_pa2];
   
    %% ReFlow
    F1            =  ReFlow_Frac;
    R1            =  ReFlow;
    ReFlow        = f_perm_Sum2 * ReFlow_Ratio ;
    ReFlow_Frac   = FracP_py2 ;
    Output_Flow   = f_perm_Sum1 +  f_resd_2 +  (f_perm_Sum2 - ReFlow);
    
    
      hh = abs(  ( ReFlow_Frac * ReFlow - R1 * F1 ) / ( R1 * F1 )  );
        if hh <  0.0000001
            break
        end
    
   

    end
      %% output to excel
    Recovery         = 100*(f_perm_Sum1*FracP_py1+ f_perm_Sum2*FracP_py2) / (F_feed1*y_feed1);
    Purity           = 100*(f_perm_Sum1*FracP_py1+ f_perm_Sum2*FracP_py2) / (f_perm_Sum1+ f_perm_Sum2);
    Outputdata_RY    = [Purity,Recovery,Output_Flow];
    Outputdata       = [A1,A2];   
   
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\MultiStage_Double_ReFlow.xlsx',Outputdata     ,'sheet1',['C',num2str(Index),':D',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\MultiStage_Double_ReFlow.xlsx',Outputdata1    ,'sheet1',['E',num2str(Index),':K',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\MultiStage_Double_ReFlow.xlsx',Outputdata2    ,'sheet1',['L',num2str(Index),':R',num2str(Index)]);
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\MultiStage_Double_ReFlow.xlsx',Outputdata_RY  ,'sheet1',['S',num2str(Index),':U',num2str(Index)]);
   
    
 
 
 
    Index         = Index + 1;
    
end
    