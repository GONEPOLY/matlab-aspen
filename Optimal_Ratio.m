% 通用函数用于优化
function Ratio_result = Optimal_Ratio(start_value, step_size, end_value, target_value, target_type)
    % 初始化默认值
    Ratio_result = NaN;
    
    % 循环查找最优比率
    for ratio = start_value:step_size:end_value
       
        if strcmp(target_type, '1')
             Aspen.Application.Tree.FindNode('\Data\Blocks\DT1\Input\BASIS_RR').value = ratio;
        elseif strcmp(target_type, '2')
            Aspen.Application.Tree.FindNode('\Data\Blocks\DT2\Input\BASIS_RR').value = ratio;
        elseif strcmp(target_type, '3')
            Aspen.Application.Tree.FindNode('\Data\Blocks\DT3\Input\BASIS_RR').value = ratio;
        end
        
        Run2(Aspen.Engine);

        % 根据目标类型选择对应的输出
        if strcmp(target_type, '1')
            output_value = Aspen.Application.Tree.FindNode('\Data\Streams\DT1S\Output\MOLEFRAC\MIXED\METHA-01').value;
        elseif strcmp(target_type, '2')
            output_value = Aspen.Application.Tree.FindNode('\Data\Streams\DT2G\Output\MOLEFLOW\MIXED\HELIU-02').value;
        elseif strcmp(target_type, '3')
            output_value = Aspen.Application.Tree.FindNode('\Data\Streams\DT3G\Output\MOLEFRAC\MIXED\HELIU-02').value;
        end
        
        % 如果满足条件，则退出循环
        if output_value >= target_value
           Ratio_result = ratio;
            break;
        end
    end
    
    % 如果在最大迭代次数内没有找到合适的结果，可以给出提示
    if isnan(Ratio_result)
        disp(['没有找到合适的比率，目标值 ', num2str(target_value), ' 没有达到']);
    end
end


