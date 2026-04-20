function writeCache(cacheFile, NStage, Mem_Area, P_feed, P_perm, Result)
    % 将新的结果写入缓存文件
    % 如果已存在同样的参数，不会重复写入

    % 如果存在就加载，否则新建
    if isfile(cacheFile)
        load(cacheFile, 'cacheData');
    else
        cacheData = [];
    end

    % 检查是否已存在相同记录
    for i = 1:numel(cacheData)
        entry = cacheData(i);
        if entry.NStage == NStage && ...
           isequal(entry.Mem_Area, Mem_Area) && ...
           entry.P_feed == P_feed && ...
           entry.P_perm == P_perm
            fprintf('⚠️ 已存在相同参数记录，不重复写入\n');
            return;
        end
    end

    % 新增条目
    newEntry = struct('NStage', NStage, ...
                      'Mem_Area', Mem_Area, ...
                      'P_feed', P_feed, ...
                      'P_perm', P_perm, ...
                      'Result', Result);

    cacheData = [cacheData; newEntry]; %#ok<AGROW>

    % 保存
    save(cacheFile, 'cacheData');
    fprintf('💾 已写入缓存: NStage=%d\n', NStage);
end
