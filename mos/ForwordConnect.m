 function Parameter_Project_Hybird = ForwordConnect(Pres_feed1 ,Pres_feed2 , f_resd_py , f_resd_pa ,f_perm_pa,f_perm_py)
    
    Down_stream_pres = 10;
    
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreada = hyspread(hysys, 'SPRDSHT-1');                          % Create a connection to a spreadsheet.
    m = hycell(spreada , {'C1', 'C2' , 'C3' , 'C4' , 'C5' , 'C6', 'C7' , 'C8'});                % Connect to the cells in the spreadsheet. 
%     m_value = hyvalue(m);
    Parameter_fill = [Down_stream_pres,Down_stream_pres,Pres_feed1,Pres_feed2,f_resd_py,f_resd_pa,f_perm_pa,f_perm_py] ;
    hyset(m(1), Parameter_fill(1)); 
    hyset(m(2), Parameter_fill(2)); 
    hyset(m(3), Parameter_fill(3));                                      % Change the value
    hyset(m(4), Parameter_fill(4));
    hyset(m(5), Parameter_fill(5));
    hyset(m(6), Parameter_fill(6));
    hyset(m(7), Parameter_fill(7));
    hyset(m(8), Parameter_fill(8));
    %% The second membrane
    pause(1) ;
   
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreadb_output = hyspread(hysys, 'OUTPUT-1');                  % Create a connection to a spreadsheet.
    %%d_res_CON = hycell(spreadb_CON, {'C1', 'C2','C3','C4'});    % Connect to the cells in the spreadsheet. 
    m1 = hycell(spreadb_output, {'C1', 'C2','C3','C4','C5','C6', 'C7','C8','C9' ,'C10','C11','C12'});    % Connect to the cells in the spreadsheet.
    data = hyvalue(m1);
    D_MoleFlow = data(1);
    C101     = data(3);
    K101A    = data(4);
    K101B    = data(5);
    K102     = data(6);
    Q_CONDEX = data(7);
    Q_REBIOL = data(8);
    Q_E103   = data(9);
    Q_E104   = data(10);
    Q_E105   = data(11);
    Q_E106   = data(12);
    Parameter_Project_Hybird = [D_MoleFlow, C101, K101A, K101B, K102,Q_CONDEX,Q_REBIOL, Q_E103,Q_E104,Q_E105, Q_E106];
    %% CONPRESSURE
    end  