%% 渗透侧程序嵌入
clc;
J1 = 120 * 3.35 * 10^(-10) * 3600; % 渗透率 kmol/(m2·h·kPa) C3H6
S12 = 50; % 选择性
A = 20; % 膜面积 m2

f_feed = 59.36; % 进料量 kmol/h
P_feed = 800; % 初始压力 kPa
y_feed1 = 0.0002; % 初始A组分进料 C3H6
y_feed2 = 1 - y_feed1; % 初始B组分进料 C3H8
N = 27;% 切割单元数

%%
%% 初值设定
T = 15.93 + 273.15;
J2 = J1 / S12;
J = [J1, J2]; % 渗透率 kmol/(m2·h·kPa)
dA = A / N;

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
        
        while d > 0.0003   
            y_resd1(k) = y_resd1(k) - 0.000000001; 
            y_resd2(k) = 1 - y_resd1(k);
            y_resdi = [y_resd1(k), y_resd2(k)]; % 第 k级渗余侧组分含量
            
            % A组分求解
            A1 = @(x) f_resd_0 * y_resd1_0 - x * y_resd1(k);
            B1 = @(x) J(1) * dA * (P_resd_0 - PR(y_resdi , x, T, P_resd_0, f_resd_0, y_resd_0)) * (y_resd1_0 - y_resd1(k)) / log(P_resd_0 / PR(y_resdi, x, T, P_resd_0, f_resd_0, y_resd_0)) / log(y_resd1_0 / y_resd1(k));
            x1 = fsolve(@(x) A1(x)-B1(x), 50);
            
            % B组分求解
            A2 = @(x) f_resd_0 * y_resd2_0 - x * y_resd2(k);
            B2 = @(x) dA * J(2) * (P_resd_0 - PR(y_resdi, x, T, P_resd_0, f_resd_0, y_resd_0))* (y_resd2_0 - y_resd2(k)) / log(P_resd_0 / PR(y_resdi, x, T, P_resd_0, f_resd_0, y_resd_0)) / log(y_resd2_0 / y_resd2(k));
            x2 = fsolve(@(x) A2(x)-B2(x), 50);
            
            % 回归求解y
            d = abs((x1 - x2) / x1);
            
            % 为下一单元赋值
            f_resd(k) = x2;
            P_resd(k) = PR(y_resdi, x2, T, P_resd_0, f_resd_0, y_resd_0);
            
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
        y_resd1(k) = y_resd1(k - 1);
        while dd > 0.0003
            if k < 70
                y_resd1(k) = y_resd1(k) - 0.00001; 
                y_resd2(k) = 1 - y_resd1(k);
            else
                y_resd1(k) = y_resd1(k) - 0.00001; 
                y_resd2(k) = 1 - y_resd1(k);
            end
            % A组分求解
            A1 = @(x) f_resd(k - 1) * y_resd1(k - 1) - x * y_resd1(k);
            B1 = @(x) J(1) * dA * (P_resd(k - 1) - PR(y_resdi, x, T, P_resd_0, f_resd_0, y_resd_0)) * (y_resd1(k - 1) - y_resd1(k)) / log(P_resd(k - 1) / PR(y_resdi, x, T, P_resd_0, f_resd_0, y_resd_0)) / log(y_resd1(k - 1) / y_resd1(k));
            x1 = fsolve(@(x) A1(x)-B1(x), 100);
            
            % B组分求解
            A2 = @(x) f_resd(k - 1) * y_resd2(k - 1) - x * y_resd2(k);
            B2 = @(x) dA * J(2) * (P_resd(k - 1) - PR(y_resdi, x, T, P_resd_0, f_resd_0, y_resd_0)) * (y_resd2(k - 1) - y_resd2(k)) / log(P_resd(k - 1) / PR(y_resdi, x, T, P_resd_0, f_resd_0, y_resd_0)) / log(y_resd2(k - 1) / y_resd2(k));
            x2 = fsolve(@(x) A2(x)-B2(x), 100);
            dd = abs((x1 - x2) / x1)
            
            % 为下一单元赋值
            f_resd(k) = x2;
            P_resd(k) = PR(y_resdi, x2, T, P_resd_0, f_resd_0, y_resd_0);
            
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
    end
end
f_c3h6_resd = f_resd(N) * y_resd1(N);
f_c3h8_resd = f_resd(N) * y_resd2(N);
y1 = f_c3h6_resd / (f_c3h6_resd + f_c3h8_resd)
ff1 = sum(f_perm1);
ff2 = sum(f_perm2);
yy2 = ff1 / (ff1 + ff2)
fff = ff1 + ff2
