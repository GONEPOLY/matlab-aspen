
clc
clear
    i = 1;
    Index = 27;
    IndexFill = 27;
    for j = 1:62
    [num] = xlsread('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two stage Mem', i , ['F',num2str(Index),':M',num2str(Index)]);
                            
    res_pressure         =  num(1);  
    resd_Molar           =  num(5);
    resd_Molar_Frac1     =  num(6);
    resd_Molar_Frac2     =  num(7);
    P_resdN              =  num(1);
    Pressure_ratio       = 800/P_resdN ;
    if Pressure_ratio < 1.1
        Pressure_ratio = 1.1;
    end
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreada = hyspread(hysys, 'SPRDSHT-1');                          % Create a connection to a spreadsheet.
    m = hycell(spreada , {'C2','C3','C4','C5','C6'});                % Connect to the cells in the spreadsheet. 
    % d_res = hyvalue(m);
    hyset(m(1), res_pressure);                                      % Change the value
    hyset(m(2), resd_Molar);
    hyset(m(3), resd_Molar_Frac1);
    hyset(m(4), resd_Molar_Frac2);
    hyset(m(5), Pressure_ratio);
    pause(5) ;
   
    hysys = hyconnect;                                               % Create a connection to Hysys.
                    % Create a connection to a spreadsheet.
    spreadb = hyspread(hysys, 'SPRDSHT-2'); 
    m1 = hycell(spreadb , {'C6'});
    mm1 = hyvalue(m1);
    
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two stage Mem', mm1, 1, ['AG',num2str(IndexFill),':AH',num2str(IndexFill)]);
    pause(2);
    Index = Index  + 1;
    IndexFill = IndexFill + 1;
    end