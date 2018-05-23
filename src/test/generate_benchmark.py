import sys
import os

model = ''
algorithm = '' 
optimization = []
phi_str = []
controlpoints = []
scalar = []
partitions = []
T_playout = []
N_max = []
input_name = []
input_range = []

status = 0
arg = ''
linenum = 0
timespan = ''
parameters = []
T = ''
loadfile = ''
addpath = []

trials = 10
fal_home = os.environ['FALHOME']

with open('./'+sys.argv[1],'r') as conf:
    for line in conf.readlines():
        argu = line.strip().split()
	if status == 0:
	    status = 1
	    arg = argu[0]
	    linenum = int(argu[1])
	elif status == 1:
	    linenum = linenum - 1
	    if arg == 'model':
		model = argu[0]

            elif arg == 'optimization':
		optimization.append(argu[0])
            elif arg == 'phi':
		complete_phi = argu[0]+';'+argu[1]
		for a in argu[2:]:
		    complete_phi = complete_phi + ' '+ a
		phi_str.append(complete_phi)
            elif arg == 'controlpoints':
		controlpoints.append(int(argu[0]))
            elif arg == 'scalar':
		scalar.append(float(argu[0]))
            elif arg == 'partitions':
		partitions.append([int(argu[0]),int(argu[1])])
            elif arg == 'T_playout':
		T_playout.append(int(argu[0]))
            elif arg == 'N_max':
		N_max.append(int(argu[0]))
	    elif arg == 'input_name':
		input_name.append(argu[0])
	    elif arg == 'input_range':
		input_range.append([float(argu[0]),float(argu[1])])
	    elif arg == 'algorithm':
		algorithm = argu[0]
	    elif arg == 'timespan':
		timespan = argu[0]
	    elif arg == 'parameters':
		parameters.append(argu[0])
	    elif arg == 'T':
		T = argu[0]
	    elif arg == 'loadfile':
		loadfile = argu[0]
	    elif arg == 'addpath':
		addpath.append(fal_home + argu[0])
	    else:
		continue
	    if linenum == 0:
		status = 0


