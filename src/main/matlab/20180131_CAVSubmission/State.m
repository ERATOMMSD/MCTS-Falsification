classdef State<handle
   properties
       
       input_signal %for the previous stages
       
       input_region %only for the current stage
       stage
       
       total_children_list
       children_list
       
       input_name
       input_range
       signal_dimen
       total_stage
       
   end
   
  
   
   methods
       function this = State(st, is,ir, cl, in, inrange, ts)
           
           this.stage = st;
           this.input_signal = is;
           this.input_region = ir;
           
           this.total_children_list = cl;
           this.children_list = cl;
           
           this.input_name = in;
           this.input_range = inrange;
           this.signal_dimen = numel(in);
           this.total_stage = ts;
       end
       
       function next = next_state_tp(this)
           st = this.stage + 1;
           
           i = randi(numel(this.children_list));
           
           reg = this.children_list(i);
          
           
           this.children_list(i) = [];
           next = State(st,this.input_signal ,reg,this.total_children_list, this.input_name, this.input_range,  this.total_stage);
       end
       
       
       
       function r = reward(this, br, T, phi, solver, time_out)
           br.Sys.tspan = 0:.01:T;
           input_gen.type = 'UniStep';
           input_gen.cp = this.total_stage;
           br.SetInputGen(input_gen);
           
           for i = 1:this.total_stage
               if i < this.stage
                   for j = 1:numel(this.input_name)
                       br.SetParam({strcat(this.input_name(j),'_u',num2str(i-1))}, this.input_signal(j,i));
                   end
               elseif i == this.stage
                   for h = 1:numel(this.input_name)
                       br.SetParamRanges({strcat(this.input_name(h),'_u',num2str(i-1))},this.input_region.get_signal(h));
                   end
               else
                   for k = 1:numel(this.input_name)
                       br.SetParamRanges({strcat(this.input_name(k),'_u', num2str(i-1))}, this.input_range(k,:));
                   end
               end
           end
           
           falsif_pb = FalsificationProblem(br, phi);
           falsif_pb.setup_solver(solver);
           falsif_pb.max_time = time_out;
           falsif_pb.solve();
           
           
           
           
           r = falsif_pb.obj_best;
           part_best = [];
           for m = 1:this.signal_dimen
               part_best = [part_best;falsif_pb.x_best((1+(m-1)*(this.total_stage-this.stage+1)))];
           end
           %part_best = [falsif_pb.x_best(1);falsif_pb.x_best(7-this.stage)];%%%%why??
           this.input_signal = [this.input_signal part_best];
       end
       
       
       
       
       
       function stop = terminal(this)
           stop = false;
           if this.stage == this.total_stage
               stop = true;
           end
       end
   end
end