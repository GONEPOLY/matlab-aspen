          clear
          clc
  
      Index    = 4;
      
      
      Nstep     = 3;
      Mem_Index = Nstep;
      Mem_I     = Nstep;
      GPU_Mem            =  zeros(1,Mem_Index);
      S_Mem              =  zeros(1,Mem_Index);
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
      Outputdata         =  zeros(Mem_Index,7);     
      Area(:)            = 0;
      upper_limits = [3000, 3000, 3000];
      a     = zeros(1,Nstep);
 for  Area_sum =200:200:9200
   %%   Original value



for i = 1:Nstep

    a(i) = Area_sum  -  upper_limits(i);
    a1   = a(i);
    if a1 >=0
        Area(i) = upper_limits(i);
    else
        
        Area(i) = max(1,Area_sum);
    end
    Area_sum = Area_sum  -  upper_limits(i);
end
      N                = 2000; 
      P_Memfeed(1)     = 800;
      F_feed(1)        = 573.1397;
      y_feed(1)        = 0.904;
      GPU_Mem(:)       = [120; 120; 120]; 
      S_Mem(:)         = [90; 90; 90];    
      
      
      
      for Mem_I  = 1 :Nstep 
     
           if Mem_I >=2
               y_feed(Mem_I)    = FracR_py(Mem_I-1);
               F_feed(Mem_I)    = f_resd(Mem_I-1);  
               P_Memfeed(Mem_I) = P_Memfeed(1);
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
    t_feed            = Membrane_Parameter(Mem_I,8);
    
    %% output result data
    Outputdata(Mem_I,:) = [P_resd_out(Mem_I), f_perm(Mem_I),  FracP_py(Mem_I),  FracP_pa(Mem_I),  f_resd(Mem_I),  FracR_py(Mem_I),  FracR_pa(Mem_I)];
   
    f_perm_downstream_py(Mem_I) =  FracP_py(Mem_I) * f_perm(Mem_I) ;

   
    %% Increase the pressure by hysys
%     [T_out, P_out, F_out, Frac1, Frac2]=Conpressure(t_feed1, P_resd_out1, f_resd_1 , FracR_py1, FracR_pa1); %% Increase the pressure

%     


   
    
      end
     f_perm_downstream_sum       =  sum(f_perm);
     f_perm_downstream_py_sum    =  sum(f_perm_downstream_py);
     f_perm_downstream_Purity_py =  100 * f_perm_downstream_py_sum/f_perm_downstream_sum;
     f_perm_downstream_Recovery_py =  100 * f_perm_downstream_py_sum/(y_feed(1)*F_feed(1));
     Outputdata_PR               =  [f_perm_downstream_Purity_py,f_perm_downstream_Recovery_py];
     xlswrite('C:\Users\GONEPOLYWING\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Area                ,'sheet4',['A',num2str(Index),':C',num2str(Index)]); 
     xlswrite('C:\Users\GONEPOLYWING\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',GPU_Mem             ,'sheet4',['D',num2str(Index),':F',num2str(Index)]); 
     xlswrite('C:\Users\GONEPOLYWING\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',S_Mem               ,'sheet4',['G',num2str(Index),':I',num2str(Index)]); 
     xlswrite('C:\Users\GONEPOLYWING\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',P_resd_out          ,'sheet4',['J',num2str(Index),':L',num2str(Index)]); 
     xlswrite('C:\Users\GONEPOLYWING\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 1.xlsx',Outputdata_PR       ,'sheet4',['M',num2str(Index),':N',num2str(Index)]); 
     Index = Index + 1;
     
     
 end
 
 
 
 
 