classdef State<handle
   properties
       
       stage
       input_region %region list from root to itself
       
       total_children_list
       children_list %n*2, n is the number of all regions
       
       input_name
       signal_dimen
       total_stage
       
      % this_region
   end
   

   
   methods
       function this = State(st, ir, cl, in, ts)
           this.stage = st;
           this.input_region = ir;
           
           
           
           this.total_children_list = cl;
           this.children_list = cl;
           
           this.input_name = in;
           this.signal_dimen = numel(in);
           this.total_stage = ts;
         %  this.this_region = Region([]);
       end
       
       function next = next_state_tp(this)
           st = this.stage + 1;
           %numel(this.children_list)
           i = randi(numel(this.children_list));
           %i
           %this.children_list(i)
           reg = this.children_list(i);
          % this.this_region = reg;
          % this.this_region
           ir = [this.input_region reg];
           this.children_list(i) = [];
           next = State(st, ir,this.total_children_list, this.input_name, this.total_stage);
       end
       
       function next = next_state_dp(this)
           st = this.stage + 1;
           i = randi(numel(this.children_list));
           ir = [this.input_region this.children_list(i)];
           next = State(st, ir,this.total_children_list, this.input_name, this.total_stage);
       end
       
       
       function r = reward(this, br, T, phi, solver, time_out)
           if this.stage == this.total_stage
           
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
           else
               r = intmax;
           end
           
       end
       
       
       
       function stop = terminal(this)
           stop = false;
           if this.stage == this.total_stage
               stop = true;
           end
       end
   end
end