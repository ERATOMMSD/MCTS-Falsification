clear;
%addpath(genpath('/Users/zhenya/tools/brea'))
InitBreach;
mdl = 'steamcondense_RNN_22';
Br = BreachSimulinkSystem(mdl);

Br.Sys.tspan = 0:.01:35;

input_gen.type = 'UniStep';
input_gen.cp = input('\n Please input control points\n');
Br.SetInputGen(input_gen);

for cpi = 0:input_gen.cp-1
    in1_sig = strcat('Input_u', num2str(cpi));
    %brake_sig = strcat('_u', num2str(cpi));
    Br.SetParamRanges({in1_sig},[3.99 4.01]);
    %Br.SetParamRanges({brake_sig},[0 325]);
end

phi = STL_Formula('phi1','alw_[30 35] (Out4[t]>=87 and Out4[t] <=87.5)');

falsif_pb = FalsificationProblem(Br, phi);
falsif_pb.max_time = 60;
%falsif_pb.max_obj_eval = 100;
falsif_pb.setup_solver('cmaes');
falsif_pb.solve();






