classdef State<handle
   properties
       
       input_region
       stage
       
       total_children_list
       children_list
       
       input_name
       input_range
       signal_dimen
       total_stage
   end
   
   
   
   methods
       function this = State(st, ir, cl, in, inrange, ts)
           
           this.stage = st;
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
          
           ir = [this.input_region reg];
           this.children_list(i) = [];
           next = State(st, ir,this.total_children_list, this.input_name, this.input_range,  this.total_stage);
       end
       
       function next = next_state_dp(this)
           st = this.stage + 1;
           
           ir = [this.input_region this.input_range];
           next = State(st, ir,this.total_children_list, this.input_name, this.input_range, this.total_stage);
       end
       
       function r = reward(this, br, T, phi, solver, time_out)
           br.Sys.tspan = 0:.01:T;
           input_gen.type = 'UniStep';
           input_gen.cp = this.total_stage;
           br.SetInputGen(input_gen);
           
           for i = 1:this.total_stage
               for j = 1:numel(this.input_name)
                   br.SetParamRanges({strcat(this.input_name(j),'_u',num2str(i-1))}, this.input_region(i).get_signal(j));%to do
                   br.SetParam({strcat(this.input_name(j),'_u',num2str(i-1))}, this.input_region(i).center(j))
               end
           end
           
           falsif_pb = FalsificationProblem(br, phi);
           falsif_pb.setup_solver(solver);
           falsif_pb.max_time = time_out;
           falsif_pb.solve();
           
           
           r = falsif_pb.obj_best;
       end
       
       
       
       
       
       function stop = terminal(this)
           stop = false;
           if this.stage == this.total_stage
               stop = true;
           end
       end
   end
end