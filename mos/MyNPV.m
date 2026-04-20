function y = MyNPV(x)
format long g
%% 渗透侧程序嵌入
J1 = 350 * 3.35 * 10^(-10) * 3600; % 渗透率 kmol/(m2·h·kPa) C3H6
S12 = 40; %选择性
A = 7000; %膜面积 m2
f_feed = 479; %进料量 kmol/h
P_feed = 800; %初始压力 kPa
y_feed1 = 0.9; %初始A组分进料 C3H6
y_feed2 = 0.1; %初始B组分进料 C3H8
N = 200; %切割单元数

[f_c3h6_resd, f_c3h8_resd] = Mem_Sep1(J1, S12, A, f_feed, P_feed, y_feed1, y_feed2, N)

%%
hysys = hyconnect;                                         % Create a connection to Hysys.
spreada = hyspread(hysys, 'Stream 1 composition');         % Create a connection to a spreadsheet.
d = hycell(spreada, {'b1'});                              % Connect to the cells in the spreadsheet. 
hyset(d(1),x(1));                                          % Change the value

while hyissolving(hysys)==1                                % Check if the solver is running.
end

% 导出基础数据
spreadb = hyspread(hysys, 'Stream 1 composition');                    % Create a connection to a spreadsheet.
m = hycell(spreadb, {'e8','i8','k8','i3','i4'});                     % Connect to the cells  in the spreadsheet.
nsr = hyvalue(m);
D = nsr(1)
NinW = nsr(2)
iinW = nsr(3)
CW = nsr(4)
LP = nsr(5)


