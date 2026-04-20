   clc
   clear
%    u = 0;
   Index = 35+7;
   IndexFill = 3+7;
%     for autofill_k = 1:14
    i = 2;
    
    [num] = xlsread('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Membrane little Selectivty', i , ['F',num2str(Index),':N',num2str(Index)]);
    
    res_propane_pressure =  num(9);                                 % Change the value 
    res_propene_pressure =  num(9);  
    res_propene_Molar    =  num(3);
    res_propane_Molar    =  num(4);
    perm_propane_Molar   =  num(2);
    perm_propene_Molar   =  num(1);
    
    hysys = hyconnect;                                               % Create a connection to Hysys.
    spreada = hyspread(hysys, 'SPRDSHT-12');                          % Create a connection to a spreadsheet.
    m = hycell(spreada , {'C3','C4','C5','C6','C7','C8'});                % Connect to the cells in the spreadsheet. 
    % d_res = hyvalue(m);
    hyset(m(1), res_propane_pressure);                                      % Change the value
    hyset(m(2), res_propene_pressure);
    hyset(m(3), res_propene_Molar);
    hyset(m(4), res_propane_Molar);
    hyset(m(5), perm_propane_Molar);
    hyset(m(6), perm_propene_Molar);
   
    hysys = hyconnect;                                               % Create a connection to Hysys.
                    % Create a connection to a spreadsheet.
    spreadb = hyspread(hysys, 'OUTPUT-1'); 
    m1 = hycell(spreadb , {'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12'});
    mm1 = hyvalue(m1);
    
    xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Energy exchange', mm1, 1, ['B',num2str(IndexFill),':M',num2str(IndexFill)]);
    pause(2);
    Index = Index  + 1;
    IndexFill = IndexFill + 1;
%     end