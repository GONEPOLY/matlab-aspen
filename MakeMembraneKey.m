function indexKey = MakeMembraneKey(Mem_Area, Upstream_P, Downstream_P, NStage)
                        indexKey = sprintf('Area%s_Up%.2f_Down%.2f_Stage%d', ...
                        strjoin(string(Mem_Area), '-'), Upstream_P, Downstream_P, NStage);
end