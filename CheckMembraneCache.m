function result = checkCache(cacheFile, NStage, Mem_Area, P_feed, P_perm)
    % 检查缓存中是否有相同的计算结果
    % cacheFile: 缓存文件名 (字符串, 比如 'cacheData.mat')
    % NStage: 膜分离级数
    % Mem_Area: 膜面积数组, 长度 = NStage
    % P_feed: 上游压力
    % P_perm: 下游压力
    % result: 如果找到则返回缓存结果，否则返回 []

    % 默认返回空
    result = [];

    % 如果文件存在就加载，否则直接返回空
    if ~isfile(cacheFile)
        return;
    end
    load(cacheFile, 'cacheData');

    if isempty(cacheData)
        return;
    end

    % 遍历缓存
    for i = 1:numel(cacheData)
        entry = cacheData(i);

        % 判断NStage是否一致
        if entry.NStage == NStage
            % 判断Mem_Area长度是否一致
            if length(entry.Mem_Area) == length(Mem_Area)
                % 判断参数是否完全相同
                if isequal(entry.Mem_Area, Mem_Area) && ...
                   entry.P_feed == P_feed && ...
                   entry.P_perm == P_perm
                    % 找到缓存
                    result = entry.Result;
                    fprintf('✅ 缓存命中: NStage=%d\n', NStage);
                    return;
                end
            end
        end
    end
end
