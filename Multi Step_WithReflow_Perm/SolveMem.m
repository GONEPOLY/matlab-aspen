function [f_c3h6_resd, f_c3h8_resd, f_c3h6_perm, f_c3h8_perm, P_resdN] = SolveMem(J, S, A_in, f_feed_in, P_feed_in, y_feed1_in, y_feed2_in, N1, t_feed)
% clear
%% 初值设定
T = t_feed + 273.15;
N = N1; %切割单元数
J1 = J * 3.35 * 10^(-10) * 3600; % 渗透率 kmol/(m2·h·kPa) C3H6
S12 = S; %选择性
J2 = J1 / S12;
J = [J1, J2]; %渗透率 kmol/(m2·h·kPa)
A = A_in; %膜面积 m2
dA = A / N;
f_feed =  f_feed_in; %进料量 kmol/h
P_feed = P_feed_in; %初始压力 kPa
y_feed1 = y_feed1_in; %初始A组分进料 C3H6
y_feed2 = y_feed2_in; %初始B组分进料 C3H8
y1 = zeros(1, N); %设定A组分摩尔含量初值 
y2 = 1 - y1; %%设定B组分摩尔含量初值 

%% 赋值
y_resd1 = zeros(1, N); % 渗余侧A组分摩尔含量
y_resd1_0 = y_feed1;
y_resd2 = zeros(1, N); % 渗余侧B组分摩尔含量
y_resd2_0 = y_feed2;
y_resd_0 = [y_resd1_0, y_resd2_0]; % 渗余侧各组分初始含量

f_resd = zeros(1, N); % 渗余侧流量
f_resd_0 = f_feed;

P_resd = zeros(1, N); %渗余侧压力
P_resd_0 = P_feed;

f_perm1 = zeros(1, N); % A组分渗透侧流量
f_perm2 = zeros(1, N); % B组分渗透侧流量

y_perm1 = zeros(1, N); % A组分渗透侧含量
y_perm2 = zeros(1, N); % B组分渗透侧含量

m1 = zeros(1, N);
n1 = zeros(1, N);
m2 = zeros(1, N);
n2 = zeros(1, N);


%% 计算
for k = 1 : N 
    if k == 1
        d = 1;
        y_resd1(k) = y_resd1_0;
        while d > 0.0001   
            y_resd1(k) = y_resd1(k) - 0.00001; 
            y_resd2(k) = 1 - y_resd1(k);
            % A组分求解
            A1 = @(x) f_resd_0 * y_resd1_0 - x * y_resd1(k);
            B1 = @(x) J(1) * dA * (P_resd_0 - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0]))* (y_resd1_0 - y_resd1(k)) / log(P_resd_0 / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0])) / log(y_resd1_0 / y_resd1(k));
            x1 = fsolve(@(x) A1(x)-B1(x), 80);
            % B组分求解
            A2 = @(x) f_resd_0 * y_resd2_0 - x * y_resd2(k);
            B2 = @(x) J(2) * dA  * (P_resd_0 - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0]))* (y_resd2_0 - y_resd2(k)) / log(P_resd_0 / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0])) / log(y_resd2_0 / y_resd2(k));
            x2 = fsolve(@(x) A2(x)-B2(x), 80);
            d = abs((x1 - x2) / x1);
            % 为下一单元赋值
            f_resd(k) = x2;
            P_resd(k) = PR([y_resd1(k), y_resd2(k)] , x2, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0]);
            % 求解渗透侧
            m1(k) = f_resd(k) * y_resd1(k);
            n1(k) = f_resd_0 * y_resd1_0;
            f_perm1(k) = n1(k) - m1(k);
            m2(k) = f_resd(k) * y_resd2(k);
            n2(k) = f_resd_0 * y_resd2_0;
            f_perm2(k) = n2(k) - m2(k);
            y_perm1(k) = f_perm1(k) / (f_perm1(k) + f_perm2(k));
            y_perm2(k) = f_perm2(k) / (f_perm1(k) + f_perm2(k));
        end
        
    else
        dd = 1;
        y_resd1(k) = y_resd1(k-1);
        x_last     = f_resd(k-1);
        while dd > 0.0001
            y_resd1(k) = y_resd1(k) - 0.00001; 
            y_resd2(k) = 1 - y_resd1(k);
            % A组分求解
            A1 = @(x) f_resd(k - 1) * y_resd1(k - 1) - x * y_resd1(k);
            B1 = @(x) J(1) * dA * (P_resd(k - 1) - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0])) * (y_resd1(k - 1) - y_resd1(k)) / log(P_resd(k - 1) / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0])) / log(y_resd1(k - 1) / y_resd1(k));
            x1 = fsolve(@(x) A1(x)-B1(x), x_last);
            % B组分求解
            A2 = @(x) f_resd(k - 1) * y_resd2(k - 1) - x * y_resd2(k);
            B2 = @(x) J(2) * dA  * (P_resd(k - 1) - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0])) * (y_resd2(k - 1) - y_resd2(k)) / log(P_resd(k - 1) / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0])) / log(y_resd2(k - 1) / y_resd2(k));
            x2 = fsolve(@(x) A2(x)-B2(x), x_last);
            dd = abs((x1 - x2) / x1);
            % 为下一单元赋值
            f_resd(k) = x2;
            
            P_resd(k) = PR([y_resd1(k), y_resd2(k)] , x2, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd1_0]);
            % 求解渗透侧
            m1(k) = f_resd(k) * y_resd1(k);
            n1(k) = f_resd(k - 1) * y_resd1(k - 1);
            f_perm1(k) = n1(k) - m1(k);
            m2(k) = f_resd(k) * y_resd2(k);
            n2(k) = f_resd(k - 1) * y_resd2(k - 1);
            f_perm2(k) = n2(k) - m2(k);
            y_perm1(k) = f_perm1(k) / (f_perm1(k) + f_perm2(k));
            y_perm2(k) = f_perm2(k) / (f_perm1(k) + f_perm2(k));
        end
        x_last    = x2;
    end
%     ff(k) = f_perm1(k) + f_perm2(k);
end
% fresd_N = f_resd(N);
% fresd1 = fresd_N * y_resd1(N);
% fresd2 = fresd_N * y_resd2(N);
% 
% fperm1 = sum(f_perm1);
% fperm2 = sum(f_perm2);

% P1 = P_resd(N) * y_resd1(N);
% P2 = P_resd(N) * y_resd2(N); 
 
% fperm = fperm1 + fperm2;
% R = f_feed - fperm - f_resd(k);
% yyy = fperm1 / fperm;
% %% 回收率
% Rec_C3H6 =  fperm1 / (f_feed * y_feed1);
% Rec_C3H8 =  (f_resd(k) * y_resd2(k)) / (f_feed * y_feed2);
 %% Value output set
f_c3h6_resd = f_resd(N) * y_resd1(N);
f_c3h8_resd = f_resd(N) * y_resd2(N);

f_c3h6_perm = sum(f_perm1);
f_c3h8_perm = sum(f_perm2);

P_resdN = P_resd(N);   
end   
    
    
    
    


    

    

