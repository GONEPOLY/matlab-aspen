       %%initial value
        Nstep     = 3;
        t_feed    = 54.5;
        N         = 200;
        y_feed    = 0.904;
        f_feed    = 573.1397;
        Select    = 85;
        GPU       = 120;
        P_Memfeed = 800;  
        Area_step = [3000 3000 3000];
        Recovery_py_accumulative = 0;
        Flow_Perm_accumulative   = 0;
        Flow_downport_py         = 0 ;
        Index                    = 11;
for step=1:Nstep
     
     
         t_feed     = 54.5;
         S          = Select;
         G          = GPU;
         Area       = Area_step(step);
        %%get last value as next input value
        if step>=2
         y_feed_in  = Membrane_Parameter_last(6);
         f_feed_in  = Membrane_Parameter_last(1);
        else
         y_feed_in  = y_feed;
         f_feed_in  = f_feed;
        end
        
        P_Memfeed   = 800;
        [f_resd , f_perm_sum, FracP_py, FracP_pa, P_resdN , FracR_py , FracR_pa , t_feed_out] = Call_MembraneSolution(G, S, Area, f_feed_in, P_Memfeed,  y_feed_in, N, t_feed);
        Membrane_Parameter1 = [f_resd , f_perm_sum, FracP_py, FracP_pa, P_resdN , FracR_py , FracR_pa , t_feed_out] ;
        Membrane_Parameter_last = Membrane_Parameter1;
        %% permeate side paremeter
        Flow_perm    = Membrane_Parameter1(2);
        Frac_perm_py = Membrane_Parameter1(3);
        Flow_perm_py = Membrane_Parameter1(2)* Membrane_Parameter1(3);
        Flow_perm_pa = Membrane_Parameter1(2)* Membrane_Parameter1(4);
       
        %% residual side paremeter
        Flow_resd    = Membrane_Parameter1(1);
        Frac_resd_py = Membrane_Parameter1(6);
        Flow_resd_py = Membrane_Parameter1(2)* Membrane_Parameter1(6);
        Flow_resd_pa = Membrane_Parameter1(2)* Membrane_Parameter1(7);
        Pres_resd    = Membrane_Parameter1(5);
        %% accumulative parameter
   
        Flow_Perm_accumulative = Flow_Perm_accumulative + Membrane_Parameter1(2);
        Flow_downport_py  = Flow_downport_py + Flow_perm_py;
        Frac_downport_py  = Flow_downport_py/Flow_Perm_accumulative;
        Recovery_py_accumulative = Flow_Perm_accumulative/(y_feed*f_feed);
        Recovery_py_accumulative_output = Recovery_py_accumulative * 100;
        
        Outputdata        = [Flow_Perm_accumulative, Recovery_py_accumulative_output,Frac_downport_py ,Frac_perm_py,Flow_perm ,Flow_perm_py, Flow_perm_pa, Flow_resd_py,  Flow_resd_pa,  Flow_resd, Frac_resd_py, Pres_resd];
        xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Membrane data reset pro', Outputdata, 4, ['E',num2str(Index),':P',num2str(Index)]);
        
        Index = Index+1;
 end
 
 
 
 
 
 
 
 
 
 
 
 
 
 