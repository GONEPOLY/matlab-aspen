% function CreatePlotInOrigin()   
%     originObj=actxserver('Origin.ApplicationSI'); %??origin?COM??
%    
%     invoke(originObj, 'Execute', 'doc -mc 1;');       
%     invoke(originObj, 'IsModified', 'false');   
% 
%     invoke(originObj, 'Execute', 'syspath$=system.path.program$;');
%     strPath='';
%     strPath = invoke(originObj, 'LTStr', 'syspath$');
%     invoke(originObj, 'Load', strcat(strPath, 'Samples\COM Server and Client\Matlab\CreatePlotInOrigin.OPJ'));
%     
%     mdata = [0.1:0.1:3; 10 * sin(0.1:0.1:3); 20 * cos(0.1:0.1:3)]; %????
%     mdata = mdata';  %????????????worksheet???
% 
%     invoke(originObj, 'PutWorksheet', 'Data1', mdata);   %??????worksheet
% 
%     invoke(originObj, 'Execute', 'page.active = 1; layer - a; page.active = 2; layer - a;'); %???????2???
%     invoke(originObj, 'CopyPage', 'Graph1'); % ???????? 
%     
%  end
 

%  

%     originObj=actxserver('Origin.ApplicationSI');
% 
%     % Make the Origin session visible
%     originObj.Execute('doc -mc 1;');
%        
%     % Clear "dirty" flag in Origin to suppress prompt for saving current project
%     % You may want to replace this with code to handling of saving current project
%     originObj.IsModified = false;
%    %%acquire data
    Index_Start = 103;
    Index_end   = 134;
    num_get1  =  xlsread('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 2.xlsx','sheet2',['C'  ,num2str(Index_Start),':C'  ,num2str(Index_end)]);
    num_get1_sum = num_get1.*2;
    num_get2  =  xlsread('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 2.xlsx','sheet2',['X'  ,num2str(Index_Start),':X'  ,num2str(Index_end)]);
    num_get3  =  xlsread('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Two step Mem 2.xlsx','sheet2',['AA' ,num2str(Index_Start),':AA' ,num2str(Index_end)]);
    x_preview =  [num_get1, num_get2, num_get3];
    x         =  x_preview;
    MATLABCallOrigin_Goneset(x_preview);
    
%     originObj.Load( 'C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\Plot\OriginC\Plot_SingleStep_XArea_ForMATWithOrigin.OPJU');
%     strBook = invoke(originObj, 'CreatePage', 2, '', 'Origin');  %???2  
%     wks = invoke(originObj, 'FindWorksheet', strBook); 
%     invoke(wks, 'Name', 'MySheet');   %???worksheet
%         %Set column
%     invoke(wks, 'Cols', 4);  %????
%     cols = invoke(wks, 'Columns'); % require columes parameter
%     colx = invoke(cols, 'Item', uint8(0)); 
%     coly = invoke(cols, 'Item', uint8(1));
%     colerr = invoke(cols, 'Item', uint8(2));  
%     colere = invoke(cols, 'Item', uint8(3));  
%     invoke(colx, 'Type', 3);  % x column
%     invoke(coly, 'Type', 10);  % y column
%     invoke(colerr, 'Type', 0);  % y error????1.1???????y????????????origin????“??????Y???”
%     invoke(wks, 'SetData', x, 0, 0);   
% %     invoke('creatpage', 3, '', 'Origin')
% %     originObj.Execute('page.active = 1; layer - a; page.active = 2; layer - a;');
% %     gl = invoke(originObj, 'FindGraphLayer'); 
%      % Build Plot
%     strGraph1 = invoke(originObj, 'CreatePage', 3, '', 'Origin');  
% %     strGraph2 = invoke(originObj, 'CreatePage', 3, '', 'Origin'); 
%     originObj.Execute('page.active = 1; layer - a; page.active = 2; layer - a;');
%     invoke(originObj, 'FindGraphLayer', strGraph1); 
%     
%     g1 = invoke(originObj, 'FindGraphLayer', strGraph1); 
%  disp(g1);


