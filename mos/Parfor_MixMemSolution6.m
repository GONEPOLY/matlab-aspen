 clc
     clear

   

      Nstep              =  2;
      Mem_Index          =  Nstep;
      Mem_I              =  Nstep;
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
      f_perm_downstream_pa = zeros(1,Mem_Index);
      Outputdata         =  zeros(Mem_Index,7);     
      Area(:)            =  0;
      upper_limits       = [4500, 4500];
      a                  = zeros(1,Nstep);
      Outputdata_Area    = [];
      Work_space1         = zeros(3600,25);
      Work_space2         = zeros(3600,42);
      write_space1        = 1;
      write_space2        = 1;
      Area_sum   =  6000;

   %%   Original value
      N                = 2000; 
      P_Memfeed(1)     = 800;
      F_feed(1)        = 573.1397;
      y_feed(1)        = 0.904;
     
      % GPU_Mem(:)       = [44; 90]; 
      % S_Mem(:)         = [23; 50];  
       GPU_Mem(:)       = [90; 44]; 
      S_Mem(:)         = [50; 23]; 

  for A1               = 5200:200:6000 
      for A2               = 200:200:6000
   
      
            for Mem_I  = 1 :Nstep 
     
                  if Mem_I >=2
                      y_feed(Mem_I)    = FracR_py(Mem_I-1);
                      F_feed(Mem_I)    = f_resd(Mem_I-1);  
                      P_Memfeed(Mem_I) = P_Memfeed(1);
                  end 
                  
    Area(:)= [A1,A2];
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

    f_perm_downstream_py(Mem_I) =  FracP_py(Mem_I) * f_perm(Mem_I) ;
    f_perm_downstream_pa(Mem_I) =  FracP_pa(Mem_I) * f_perm(Mem_I) ;
    
     f_perm_downstream_sum           =  sum(f_perm);
     f_perm_downstream_py_sum        =  sum(f_perm_downstream_py);
     f_perm_downstream_pa_sum        =  sum(f_perm_downstream_pa);
     f_perm_downstream_Purity_py     =  100 * f_perm_downstream_py_sum/f_perm_downstream_sum;
     f_perm_downstream_Recovery_py   =  100 * f_perm_downstream_py_sum/(y_feed(1)*F_feed(1));
    %% output result data
    Outputdata(Mem_I,:)         = [P_resd_out(Mem_I), f_perm(Mem_I),  FracP_py(Mem_I),  FracP_pa(Mem_I),  f_resd(Mem_I),  FracR_py(Mem_I),  FracR_pa(Mem_I)];  % 7 
    
    Outputdata_Area             =  [A1,A2];
    Purity1                     =  FracP_py(1);
    Purity2                     =  FracP_py(2);
    Purity_py_sum               =  f_perm_downstream_Purity_py;
    Purity_Mix                  =  [Purity1,Purity2,Purity_py_sum];
    Recovery                    =  f_perm_downstream_Recovery_py;
           end
    
     %% Price of Mem and Comform

     Price_6FDA  = 2344;
     Price_ZIF8 = 6000;
     Cost_Mem  = A1*Price_6FDA +  A2*Price_6FDA;


    
    %% ForwardConnect_Rebuild parameter Integrate

    P_resd_connect     =  P_resd_out(2);
    P_perm_connect     =  10;
    f_resd_py_connect  =  FracR_py(2)*f_resd(2);
    f_resd_pa_connect  =  FracR_pa(2)*f_resd(2);
    f_perm_py_connect  =  f_perm_downstream_py_sum;
    f_perm_pa_connect  =  f_perm_downstream_pa_sum;
    Work_space1(write_space1,:)  = [GPU_Mem, Outputdata_Area, S_Mem, Outputdata(1,:) , Outputdata(2,:) ,f_perm_downstream_sum,Recovery,Purity_Mix];
   
    write_space1 = write_space1 +1;

     end
  end

    %%  Excel fill with result data

    interval             = 150;
    Index_mem            = 753;


    path1 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 2.xlsx';
    sheet_value1 = 3;
    writematrix(Work_space1, path1   ,'sheet',sheet_value1,'Range',['A' ,num2str(Index_mem),':Y'  ,num2str(Index_mem+ interval-1)]);

 
    