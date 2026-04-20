function Call_WriteCell(database ,tick, NStage,filename) 
                    headers_pres = {'上游压力'};
                    headers_A    = arrayfun(@(x) sprintf('第%d级膜面积', x), 1:NStage, 'UniformOutput', false);
                    headers_R    = arrayfun(@(x) sprintf('He回收率%d',x), 1:NStage, 'UniformOutput', false);
                    headers_P    = arrayfun(@(x) sprintf('He纯度%d',x), 1:NStage, 'UniformOutput', false);
                    
                    % 总能耗
                    headers_eduty = {'总电耗'};
                    headers_cduty = {'总冷耗'};
                    headers_hduty = {'总热耗'};
                    
                    % 塔出口
                    headers_oputHE1_R = {'塔出口HE回收率'};
                    headers_oputHE1_P = {'塔出口HE纯度'};
                    
                    % 氮循环能耗
                    headers_oputN2_Cycle = {'氮循环能耗'};
                    
                    % 塔1~3冷热
                    headers_oputDT1_Condensor = {'塔1冷耗'};
                    headers_oputDT1_Reboiler  = {'塔1热耗'};
                    headers_oputDT2_Condensor = {'塔2冷耗'};
                    headers_oputDT2_Reboiler  = {'塔2热耗'};
                    headers_oputDT3_Condensor = {'塔3冷耗'};
                    headers_oputDT3_Reboiler  = {'塔3热耗'};
                    
                    % 合并表头
                    headers = [headers_pres, headers_A, headers_R, headers_P, ...
                               headers_eduty, headers_cduty, headers_hduty, ...
                               headers_oputHE1_R, headers_oputHE1_P, headers_oputN2_Cycle, ...
                               headers_oputDT1_Condensor, headers_oputDT1_Reboiler, ...
                               headers_oputDT2_Condensor, headers_oputDT2_Reboiler, ...
                               headers_oputDT3_Condensor, headers_oputDT3_Reboiler];
                    
                    writecell(headers, filename, 'Sheet', NStage, 'Range', 'A1');
                    database = database(1:tick-1, :);
                    writematrix(database, filename, 'Sheet', NStage, 'Range', 'A2');
    end