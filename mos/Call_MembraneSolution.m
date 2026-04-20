 function Membrane_parameter = Call_MembraneSolution(J1, S12, A, f_feed, P_feed, y_feed1, N)
    y_feed2=1-y_feed1;
    [f_c3h6_resd, f_c3h8_resd, f_c3h6_perm, f_c3h8_perm, P_resdN] =  Solve_Mem_Op(J1, S12, A, f_feed, P_feed, y_feed1, y_feed2, N);
    f_resd = f_c3h6_resd + f_c3h8_resd;                             % 渗余侧组分流量kmol/h
    f_perm_sum = f_c3h6_perm + f_c3h8_perm;
    FracP_py = f_c3h6_perm/(f_c3h6_perm + f_c3h8_perm) ;
    FracP_pa = 1 - FracP_py;
    FracR_py = f_c3h6_resd/(f_c3h6_resd + f_c3h8_resd );
    FracR_pa = 1-FracR_py;
    t_feed = 54.5;
    Membrane_parameter = [f_resd , f_perm_sum , FracP_py ,FracP_pa ,P_resdN , FracR_py , FracR_pa , t_feed];
    end