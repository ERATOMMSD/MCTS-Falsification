import sys

model = ''
algorithm = '' 
optimization = []
phi_str = []
controlpoints = []
input_name = []
input_range = []
parameters = []
timespan = ''

status = 0
arg = ''
linenum = 0

algopath = ''
trials = 10

with open('config/'+sys.argv[1],'r') as conf:
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
	    elif arg == 'input_name':
		input_name.append(argu[0])
	    elif arg == 'input_range':
		input_range.append([float(argu[0]),float(argu[1])])
	    elif arg == 'parameters':
		parameters.append(argu[0])	
	    elif arg == 'timespan':
		timespan = argu[0]
	    else:
		continue
	    if linenum == 0:
		status = 0


for ph in phi_str:
    for cp in controlpoints:
        for opt in optimization:
            property = ph.split(';')
            filename = model+ '_breach_' + property[0]+'_' + str(cp)  +'_' + opt 
	    param = '\n'.join(parameters)
            with open('../benchmarks/'+filename,'w') as bm:
                bm.write('#!/bin/sh\n')
                bm.write('csv=$1\n')
                bm.write('matlab -nodesktop -nosplash <<EOF\n')
                bm.write('clear;\n') 
                bm.write('InitFalsification;\n')
                bm.write('InitBreach;\n\n')
		bm.write(param + '\n')
                bm.write('mdl = \''+ model + '\';\n')
                bm.write('Br = BreachSimulinkSystem(mdl);\n')
		bm.write('Br.Sys.tspan ='+ timespan +';\n')
		bm.write('input_gen.type = \'UniStep\';\n') 				
		bm.write('input_gen.cp = '+ str(cp) + ';\n')
		bm.write('Br.SetInputGen(input_gen);\n')
		bm.write('for cpi = 0:input_gen.cp -1\n')
		for i in range(len(input_name)):
		    bm.write('\t' + input_name[i] + '_sig = strcat(\''+input_name[i]+'_u\',num2str(cpi));\n')
		    bm.write('\tBr.SetParamRanges({'+input_name[i] + '_sig},[' +str(input_range[i][0])+' '+str(input_range[i][1]) + ']);\n')
			
		bm.write('end\n')
		bm.write('spec = \''+ property[1]+'\';\n')
		bm.write('phi = STL_Formula(\'phi\',spec);\n')
		
		bm.write('trials = 10;\n')	
		bm.write('filename = \''+filename+'\';\n')
		bm.write('algorithm = \'Breach\';\n')
		bm.write('falsified = [];\n')
		bm.write('time = [];\n')
		
		bm.write('for n = 1:trials\n')
		bm.write('\tfalsif_pb = FalsificationProblem(Br,phi);\n')
		bm.write('\tfalsif_pb.max_time = 900;\n')
		bm.write('\tfalsif_pb.setup_solver(\''+ opt  +'\');\n')
		bm.write('\tfalsif_pb.solve();\n')
		bm.write('\tif falsif_pb.obj_best < 0\n')
		bm.write('\t\tfalsified = [falsified;1];\n')
		bm.write('\telse\n')
		bm.write('\t\tfalsified = [falsified;0];\n')
		bm.write('\tend\n')
		bm.write('\ttime = [time;falsif_pb.time_spent];\n')
		
		bm.write('end\n')

		bm.write('spec = {spec')
		for j in range(1,trials):
		    bm.write(';spec')
		bm.write('};\n')

		bm.write('filename = {filename')
                for j in range(1,trials):
                    bm.write(';filename')
                bm.write('};\n')

		bm.write('result = table(filename, spec, falsified, time);\n')
				
		bm.write('writetable(result,\'$csv\',\'Delimiter\',\';\');\n')
		bm.write('quit\n')
		bm.write('EOF\n')
