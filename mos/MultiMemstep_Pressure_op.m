    
function Outputproperty = MultiMemstep_Pressure_op(Nstep,Area_set,GPU_Mem,S_Mem,P_Memfeedorigin,y_feed_origin,F_feed_origin)

        N                   = 2000; 
        Membrane_Parameter  = zeros(Nstep,8);
        Outputdata          = zeros(Nstep,7);
        f_resd              = zeros(Nstep,1);
        f_perm              = zeros(Nstep,1);
        FracP_py            = zeros(1,Nstep);
        FracP_pa            = zeros(1,Nstep);
        P_resd_out          = zeros(Nstep,1);
        FracR_py            = zeros(Nstep,1);
        FracR_pa            = zeros(Nstep,1);
        f_perm_py           = zeros(Nstep,1);
        f_perm_pa           = zeros(Nstep,1);
        y_feed              = zeros(Nstep,1);
        F_feed              = zeros(Nstep,1);
        Area                = zeros(Nstep,1);
        P_Memfeed           = zeros(1,Nstep);

        for Mem_I  = 1 :Nstep 

                  P_Memfeed(Mem_I) = P_Memfeedorigin;
                   Area(1)         = 2000;
                   Area(2)         = 2000;
                   Area(3)         = Area_set - 4000;

                  if Mem_I >=2
                      y_feed(Mem_I)    = FracR_py(Mem_I-1);
                      F_feed(Mem_I)    = f_resd(Mem_I-1);  
                  else
                      y_feed(Mem_I)    = y_feed_origin;
                      F_feed(Mem_I)    = F_feed_origin;   
                  end 
               
      

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
   
    %% output result data and integrate
    f_perm_py(Mem_I)      =  FracP_py(Mem_I) * f_perm(Mem_I) ;
    f_perm_pa(Mem_I)      =  FracP_pa(Mem_I) * f_perm(Mem_I) ;  
    f_perm_sum            =  sum(f_perm); 
    f_perm_py_sum         =  sum(f_perm_py);
    f_perm_Purity_py      =  100 * f_perm_py_sum/f_perm_sum;
    f_Recovery_py         =  100 * f_perm_py_sum/(y_feed_origin*F_feed_origin);
    Outputdata(Mem_I,:)   =  [P_resd_out(Mem_I), f_perm(Mem_I),  FracP_py(Mem_I),  FracP_pa(Mem_I),  f_resd(Mem_I),  FracR_py(Mem_I),  FracR_pa(Mem_I)];  % 7 

    Purity_py_sum               =  f_perm_Purity_py;
    Purity_Mix                  =  [FracP_py,Purity_py_sum]; % 1+N
    Recovery                    =  f_Recovery_py ; %1

   
   %% the last matrix  send to main function 
    Outputproperty = [Outputdata(1,:),Outputdata(2,:),Outputdata(3,:),f_perm_sum ,Recovery,Purity_Mix]; % 7*N + 1+N +1
       end   
end