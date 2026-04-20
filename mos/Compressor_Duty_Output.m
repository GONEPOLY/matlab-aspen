
clc
clear
    span         = 60;
    Work_space2  = zeros( span ,1);
    Work_space3  = zeros( span ,3);
   
   i = 9;
   
    Sheet_value1 =  i;
    Sheet_value2 =  i;
      Index_Mem          = 3;
      interval           = span;
      write_Space        = 1;
      Index_couple       = 4;
      %% Read Input data
      path_read1 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two Stage Mem.xlsx';
      num        = readmatrix( path_read1   ,'Sheet', ['Sheet' ,num2str(Sheet_value1 )],'Range',  ['A' ,num2str(Index_Mem )  ,':Y' ,num2str(Index_Mem  + interval-1)]);  
      % path_read2 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund12.xlsx';
      % num_Modify = readmatrix( path_read2   ,'Sheet', ['Sheet' ,num2str(Sheet_value2 )],'Range',  ['H' ,num2str( Index_couple   )  ,':J' ,num2str( Index_couple    + interval-1)]);
      
    for read_index = 1 :span
    Temperature          =  54.5;
    res_pressure         =  num(read_index,7);  
    resd_Molar           =  num(read_index,11);
    resd_Molar_Frac1     =  num(read_index,12);
    resd_Molar_Frac2     =  1-resd_Molar_Frac1 ;
    resd_Molar_py        =  resd_Molar  *resd_Molar_Frac1;
    resd_Molar_pa        =  resd_Molar *resd_Molar_Frac2;
    P_resdN              =  num(read_index,7);
   
    Pressure_ratio       = 800/P_resdN ;
    % Pressure_ratio        =   fix(Pressure_ratio1 * 10)/10;
    if Pressure_ratio < 1.1
        Pressure_ratio = 1.1;
    end

    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreada = hyspread(hysys, 'SPRDSHT-1');                          % Create a connection to a spreadsheet.
    m = hycell(spreada , {'B1','B2','B3','B4','B5'});                % Connect to the cells in the spreadsheet. 
    % d_res = hyvalue(m);
    hyset(m(1), res_pressure); 
    hyset(m(2), resd_Molar);                                      % Change the value
    hyset(m(3), resd_Molar_Frac1);
    hyset(m(4), resd_Molar_Frac2);
    hyset(m(5),  Pressure_ratio);
    
    pause(0.1) ;
   
    hysys = hyconnect;                                               % Create a connection to Hysys.
                    % Create a connection to a spreadsheet.
    spreadb = hyspread(hysys, 'SPRDSHT-2'); 
    m1 = hycell(spreadb , {'C6'});
    mm1 = hyvalue(m1);
    Work_space2(write_Space)  = mm1*0.71*8000/10000;
    
    Work_space3(write_Space,1)  = num_Modify(read_index,3)  + num_Modify(read_index,2) + mm1*0.71*8000/10000;
    Work_space3(write_Space,2)  = num_Modify(read_index,2);
    Work_space3(write_Space,3)  = num_Modify(read_index,3)  + mm1*0.71*8000/10000;
    write_Space =   write_Space +1;
    end
    
    interval      = span;
    sheet  = ['Sheet',num2str(Sheet_value2)];
  
    path_write1 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy Edit fund12.xlsx';

    range2 =  ['AQ' ,num2str(Index_couple )  ,':AQ' ,num2str(Index_couple  + interval)];
    range3 =  ['H'  ,num2str(Index_couple )   ,':J'  ,num2str(Index_couple  + interval)];
    xlswrite(path_write1, Work_space2, sheet, range2);
    % xlswrite(path_write1, Work_space3, sheet, range3);

