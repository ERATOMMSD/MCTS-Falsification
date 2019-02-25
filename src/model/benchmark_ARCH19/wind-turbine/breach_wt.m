clear;


SimplifiedTurbine_Config;
addpath('tools/')
addpath('wind/')
addpath(config.wafo_path)

load('ClassA.mat')
load('ClassA_config.mat')

load('aeromaps3.mat');
Parameter.InitialConditions = load('InitialConditions');
% remove all unnecessary fields (otherwise Simulink will throw an error)
cT_modelrm = rmfield(cT_model,{'VarNames'});%,'RMSE','ParameterVar','ParameterStd','R2','AdjustedR2'});
cP_modelrm = rmfield(cP_model,{'VarNames'});%,'RMSE','ParameterVar','ParameterStd','R2','AdjustedR2'});

% initialize WAFO
initwafo 

iBin = find(URefVector==Parameter.URef);
iRandSeed = 1;

config.iBin                         = iBin;
config.iRandSeed                    = iRandSeed;
Parameter.v0                        = v0_cell{iBin,iRandSeed};
Parameter.v0.signals.values         = Parameter.v0.signals.values';
Parameter.TMax                      = v0_cell{iBin,iRandSeed}.time(end);
config.WindFieldName                = FileNames{iBin,iRandSeed};
% Time
Parameter.Time.TMax                 = 630;              % [s]       duration of simulation
Parameter.Time.dt                   = 0.01;           % [s]       time step of simulation
Parameter.Time.cut_in               = 30;
Parameter.Time.cut_out              = Parameter.Time.TMax;
Parameter.v0_0 = Parameter.v0.signals.values(1);

Parameter = SimplifiedTurbine_ParamterFile(Parameter);

InitBreach;


mdl = 'SimplifiedWTModelFALS';
Br = BreachSimulinkSystem(mdl);


%Br.Sys.tspan = 0:.001: 1;

input_gen.type = 'UniStep';
input_gen.cp = input('\n Please input control points\n');
Br.SetInputGen(input_gen);

for cpi = 0:input_gen.cp-1
    ws_sig = strcat('In1_u', num2str(cpi));
    Br.SetParamRanges({ws_sig},[15.0 16.0]);
end

phi1 = STL_Formula('phi1','always_[30, 630] Out6 <= 14.2');

phi_in = '\n Please input which property? \n';
phi_input = input(phi_in);
phi = eval(strcat('phi', num2str(phi_input)));


BreachProblem.list_solvers();
solver_input = input('\n Please input a solver:\n', 's');
IterNum = input('\n Please input the number of trials:\n');

total_time = 0.0;
succ_iter = 0;
succ_trial = 0;
%obj_best = [];
%num_sim = [];

for n = 0:IterNum-1
    
    falsif_pb = FalsificationProblem(Br, phi);
    falsif_pb.max_time = 600;
    %falsif_pb.max_obj_eval = 20;
    falsif_pb.setup_solver(solver_input);
    falsif_pb.solve();
    
    
    if falsif_pb.obj_best < 0
       total_time = total_time + falsif_pb.time_spent;
       succ_iter = succ_iter + falsif_pb.nb_obj_eval;
       succ_trial = succ_trial + 1; 
    end
    %obj_best = [obj_best; falsif_pb.obj_best]
    %num_sim = [num_sim; falsif_pb.nb_obj_eval]
    
end

aver_time = total_time/succ_trial
aver_succ_iter = succ_iter/succ_trial
succ_trial
