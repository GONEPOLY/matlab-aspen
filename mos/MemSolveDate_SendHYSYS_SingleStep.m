  
clc
clear
      Nstep              =  1;
      Mem_Index          =  Nstep;
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
      span               = 50;
      Work_space1        = zeros( span ,24);
      Work_space2        = zeros( span ,39);
      Work_space3        = zeros( span ,4);
      % Price              = cell(1,4);
      write_space1       = 1;
      write_space2       = 1;
       % Initialize Price array
      Index_Mem          = 3;
      Index_couple       = 4;
      interval           = span ;
      
     % for read_i = 1:4
             read_i = 5;  
      path = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Single Step.xlsx';
      Sheet_value2 =  ['Sheet' ,num2str(read_i)];
      Read_Data = readmatrix( path   ,'Sheet',Sheet_value2,'Range',  ['A' ,num2str(Index_Mem )  ,':L' ,num2str(Index_Mem  + interval-1)]);
      Price = 195;
      for Read_Index =1:span
      
          if Read_Data(Read_Index,3) ~= 31
               Price =3360;
          end
      P_resd_connect     =   Read_Data (Read_Index, 4);
      P_perm_connect     =   10;
      f_perm_py_connect  =   Read_Data(Read_Index,5) * Read_Data(Read_Index,6);
      f_perm_pa_connect  =   Read_Data(Read_Index,5) * Read_Data(Read_Index,7);
      f_resd_py_connect  =   Read_Data(Read_Index,8) * Read_Data(Read_Index,9);
      f_resd_pa_connect  =   Read_Data(Read_Index,8) * Read_Data(Read_Index,10);
      f_perm             =   f_perm_pa_connect + f_perm_py_connect;
      Parameter_Project_Hybird  =  ForwordConnect_OptimizeFeedStage(P_perm_connect, f_perm_py_connect, f_perm_pa_connect  , P_resd_connect,f_resd_py_connect,f_resd_pa_connect);
   
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
    GPU_Mem     = Read_Data(Read_Index,1);
    A1          = Read_Data(Read_Index,2);
    S_Mem       =   Read_Data(Read_Index,3);
    Outputdata_Area =   A1;

    
    %% of TOC
    Total_condenser       =  (E101+E103+E105+E106)*0.025*8000/(3600*10000);
    Total_Vacum           =  (0.22*C101/0.9)*8000/10000;
    Total_Heater          =  0.41*E102*8000/(3600*10000);
    Total_Electic_Duty    =   K101A+K101B+K102;
    Total_Electic_Price   =  (0.7*(K101A+K101B+K102)/0.9)*8000/10000;

    %% of TCC
    Cost_Mem  = A1*Price/10000;
    EXchanger_Area        =  (E103+E104+E105+E106)/(158.265*10); 
    EXchanger_enquipment  =  8*(EXchanger_Area^0.65)*(1448.3/280)*(2.29+3.75)/(10000);
    Comp_enquipment       =  8*((1448.3/280)*2047.24)*(((K101A+K101B+K102)/0.7457)^0.65)/10000;
    Vacuum_enquipment     =  8*4200*( (60*8.314*273.15*f_perm/(3600*101.325))^0.55)/10000;
    AOC                   =  Total_Electic_Price + Total_Heater + Total_condenser  + Total_Vacum;
    TCC                   =  (EXchanger_enquipment + Cost_Mem + Comp_enquipment +Vacuum_enquipment);
    TAC                   =  (TCC + AOC ); 
    Cost_Integrate        =  [TAC,TCC,AOC,Cost_Mem,EXchanger_enquipment,EXchanger_Area,Total_Electic_Price,Total_Electic_Duty,Total_Heater,Total_Vacum,Total_condenser];  %% 11 Point

    %%  19 22 25 28 31 33 35 37 39 41 
    Outputdata_Hybrid_reset      = [K101A,K101A/0.9,0.22*K101A/0.9,K101B,K101B/0.9,0.22*K101B/0.9,K102,K102/0.9,0.22*K102/0.9,C101,C101/0.9,0.22*C101/0.9,E101,E101*0.025/3600,E102,E102*0.41/3600,E103,E103*0.025/3600,E104,E104*0.025/3600,E105,E105*0.025/3600,E106,E106*0.025/3600];
    Work_space2(write_space2,:)  = [GPU_Mem,Outputdata_Area,S_Mem,Draw_Dist_mole, Cost_Integrate,Outputdata_Hybrid_reset]; %% 7-11-24 = 42
    Work_space3(write_space2,:)  = [Vacuum_enquipment,EXchanger_enquipment,Comp_enquipment,Price];                   
    %% 2 2 2 1 11 24
    write_space2                 = write_space2 + 1;

    %%  Excel fill with result data 6 7 8 / 9  10  11

      end
    interval      =  span ;
   
    path2 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund_SingleStep.xlsx';
    sheet_value2 = read_i;
    sheet = ['Sheet',num2str(sheet_value2)];
    range2 = ['A' ,num2str(Index_couple )  ,':  AM' ,num2str(Index_couple  + interval)];
    range3 = ['AO' ,num2str(Index_couple )  ,':  AR' ,num2str(Index_couple  + interval)];
    xlswrite(path2, Work_space2, sheet, range2);
    xlswrite(path2, Work_space3, sheet, range3);
 
       