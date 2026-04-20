function A_opt = adjust_area(y_feed, F_feed, perm_coeff, P_feed, P_perm ,A ,A_TES)
    tol = 1e-6;        % 收敛精度
    max_iter = 100;     % 最大迭代次数
    nComp = length(y_feed);
    deltaP = P_feed - P_perm;

    A_max_each = zeros(1,nComp);

    % 对每个组分做二分法，求最大允许膜面积
    for j = 1:nComp
        A_low = 0;
        A_high = A + A_TES;  % 一个足够大的初值
       
   
        for iter = 1:max_iter
            A_mid = 0.5*(A_low + A_high);
            F_perm_j = 3.348e-10 * 3600 * perm_coeff(j) * A_mid * deltaP * y_feed(j)/1000;
         
            if F_perm_j > F_feed * y_feed(j)
                A_high = A_mid;  % 面积太大，缩小
            else
                A_low = A_mid;   % 面积可行，尝试增大
            end
            if abs(A_high - A_low) < tol
                break;
            end
        end
        A_max_each(j) = A_mid;   % 每个组分对应的最大面积
    end
     A_opt = min(A_max_each);
     
   
    
 
end