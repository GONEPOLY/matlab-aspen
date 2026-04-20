function fitness = obj
format long g
k = 0;
for m = 5 : 1 : 10
    k=k+1;
    x(1)=m;
    hysys = hyconnect;                               % Create a connection to Hysys.
    spreada = hyspread(hysys, 'data');               % Create a connection to a spreadsheet.
    d = hycell(spreada, {'a2'}); % Connect to the cells  in the spreadsheet. 

    hyset(d(1),x(1));          % Change the value



    while hyissolving(hysys)==1 % Check if the solver is running.
    end

    spreadb = hyspread(hysys, 'data');                    % Create a connection to a spreadsheet.
    m = hycell(spreadb, {'b2','b3','b4'});                     % Connect to the cells  in the spreadsheet.
    nsr= hyvalue(m);                                      % Read the values of the cells.
    R(1,k)=x(1);
    R(2,k)=nsr(1)*3600;
    R(3,k)=nsr(2)*3600;
    R(4,k)=nsr(3)*3600;
end
R
save R
  


        
        
    





