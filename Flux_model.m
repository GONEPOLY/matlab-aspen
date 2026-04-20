
function PERMEANCE_GPU = Flux_model(filename, membrane_id, MCH_feed)
 
   
    sheets = sheetnames(filename);
    n = length(sheets);
    
    if membrane_id < 1 || membrane_id > n
        error('膜编号必须为 1~%d（当前Excel共有%d个膜）', n, n);
    end
     
    % ===== 浓度范围检查（新增）=====
    if any(MCH_feed < 0) || any(MCH_feed > 1)
        warning('MCH进料浓度应在 0~1 之间，当前输入存在越界值');
    end
    
    % ===== 只读取对应膜的数据 =====
    data = readmatrix(filename, ...
        'Sheet', sheets{membrane_id}, ...
        'Range', 'K:M', ...
        'NumHeaderLines', 1);
     % 去空行
    data = data(~all(isnan(data),2), :);
  
    % ===== 数据拆分 =====
    x = data(:,3);      % MCH进料浓度
    y_tol = data(:,1);  % Tol flux
    y_mch = data(:,2);  % MCH flux
    
    % ===== 拟合（线性）=====
    p_tol = polyfit(x, y_tol, 3);
    p_mch = polyfit(x, y_mch, 3);   
    % ===== 外推检查 =====
    xmin = min(x);
    xmax = max(x);

    if any(MCH_feed < xmin) || any(MCH_feed > xmax)
        warning('输入浓度超出实验范围 [%g, %g]，属于外推', xmin, xmax);
    end
    
    % ===== 预测 =====
    Tol_flux = polyval(p_tol, MCH_feed);
    MCH_flux = polyval(p_mch, MCH_feed);
    PERMEANCE_GPU = [MCH_flux, Tol_flux ];
end 