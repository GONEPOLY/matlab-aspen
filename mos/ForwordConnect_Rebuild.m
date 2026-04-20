 function Parameter_Project_Hybird = ForwordConnect_Rebuild(Perm_Pres,  Perm_flow_py, Perm_flow_pa,Resd_Pres, Resd_flow_py, Resd_flow_pa)
    
    
    
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreada = hyspread(hysys, 'SPRDSHT-11');                          % Create a connection to a spreadsheet.
    m = hycell(spreada , {'C1', 'C2' , 'C3' , 'C4' , 'C5' , 'C6', 'C7' , 'C8'});                % Connect to the cells in the spreadsheet. 

    Parameter_fill = [Perm_Pres, Perm_Pres, Resd_Pres, Resd_Pres, Perm_flow_py, Perm_flow_pa,  Resd_flow_py, Resd_flow_pa];
    hyset(m(1), Parameter_fill(1)); 
    hyset(m(2), Parameter_fill(2)); 
    hyset(m(3), Parameter_fill(3));                                      % Change the value
    hyset(m(4), Parameter_fill(4));
    hyset(m(5), Parameter_fill(5));
    hyset(m(6), Parameter_fill(6));
    hyset(m(7), Parameter_fill(7));
    hyset(m(8), Parameter_fill(8));
    fill_matrixR = zeros(1,36); 
    R_frac  =   Resd_flow_py/(Resd_flow_py+ Resd_flow_pa );
    
     %% scratch data from tabel of hysys and assign to value
       Table_cratch  = cell(1, 36);
       Table_assign  = cell(1, 36);
       for i = 1:36
        Table_cratch{1,i} = ['A' num2str(i)];
        Table_assign{1,i} = ['A' num2str(i)];
       end
     
      record = 1;
      Index_R = 0;

       while  record ~=Index_R
          
  
    %% fill the optimize stage value by the tee model
    hysys = hyconnect; 
    spreada_frac = hyspread(hysys, 'SPRDSHT-22');
    %% fill region B1:B27 AND D1:D21
    value_frac   = hycell(spreada_frac , Table_assign ); 
    Data_cratch  = hyvalue(value_frac);
    [~,Index_R]  = min(abs(Data_cratch  -R_frac));
    hysys        = hyconnect; 
    spreada_ratio = hyspread(hysys, 'SPRDSHT-32');
    %% fill region B1:B27 AND D1:D21
    value_ratio = hycell(spreada_ratio , Table_assign ); 
    fill_matrixR(Index_R) = 1;
    hyset(value_ratio(1:36), fill_matrixR);
    record = Index_R;
      end
 
    %% The second membrane
    pause(1);


    %% output fun
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreadb_output = hyspread(hysys, 'OUTPUT-1');                  % Create a connection to a spreadsheet.
    
    m1 = hycell(spreadb_output, {'C1', 'C2','C3','C4','C5','C6', 'C7','C8','C9' ,'C10','C11','C12'});    % Connect to the cells in the spreadsheet.
    data = hyvalue(m1);
    D_MoleFlow = data(1);
    D_MassFlow = data(2);
    C101       = data(3);
    K101A      = data(4);
    K101B      = data(5);
    K102       = data(6);
    Q_CONDEX   = data(7);
    Q_REBIOL   = data(8);
    Q_E103     = data(9);
    Q_E104     = data(10);
    Q_E105     = data(11);
    Q_E106     = data(12);
    Parameter_Project_Hybird = [D_MoleFlow,D_MassFlow , C101, K101A, K101B, K102,Q_CONDEX,Q_REBIOL, Q_E103,Q_E104,Q_E105, Q_E106];
    %% CONPRESSURE
    end  