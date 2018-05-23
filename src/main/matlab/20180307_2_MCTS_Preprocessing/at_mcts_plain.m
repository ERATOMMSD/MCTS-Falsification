InitBreach;


mdl = 'Autotrans_shift';
        
Br = BreachSimulinkSystem(mdl);
br = Br.copy();

budget = 2;
scalar = 0.5;
phi = STL_Formula('phi1','alw_[0,30] (speed[t] < 200)');
%phi = STL_Formula('phi4','not alw_[10,30](50 < speed[t] and speed[t] < 60)');
%phi = STL_Formula('phi5','alw_[0,10](speed[t]<50) or ev_[0,30](RPM[t] > 2520)');
T = 30;
ts = 5;
solver = 'cmaes';
time_out = 2;

input_name = {'throttle','brake'};
input_range = [[0 100];[0 325]];
total_range = [1 1];

tic
count = 0;
trials = 1;
for i = 1:trials
    
    m = MCTS(br, budget, scalar, phi, T, ts, solver, time_out, input_name, input_range, total_range);
    count = count+m.falsified;
end
time = toc;
av_time = time/trials;



t = table(scalar, time_out, budget, time, av_time, count, trials);