for ph in phi_str:
    for cp in controlpoints:
        for c in scalar:
            for par in partitions:
                for nm in N_max:
                    for opt in optimization:
                        for tp in T_playout:
			    property = ph.split(';')
			    par_str = '_'.join(str(i) for i in par)
                            filename = algorithm + '_'+property[0]+'_' + str(cp) + '_' + str(c) + '_'+par_str+'_'+str(nm)+'_' + opt + '_' + str(tp)
			    param = '\n'.join(parameters)
                            with open('../benchmarks/'+filename,'w') as bm:
                                bm.write('#!/bin/sh\n')
                                bm.write('csv=$1\n')
                                bm.write('matlab -nodesktop -nosplash <<EOF\n')
                                bm.write('clear;\n')
				for ap in addpath: 
                                    bm.write('addpath '+ ap +'\n')
				if loadfile!='':
				    bm.write('load '+loadfile + '\n')
                                bm.write('InitFalsification;\n')
                                bm.write('InitBreach;\n\n')
				bm.write(param+ '\n')
                                bm.write('mdl = \''+ model + '\';\n')
                                bm.write('Br = BreachSimulinkSystem(mdl);\n')
                                bm.write('br = Br.copy();\n')
   				bm.write('N_max =' + str(nm)  + ';\n')
				bm.write('scalar = '+ str(c) +';\n')
				bm.write('phi_str = \''+ property[1] +'\';\n')
				bm.write('phi = STL_Formula(\'phi1\',phi_str);\n') 
           			bm.write('T = ' + T + ';\n')
				bm.write('controlpoints = '+ str(cp)+ ';\n')
 				bm.write('hill_climbing_by = \''+ opt+'\';\n')
				bm.write('T_playout = '+str(tp)+';\n')
				bm.write('input_name = {\''+input_name[0]+'\'')
				for inm in input_name[1:]:
				    bm.write(',\'')
				    bm.write(inm)
				    bm.write('\'')
				bm.write('};\n')
 				bm.write('input_range = [['+ str(input_range[0][0])+' '+str(input_range[0][1])+']')
				for ir in input_range[1:]:
				    bm.write(';[')
				    bm.write(str(ir[0])+' '+str(ir[1]))
				    bm.write(']')
				bm.write('];\n')
				bm.write('partitions = ['+ str(par[0]))
		    		for p in par[1:]:
				    bm.write(' ')
				    bm.write(str(p))
				bm.write('];\n')

				bm.write('filename = \''+filename+'\';\n')
				bm.write('algorithm = \''+algorithm+ '\';\n')
				bm.write('falsified_at_all = [];\n')
				bm.write('total_time = [];\n')
				bm.write('falsified_in_preprocessing = [];\n')
				bm.write('time_for_preprocessing = [];\n')
				bm.write('falsified_after_preprocessing = [];\n')
				bm.write('time_for_postpreprocessing = [];\n')
				bm.write('trials = 10;\n')
				bm.write('for i = 1:trials\n')
				bm.write('\t tic\n')
				bm.write('\t m = MCTS(br, N_max, scalar, phi, T, controlpoints, hill_climbing_by, T_playout, input_name, input_range, partitions);\n')
				bm.write('\t falsified_in_preprocessing = [falsified_in_preprocessing; m.falsified];\n')
				bm.write('\t time = toc;\n')
				bm.write('\t time_for_preprocessing = [time_for_preprocessing; time];\n')
				bm.write('\t if m.falsified == 0\n')
				bm.write('\t\t BR = Br.copy();\n')
				bm.write('\t\t BR.Sys.tspan = '+ timespan +';\n')
				bm.write('\t\t input_gen.type = \'UniStep\';\n')
				bm.write('\t\t input_gen.cp = controlpoints;\n')
				bm.write('\t\t BR.SetInputGen(input_gen);\n')
				bm.write('\t\t range = m.best_children_range;\n')
				bm.write('\t\t r = numel(range);\n')
				bm.write('\t\t for cpi = 1:controlpoints\n')
				bm.write('\t\t\t for k = 1:numel(input_name)\n')
				bm.write('\t\t\t\t sig_name = strcat(input_name(k), \'_u\', num2str(cpi-1));\n')
				bm.write('\t\t\t\t if cpi <= r\n')
				bm.write('\t\t\t\t\t BR.SetParamRanges({sig_name},range(cpi).get_signal(k));\n')
				bm.write('\t\t\t\t else\n')
				bm.write('\t\t\t\t\t BR.SetParamRanges({sig_name},input_range(k,:));\n')
				bm.write('\t\t\t\t end\n')
				bm.write('\t\t\t end\n')
				bm.write('\t\t end\n')
				bm.write('\t\t falsif_pb = FalsificationProblem(BR, phi);\n')
				bm.write('\t\t falsif_pb.max_time = 300;\n')
				bm.write('\t\t falsif_pb.setup_solver(\'cmaes\');\n')
				bm.write('\t\t falsif_pb.solve();\n')
				bm.write('\t\t if falsif_pb.obj_best < 0\n')
				bm.write('\t\t\t time_for_postpreprocessing = [time_for_postpreprocessing; falsif_pb.time_spent];\n')
				bm.write('\t\t\t falsified_after_preprocessing = [falsified_after_preprocessing; 1];\n')
				bm.write('\t\t else\n')
				bm.write('\t\t\t time_for_postpreprocessing = [time_for_postpreprocessing; falsif_pb.time_spent];\n')
				bm.write('\t\t\t falsified_after_preprocessing = [falsified_after_preprocessing;0];\n')
				bm.write('\t\t end\n')
				bm.write('\t else\n')
				bm.write('\t\t falsified_after_preprocessing = [falsified_after_preprocessing; 1];\n')
				bm.write('\t\t time_for_postpreprocessing = [time_for_postpreprocessing; 0];\n')
				bm.write('\t end\n')
				bm.write('end\n')
				bm.write('falsified_at_all = falsified_after_preprocessing;\n')
				bm.write('total_time = time_for_preprocessing + time_for_postpreprocessing;\n')
				bm.write('phi_str = {phi_str')
				for j in range(1,trials):
				    bm.write(';phi_str')
				bm.write('};\n')
				bm.write('algorithm = {algorithm')
                                for j in range(1,trials):
                                    bm.write(';algorithm')
                                bm.write('};\n')
				bm.write('hill_climbing_by = {hill_climbing_by')
                                for j in range(1,trials):
                                    bm.write(';hill_climbing_by')
                                bm.write('};\n')
				bm.write('filename = {filename')
                                for j in range(1,trials):
                                    bm.write(';filename')
                                bm.write('};\n')
				bm.write('controlpoints = controlpoints*ones(trials,1);\n')
				bm.write('scalar = scalar*ones(trials,1);\n')
				bm.write('partitions = [partitions(1)*ones(trials,1) partitions(2)*ones(trials,1)];\n') #not generalized
				bm.write('T_playout = T_playout*ones(trials,1);\n')
				bm.write('N_max = N_max*ones(trials,1);\n')
				bm.write('result = table(filename, phi_str, algorithm, hill_climbing_by, controlpoints, scalar, partitions, T_playout, N_max, falsified_at_all, total_time, falsified_in_preprocessing, time_for_preprocessing, falsified_after_preprocessing, time_for_postpreprocessing);\n')
				bm.write('writetable(result,\'$csv\',\'Delimiter\',\';\');\n')
				bm.write('quit\n')
				bm.write('EOF\n')
