% clear%% ≥ı÷µ…Ë∂®
% RT1=1;
% while RT1<=7 
function [f_c3h6_resd, f_c3h8_resd, f_c3h6_perm, f_c3h8_perm, P_resdN] = test06five1(J1_port, S12_port, A_port, f_feed_port, P_feed_port, y_feed1_port, y_feed2_port, N_port, t_feed)
%     S=[30 25 20 15 10 5 2];
    
T = t_feed + 273.15;
% N = 200; %«–∏Óµ•‘™ ˝
J1 =J1_port * 3.35 * 10^(-10) * 3600; % …¯Õ∏¬  kmol/(m2°§h°§kPa) C3H6
S12 = S12_port; %—°‘Ò–‘
J2 = J1 / S12;
J = [J1, J2]; %…¯Õ∏¬  kmol/(m2°§h°§kPa)
A =  A_port; %ƒ§√Êª˝ m2
N =  N_port;
dA = A / N;
f_feed = f_feed_port; %Ω¯¡œ¡ø kmol/h
P_feed = P_feed_port; %≥ı º—π¡¶ kPa
y_feed1 = y_feed1_port; %≥ı ºA◊È∑÷Ω¯¡œ C3H6 y_feed1_port, y_feed2_port,
y_feed2 = y_feed2_port; %≥ı ºB◊È∑÷Ω¯¡œ C3H8
y1 = zeros(1, N); %…Ë∂®A◊È∑÷ƒ¶∂˚∫¨¡ø≥ı÷µ 
y2 = 1 - y1; %%…Ë∂®B◊È∑÷ƒ¶∂˚∫¨¡ø≥ı÷µ B◊È∑÷ƒ¶∂

%% ∏≥÷µ y_feed1_port, y_feed2_port
y_resd1 = []; %…¯”‡≤‡A◊È∑÷ƒ¶∂˚∫¨¡ø
y_resd1 = y1;
y_resd1_0 = y_feed1;

y_resd2 = []; %…¯”‡≤‡B◊È∑÷ƒ¶∂˚∫¨¡ø
y_resd2 = y2;
y_resd2_0 = y_feed2;

f_resd = []; %…¯”‡≤‡¡˜¡ø
f_resd_0 = f_feed;

P_resd = []; %…¯”‡≤‡—π¡¶
P_resd_0 = P_feed;

f_perm1 = []; %A◊È∑÷…¯Õ∏≤‡¡˜¡ø
f_perm2 = []; %B◊È∑÷…¯Õ∏≤‡¡˜¡ø

y_perm1 = [];
y_perm2 = [];

m1 = [];
n1 = [];
m2 = [];
n2 = [];

%% º∆À„
for k = 1 : N 
    if k == 1
        d = 1;
        y_resd1(k) = y_resd1_0;
        while d > 0.0001  
            y_resd1(k) = y_resd1(k) - 0.000001; 
            y_resd2(k) = 1 - y_resd1(k);
            % A◊È∑÷«ÛΩ‚
            A1 = @(x) f_resd_0 * y_resd1_0 - x * y_resd1(k);
            B1 = @(x) J(1) * dA * (P_resd_0 - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0]))* (y_resd1_0 - y_resd1(k)) / log(P_resd_0 / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0])) / log(y_resd1_0 / y_resd1(k));
            x1 = fsolve(@(x) A1(x)-B1(x), 100);
            % B◊È∑÷«ÛΩ‚
            A2 = @(x) f_resd_0 * y_resd2_0 - x * y_resd2(k);
            B2 = @(x) J(2) * dA * (P_resd_0 - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0]))* (y_resd2_0 - y_resd2(k)) / log(P_resd_0 / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0])) / log(y_resd2_0 / y_resd2(k));
            x2 = fsolve(@(x) A2(x)-B2(x), 100);
            d = abs((x1 - x2) / x1);
            % Œ™œ¬“ªµ•‘™∏≥÷µ
            f_resd(k) = x2;
            P_resd(k) = PR([y_resd1(k), y_resd2(k)] , x2, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0]);
            % «ÛΩ‚…¯Õ∏≤‡
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
        ddpre=1;
        y_resd1(k) = y_resd1(k-1);
