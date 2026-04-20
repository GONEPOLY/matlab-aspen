
function [f_c3h6_resd, f_c3h8_resd, f_c3h6_perm, f_c3h8_perm, P_resdN] = Solve_Mem_Op(J, S, A_in, f_feed_in, P_feed_in, y_feed1_in, y_feed2_in, N1)
Index    = 37;
Addindex = 1;
T       = 54.5 + 273.15;
N       = N1; %ÇĞ¸îµ¥ÔªÊı
J1      = J * 3.35 * 10^(-10) * 3600; % kmol/(m2¡h¡kPa) C3H6

S12     = S; %Ñ¡ÔñĞÔ
J2      = J1 / S12;
J       = [J1, J2]; %ÉøÍ¸ÂÊ kmol/(m2¡¤h¡¤kPa)

% Area    = 9000:100:10000; %Ä¤Ãæ»ı m2 
A       = A_in;
dA      = A / N;  
f_feed  = f_feed_in; %½øÁÏÁ¿ kmol/h
P_feed  = P_feed_in;%³õÊ¼Ñ¹Á¦ kPa
y_feed1 = y_feed1_in; %³õÊ¼A×é·Ö½øÁÏ C3H6
y_feed2 = y_feed2_in; %³õÊ¼B×é·Ö½øÁÏ C3H8
y1      = zeros(1, N); %Éè¶¨A×é·ÖÄ¦¶ûº¬Á¿³õÖµ 
y2      = 1 - y1; %%Éè¶¨B×é·ÖÄ¦¶ûº¬Á¿³õÖµ B×é·ÖÄ¦¶


f_resd    = zeros(1, N); %ÉøÓà²àÁ÷Á¿
f_resd_0  = f_feed;
f_perm    = zeros(1, N);
f_perm_accumulative1 = zeros(1, N);
f_perm_accumulative2 = zeros(1, N);

f_perm_accumulative = zeros(1, N);
P_resd    = zeros(1, N); %ÉøÓà²àÑ¹Á¦
P_perm    = zeros(1, N);
P_perm_0  = 1;
P_resd_0  = P_feed;

f_perm1   = zeros(1, N); %A×é·ÖÉøÍ¸²àÁ÷Á¿
f_perm2   = zeros(1, N); %B×é·ÖÉøÍ¸²àÁ÷Á¿
y_resd1   = zeros(1, N);
y_resd2   = zeros(1, N);
y_perm1   = zeros(1, N);
y_perm2   = zeros(1, N);


%  for  Get_area = 1:length(Area)
     
%             A      = Area(Get_area);
        
           
  
   for k = 1 : N 
      if k == 1
        f_resd(k)  = f_feed;
        y_resd1(k) = y_feed1;
        y_resd2(k) = 1 - y_resd1(k);
        P_resd(k)  = P_feed;
        f_perm1(k) = J(1) * dA * (y_resd1(k)*P_resd_0 - P_perm_0);
        f_perm2(k) = J(2) * dA * (y_resd2(k)*P_resd_0 - P_perm_0);
        f_perm(k)  = f_perm1(k) + f_perm2(k);
     
       
        f_perm_accumulative1(k) = f_perm1(k);
        f_perm_accumulative2(k) = f_perm2(k);
        f_perm_accumulative(k)  = f_perm(k);
        y_perm1(k)              = f_perm_accumulative1(k)/f_perm_accumulative(k);
        y_perm2(k)              = f_perm_accumulative2(k)/f_perm_accumulative(k);
        
        
        
    else
        f_resd(k)  =  f_resd(k-1) - (f_perm1(k-1) + f_perm2(k-1));
        y_resd1(k) = (f_resd(k-1)*y_resd1(k-1)-f_perm1(k-1))/f_resd(k); 
        y_resd2(k) = (f_resd(k-1)*y_resd2(k-1)-f_perm2(k-1))/f_resd(k);
        P_resd(k)  = PR([y_resd1(k), y_resd2(k)] , f_resd(k), T, P_resd_0, f_resd_0, [y_feed1, y_feed2]);
        P_perm(k)  = PR([y_resd1(k), y_resd2(k)] , f_perm(k-1), T, P_resd_0, f_resd_0, [y_feed1, y_feed2]); %%accu_calpres
        
      
        
        f_perm1(k) = J(1) * dA * (y_resd1(k)*P_resd(k) - y_perm1(k-1)*P_perm(k-1));%%- y_perm1(k-1)*P_perm(k-1)
        f_perm2(k) = J(2) * dA * (y_resd2(k)*P_resd(k) - y_perm2(k-1)*P_perm(k-1));%%- y_perm2(k-1)*P_perm(k-1)
        
        f_perm(k)  = f_perm1(k) + f_perm2(k);
 
       
        
        f_perm_accumulative1(k) = f_perm_accumulative1(k-1) + f_perm1(k);
        f_perm_accumulative2(k) = f_perm_accumulative2(k-1) + f_perm2(k);
        f_perm_accumulative(k)  = f_perm_accumulative(k-1)  + f_perm(k);
%         P_resd(k)               = PR([y_resd1(k), y_resd2(k)] , f_resd(k), T, P_resd_0, f_resd_0, [y_feed1, y_feed2]);
%         P_perm(k)               = PR([y_resd1(k), y_resd2(k)] , f_perm(k), T, P_resd_0, f_resd_0, [y_feed1, y_feed2]); %%accu_calpres
        
        y_perm1(k)              = f_perm_accumulative1(k)/f_perm_accumulative(k);
        y_perm2(k)              = f_perm_accumulative2(k)/f_perm_accumulative(k);
      
      end
       
           
       
 end

%   fperm1        =  f_perm_accumulative1(N);
%   fperm2        =  f_perm_accumulative2(N);
%   fperm         =  fperm1 + fperm2;
%   R             =  f_feed - fperm - f_resd(k);
%   Rec_C3H6      =  f_perm_accumulative1(N)/(f_feed * y_feed1);
%   Rec_C3H8      =  (f_resd(k) * y_resd2(k))/(f_feed * y_feed2);
%   y_resd1_out   =  100*y_resd1(N);
%   f_resd_out    =  f_resd(N);    
%   P_resd_out    =  P_resd(N); 
% %   C_PERM_py     =  100*fperm1/fperm;
% %   Recovery_C3H6 =  100*fperm1/(y_feed1*f_feed);
%   fresd1        =  y_resd1(N)*f_resd_out;
%   fresd2        =  f_resd_out-fresd1;
%   P_resd_py     =  P_resd_out*y_resd1(N);
%   P_resd_pa     =  P_resd_out-P_resd_py;
  f_c3h6_resd = f_resd(N) * y_resd1(N);
  f_c3h8_resd = f_resd(N) * y_resd2(N);

  f_c3h6_perm = sum(f_perm1);
  f_c3h8_perm = sum(f_perm2);

  P_resdN = P_resd(N);  
%   Outputdata    =  [fperm,C_PERM_py,fperm1,fperm2,fresd1,fresd2,f_resd_out,y_resd1_out,P_resd_py,P_resd_pa,P_resd_out,Recovery_C3H6];
% %   xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Feed10M_Downstream_Pressure.xlsx', Outputdata, 2, ['D',num2str(Index),':O',num2str(Index)]);
%   xlswrite('C:\Users\chang\OneDrive\Documents\Graduate level documents\Master thesis\gnh use\Membrane data reset pro',Outputdata,1,['D',num2str(Index),':N',num2str(Index)]);   
% % ['F',num2str(Index),':S',num2str(Index)]
  Index = Index + Addindex;
end
