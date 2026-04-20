clc
clear
      Nstep              =  2;
      Mem_Index          =  Nstep;
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
      Work_space1        = zeros(900,27);
      Work_space2        = zeros(900,42);
      write_space1       = 1;
      write_space2       = 1;
  
      Index_Mem          = 3;
      interval           = 900;
      %% Read Input data
      path = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 2.xlsx';
      Sheet_value2 =  ['Sheet' ,num2str(5 )];
      Read_Data = readmatrix( path   ,'Sheet',Sheet_value2,'Range',  ['A' ,num2str(Index_Mem )  ,':Y' ,num2str(Index_Mem  + interval-1)]);
      
   
  
    

      for Read_Index =1:900
      
      P_resd_connect     =   Read_Data (Read_Index, 14);
      P_perm_connect     =   10;
      f_perm_py_connect  =   Read_Data(Read_Index,21) * Read_Data(Read_Index,25)/100;
      f_perm_pa_connect  =   Read_Data(Read_Index,21) * (100-Read_Data(Read_Index,25))/100;
      f_resd_py_connect  =   Read_Data(Read_Index,18) * Read_Data(Read_Index,19);
      f_resd_pa_connect  =   Read_Data(Read_Index,18) * Read_Data(Read_Index,20);
      Input_Judgment_Purity  =  f_perm_py_connect / (f_perm_pa_connect + f_perm_py_connect);


      if Input_Judgment_Purity > 0.996
      Parameter_Project_Hybird  =  ForwordConnect_Rebuild(P_perm_connect, f_perm_py_connect, f_perm_pa_connect  , P_resd_connect,f_resd_py_connect,f_resd_pa_connect);
     
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

    
    %% Cost calculate
    GPU_Mem     = [Read_Data(Read_Index,1),Read_Data(Read_Index,2)];
    A1          = Read_Data(Read_Index,3);
    A2          = Read_Data(Read_Index,4);
    Outputdata_Area =   [A1,A2];
    S_Mem       = [Read_Data(Read_Index,5),Read_Data(Read_Index,6)];
    Price_6FDA  = 2344;
    Price_ZIF8  = 6000;
    if GPU_Mem(1) ==44
     Price1  = Price_6FDA;
    else
        Price1  = Price_ZIF8;
    end
     if GPU_Mem(2) ==44
     Price2  = Price_6FDA;
    else
        Price2  = Price_ZIF8;
    end
    Cost_Mem  = (A1*Price1 +  A2*Price2)/10000;

    Total_condenser     =  (E101+E103+E105+E106)*0.025*8000/(3600*10000);
    Total_Vacum         =  (0.22*C101/0.9)*8000/10000;
    Total_Heater        =  0.41*E102*8000/(3600*10000);
    Total_Electic_Price =  (0.7*(K101A+K101B+K102)/0.9)*8000/10000;
    Total_Electic_Duty  =  (K101A+K101B+K102)/0.9;
    EXchanger_Area      =  (E101+E102+E103+E104+E105+E106)/(3600*1703.4786*10);
    Total_EXchanger     =  (EXchanger_Area^0.65)*1448.3*(2.29+3.75)/(35*10000);
    AOC                 =  Total_Electic_Price + Total_Heater + Total_condenser  + Total_Vacum;
    TCC                 =  (Total_EXchanger + Cost_Mem);
    TAC                 =  (TCC + AOC ); 
    Cost_Integrate      =  [TAC,TCC,AOC,Cost_Mem,Total_EXchanger,EXchanger_Area,Total_Electic_Price,Total_Electic_Duty,Total_Heater,Total_Vacum,Total_condenser];  %% 11 Point

    %%  19 22 25 28 31 33 35 37 39 41 
    Outputdata_Hybrid_reset      = [K101A,K101A/0.9,0.22*K101A/0.9,K101B,K101B/0.9,0.22*K101B/0.9,K102,K102/0.9,0.22*K102/0.9,C101,C101/0.9,0.22*C101/0.9,E101,E101*0.025/3600,E102,E102*0.41/3600,E103,E103*0.025/3600,E104,E104*0.025/3600,E105,E105*0.025/3600,E106,E106*0.025/3600];
    Work_space2(write_space2,:)  = [GPU_Mem,Outputdata_Area,S_Mem,Draw_Dist_mole, Cost_Integrate,Outputdata_Hybrid_reset]; %% 7-11-24 = 42
                                  %% 2 2 2 1 11 24
    write_space2                 = write_space2 + 1;
    end
 

    %%  Excel fill with result data

      end
    interval      = 900;
    Index_couple  = 4;
    path2 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund.xlsx';
    sheet_value2 = 12;
    writematrix(Work_space2, path2   ,'sheet',sheet_value2,'Range',['A' ,num2str(Index_couple )  ,':AP' ,num2str(Index_couple  + interval)]);