%         dy=(y_resd1(k)-y_resd1(k-1))/10;
        dy=0.000001;
        t=1;
        while dd > 0.0001
            y_resd1(k) = y_resd1(k) - dy; 
            y_resd2(k) = 1 - y_resd1(k);
            % A◊È∑÷«ÛΩ‚
            A1 = @(x) f_resd(k - 1) * y_resd1(k - 1) - x * y_resd1(k);
            B1 = @(x) J(1) * dA * (P_resd(k - 1) - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0])) * (y_resd1(k - 1) - y_resd1(k)) / log(P_resd(k - 1) / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0])) / log(y_resd1(k - 1) / y_resd1(k));
            x1 = fsolve(@(x) A1(x)-B1(x), 100);
            % B◊È∑÷«ÛΩ‚
            A2 = @(x) f_resd(k - 1) * y_resd2(k - 1) - x * y_resd2(k);
            B2 = @(x) J(2) * dA  * (P_resd(k - 1) - PR([y_resd1(k), y_resd2(k)] , x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0])) * (y_resd2(k - 1) - y_resd2(k)) / log(P_resd(k - 1) / PR([y_resd1(k), y_resd2(k)], x, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0])) / log(y_resd2(k - 1) / y_resd2(k));
            x2 = fsolve(@(x) A2(x)-B2(x), 100);
              dd = abs((x1 - x2) / x1); 
            while t==1
               if k>2
                  if dd < ddpre            
                   
                      dy=dy+0.000001;
                      
                  else
                      y_resd1(k)=y_resd1(k)+dy;
                      dy=0.000001;
                      t=0;
                  end
                 
               end
               break
            end
%                                   
            ddpre=dd;   
            f_resd(k) = x2;
            P_resd(k) = PR([y_resd1(k), y_resd2(k)] , x2, T, P_resd_0, f_resd_0, [y_resd1_0, y_resd2_0]);
            % «ÛΩ‚…¯Õ∏≤‡
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
    ff(k) = f_perm1(k) + f_perm2(k);
end
fperm1 = sum(f_perm1);
fperm2 = sum(f_perm2);
fperm = fperm1 + fperm2;
R = f_feed - fperm - f_resd(k);
%% ªÿ ’¬ 
Rec_C3H6 =  fperm1 / (f_feed * y_feed1);
Rec_C3H8 =  (f_resd(k) * y_resd2(k)) / (f_feed * y_feed2);
y_resd1_out=y_resd1(N);
f_resd_out=f_resd(N);    
P_resd_out=P_resd(N); 
C_PERM_py=fperm1/fperm;
fresd1=y_resd1_out*f_resd_out;
fresd2=f_resd_out-fresd1;
P_resd_py=P_resd_out*y_resd1_out;
P_resd_pa=P_resd_out-P_resd_py;
f_c3h6_resd = f_resd(N) * y_resd1(N);
f_c3h8_resd = f_resd(N) * y_resd2(N);

f_c3h6_perm = sum(f_perm1);
f_c3h8_perm = sum(f_perm2);

P_resdN = P_resd(N);
Outputdata=[fperm,C_PERM_py,fperm1,fperm2,fresd1,fresd2,f_resd_out,y_resd1_out,P_resd_py,P_resd_pa,P_resd_out];
end
% if RT1==1
%  xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\DATA Membrane Mode Calculation 1',Outputdata,'sheet1','D71:N71');
% end
% if RT1==2
%  xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\DATA Membrane Mode Calculation 1',Outputdata,'sheet1','D72:N72');   
% end
% if RT1==3
%  xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\DATA Membrane Mode Calculation 1',Outputdata,'sheet1','D73:N73');   
% end
% if RT1==4
%  xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\DATA Membrane Mode Calculation 1',Outputdata,'sheet1','D74:N74');   
% end
% if RT1==5
%  xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\DATA Membrane Mode Calculation 1',Outputdata,'sheet1','D75:N75');   
% end
% if RT1==6
%  xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\DATA Membrane Mode Calculation 1',Outputdata,'sheet1','D76:N76');   
% end
% if RT1==7
%  xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\DATA Membrane Mode Calculation 1',Outputdata,'sheet1','D77:N77');   
% end
% RT1=RT1+1;


%  