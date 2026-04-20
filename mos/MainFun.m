


Nstep          = 3;

GPU_Mem        = zeros(1,Nstep);
S_Mem          = zeros(1,Nstep);



P_Memfeed      = 800;
y_feed_origin  = 0.904;
F_feed_origin  = 573.1397;
GPU_Mem_send   = 120;
S_Mem_send     = 40;
Work_space1    = zeros(30,30);
for i = 1:Nstep

GPU_Mem(i)        = 120;
S_Mem(i)          = 40;
end

parfor A = 1:10

Area           = A*200+4000; 
Area_set       = Area;     
% (Nstep,Area_set,GPU_Mem,S_Mem,P_Memfeed,y_feed_origin,F_feed_origin)

 
Outputproperty   = MultiMemstep_Pressure_op(Nstep,Area_set,GPU_Mem,S_Mem,P_Memfeed,y_feed_origin,F_feed_origin);
Work_spacedata   = [GPU_Mem_send,Area_set,S_Mem_send,Outputproperty];
Work_space1(A,:) = Work_spacedata;

end
    interval             = 30;
    Index_mem            = 23 ;
    
    path1 = 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Multi_Step_PressureOptim.xlsx';
    sheet_value1 = 4;
    writematrix(Work_space1, path1   ,'sheet',sheet_value1,'Range',['A' ,num2str(Index_mem),':AB'  ,num2str(Index_mem+ interval)]);


