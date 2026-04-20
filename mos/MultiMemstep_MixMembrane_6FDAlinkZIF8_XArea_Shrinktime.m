   clc
     clear

   

      Nstep              =  2;
      Mem_Index          =  Nstep;
      Mem_I              =  Nstep;
      GPU_Mem            =  zeros(1,Mem_Index);
      S_Mem              =  zeros(1,Mem_Index);
      P_resd_out         =  zeros(1,Mem_Index);
      Membrane_Parameter =  zeros(Mem_Index,8);
      f_resd             =  zeros(1,Mem_Index);
      FracP_py           =  zeros(1,Mem_Index);
      FracP_pa           =  zeros(1,Mem_Index);
      FracR_py           =  zeros(1,Mem_Index);
      FracR_pa           =  zeros(1,Mem_Index);
      f_perm             =  zeros(1,Mem_Index);
      F_feed             =  zeros(1,Mem_Index);
      y_feed             =  zeros(1,Mem_Index);
      Area               =  zeros(1,Mem_Index);
      P_Memfeed          =  zeros(1,Mem_Index);
      f_perm_downstream_py = zeros(1,Mem_Index);
      f_perm_downstream_pa = zeros(1,Mem_Index);
      Outputdata         =  zeros(Mem_Index,7);     
      Area(:)            =  0;
      upper_limits       = [4500, 4500];
      a                  = zeros(1,Nstep);
      Outputdata_Area    = [];
      Work_space1         = zeros(3600,27);
      Work_space2         = zeros(3600,42);
      write_space1        = 1;
      write_space2        = 1;
      Area_sum   =  6000;

   %%   Original value
      N                = 2000; 
      P_Memfeed(1)     = 800;
      F_feed(1)        = 573.1397;
      y_feed(1)        = 0.90;
      P_p              = 90;
      P_s              = 44;

      P_MMM = P_p*(P_s+2*P_p-2*Load_V*(P_p-P_s))/(P_s+2*P_p+Load_V*(P_p-P_s));
      % GPU_Mem(:)       = [44; 90]; 
      % S_Mem(:)         = [23; 50];  
      GPU_Mem(:)       = [44; 44]; 
      S_Mem(:)         = [23; 23];  

  for A1               = 200:200:6000 
      for A2               = 200:200:6000
      
            for Mem_I  = 1 :Nstep 
     
                  if Mem_I >=2
                      y_feed(Mem_I)    = FracR_py(Mem_I-1);
                      F_feed(Mem_I)    = f_resd(Mem_I-1);  
                      P_Memfeed(Mem_I) = P_Memfeed(1);
                  end 
                  
    Area(:)= [A1,A2];
    %% Solution value of membrane
    Membrane_Parameter(Mem_I,:) = Call_MembraneSolution(GPU_Mem(Mem_I), S_Mem(Mem_I), Area(Mem_I), F_feed(Mem_I), P_Memfeed(Mem_I) , y_feed(Mem_I), N);
    
    %% acquire parameter from result function
    f_resd(Mem_I)     = Membrane_Parameter(Mem_I,1);
    f_perm(Mem_I)     = Membrane_Parameter(Mem_I,2);
    FracP_py(Mem_I)   = Membrane_Parameter(Mem_I,3);
    FracP_pa(Mem_I)   = Membrane_Parameter(Mem_I,4);
    P_resd_out(Mem_I) = Membrane_Parameter(Mem_I,5);
    FracR_py(Mem_I)   = Membrane_Parameter(Mem_I,6);
    FracR_pa(Mem_I)   = Membrane_Parameter(Mem_I,7);     
    t_feed            = Membrane_Parameter(Mem_I,8);
    
    %% output result data
    Outputdata(Mem_I,:) = [P_resd_out(Mem_I), f_perm(Mem_I),  FracP_py(Mem_I),  FracP_pa(Mem_I),  f_resd(Mem_I),  FracR_py(Mem_I),  FracR_pa(Mem_I)];
    f_perm_downstream_py(Mem_I) =  FracP_py(Mem_I) * f_perm(Mem_I) ;
    f_perm_downstream_pa(Mem_I) =  FracP_pa(Mem_I) * f_perm(Mem_I) ;
  
           end
    
     %% Price of Mem and Comform

     Price_6FDA  = 2344;
     Price_ZIF8 = 6000;
     Cost_Mem  = A1*Price_6FDA +  A2*Price_6FDA;

     f_perm_downstream_sum           =  sum(f_perm);
     f_perm_downstream_py_sum        =  sum(f_perm_downstream_py);
     f_perm_downstream_pa_sum        =  sum(f_perm_downstream_pa);
     f_perm_downstream_Purity_py     =  100 * f_perm_downstream_py_sum/f_perm_downstream_sum;
     f_perm_downstream_Recovery_py   =  100 * f_perm_downstream_py_sum/(y_feed(1)*F_feed(1));
    
    %% ForwardConnect_Rebuild parameter Integrate

    P_resd_connect     =  P_resd_out(2);
    P_perm_connect     =  10;
    f_resd_py_connect  =  FracR_py(2)*f_resd(2);
    f_resd_pa_connect  =  FracR_pa(2)*f_resd(2);
    f_perm_py_connect  =  f_perm_downstream_py_sum;
    f_perm_pa_connect  =  f_perm_downstream_pa_sum;
   
    %%  Send result of Membrane Module to HYSYS

    Parameter_Project_Hybird  =  ForwordConnect_Rebuild(P_perm_connect, f_perm_py_connect, f_perm_pa_connect  , P_resd_connect,f_resd_py_connect,f_resd_pa_connect);
    Draw_Dist                 =  Parameter_Project_Hybird(1);
    Draw_Dist_mole            =  Parameter_Project_Hybird(2);
    C101                      =  Parameter_Project_Hybird(3);
    K101A                     =  Parameter_Project_Hybird(4);
    K101B                     =  Parameter_Project_Hybird(5);
    K102                      =  Parameter_Project_Hybird(6);
    E101                      =  Parameter_Project_Hybird(7);
    E102                      =  Parameter_Project_Hybird(8);
    E103                      =  Parameter_Project_Hybird(9);
    E104                      =  Parameter_Project_Hybird(10);
    E105                      =  Parameter_Project_Hybird(11); 
    E106                      =  Parameter_Project_Hybird(12);

    Data_Hybrid         =  [K101A,K101B,K102,C101,E101,E102,E103,E104,E105,E106];
    Outputdata_Area     =  [A1,A2];  
    Purity1             =  FracP_py(1);
    Purity2             =  FracP_py(2);
    Purity_py_sum       =  f_perm_downstream_Purity_py;
    Purity_output       =  [Purity1,Purity2,Purity_py_sum];
    Recovery            =  f_perm_downstream_Recovery_py;
    
    %% Cost calculate

    Total_condenser     =  (E101+E103+E105+E106)*0.025*8000/10000;
    Total_Vacum         =  (0.22*C101/0.9)*8000/10000;
    Total_Heater        =  E102*8000/10000;
    Total_Electic_Price =  (0.22*(K101A+K101B+K102)/0.9)*8000/10000;
    Total_Electic_Duty  =  (K101A+K101B+K102)/0.9;
    EXchanger_Area      =  ((E101+E102+E103+E104+E105+E106)*3600)/(1703.4786*10);
    Total_EXchanger     =  (EXchanger_Area^0.65)*1448.3*(2.29+3.75)/(35*10000);
    AOC                 =  Total_Electic_Price + Total_Heater + Total_condenser  + Total_Vacum;
    TCC                 =  (Total_EXchanger + Cost_Mem)/(3*1000);
    TAC                 =  (TCC + AOC ); 
    Cost_Integrate      =  [TAC,TCC,AOC,Cost_Mem,Total_EXchanger,EXchanger_Area,Total_Electic_Price,Total_Electic_Duty,Total_Heater,Total_Vacum,Total_condenser];  %% 11 Point

    %% Matrix with data set

    Work_space1(write_space1,:)  = [GPU_Mem,Outputdata_Area,S_Mem,Membrane_Parameter(1,:),Membrane_Parameter(2,:),f_perm_downstream_sum,Recovery,Purity_output];
    %%  19 22 25 28 31 33 35 37 39 41 
    Outputdata_Hybrid_reset      = [K101A,K101A/0.9,0.22*K101A/0.9,K101B,K101B/0.9,0.22*K101B/0.9,K102,K102/0.9,0.22*K102/0.9,C101,C101/0.9,0.22*C101/0.9,E101,E101*0.025/3600,E102,E102*0.41/3600,E103,E103*0.025/3600,E104,E104*0.025/3600,E105,E105*0.025/3600,E106,E106*0.025/3600];
    Work_space2(write_space2,:)  = [GPU_Mem,Outputdata_Area,S_Mem,Draw_Dist, Cost_Integrate,Outputdata_Hybrid_reset]; %% 7-11-24 = 42
    write_space1                 = write_space1 + 1;
    write_space2                 = write_space2 + 1;

     end
  end

    %%  Excel fill with result data

    interval             = 900;
    Index_mem            = 5 ;
    Index_couple         = 6;

    path1 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 2.xlsx';
    sheet_value1 = 6;
    writematrix(Work_space1, path1   ,'sheet',sheet_value1,'Range',['A' ,num2str(Index_mem),':Y'  ,num2str(Index_mem+ interval)]);

    path2 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx';
    sheet_value2 = 11;
    writematrix(Work_space2, path2   ,'sheet',sheet_value2,'Range',['A' ,num2str(Index_couple )  ,':AP' ,num2str(Index_couple  + interval)]);
    

   
  
    