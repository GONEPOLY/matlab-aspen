 function [T_out, P_out, F_out, Frac1, Frac2]=Conpressure(T , P , F , Frac1 , Frac2)
    t_feed = T;
    P_resdN = P;
    f_resd_Sum = F;
    Frac_py = Frac1;
    Frac_pa = Frac2;
    Pressure_ratio = 800/P_resdN ;
    if Pressure_ratio < 1.1
        Pressure_ratio = 1.1;
    end
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreada = hyspread(hysys, 'SPRDSHT-1');                          % Create a connection to a spreadsheet.
    m = hycell(spreada , {'C1', 'C2' , 'C3' , 'C4' , 'C5' , 'C6'});                % Connect to the cells in the spreadsheet. 
    % d_res = hyvalue(m);
    hyset(m(1), t_feed);                                      % Change the value
    hyset(m(2), P_resdN);
    hyset(m(3), f_resd_Sum);
    hyset(m(4), Frac_py);
    hyset(m(5), Frac_pa);
    hyset(m(6), Pressure_ratio);
    %% The second membrane
     pause(5) ;
   
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreadb_CON = hyspread(hysys, 'SPRDSHT-2');                  % Create a connection to a spreadsheet.
    %%d_res_CON = hycell(spreadb_CON, {'C1', 'C2','C3','C4'});    % Connect to the cells in the spreadsheet. 
    m1 = hycell(spreadb_CON, {'C1', 'C2','C3','C4','C5'});    % Connect to the cells in the spreadsheet.
    data = hyvalue(m1);
    T_out = data(1);
    P_out = data(2);
    F_out = data(3);
    Frac1 = data(5);
    Frac2 = data(4);
    %% CONPRESSURE
    end  