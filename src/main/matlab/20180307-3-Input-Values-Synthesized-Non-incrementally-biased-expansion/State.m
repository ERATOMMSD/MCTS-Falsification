classdef State<handle
   properties
       
       input_region
       stage
       
       total_children_list    %all children
       children_list          %not yet expanded children
       children_remove_list   %already expanded children
       
       input_name
       input_range
       signal_dimen
       total_stage
       signal_unit
       
      
       
   end
   
   
   
   methods
       function this = State(st, ir, cl, in, inrange, ts, unit)
           this.stage = st;
           this.input_region = ir;
           
           this.total_children_list = cl;
           this.children_list = cl;
           this.children_remove_list = [];
           
           this.input_name = in;
           this.input_range = inrange;
           this.signal_dimen = numel(in);
           this.total_stage = ts;
           this.signal_unit = unit;
       end
       
       
       
      
       
       function [rew,s_reg, state] = reward(this, br, T, phi, solver, time_out)
           
           reg = this.compute_region();
           
           
           
           br.Sys.tspan = 0:.01:T;
           input_gen.type = 'UniStep';
           input_gen.cp = this.total_stage;
           br.SetInputGen(input_gen);
           
           for i = 1:this.total_stage
               if i < this.stage
                   for j = 1:numel(this.input_name)
                        br.SetParamRanges({strcat(this.input_name(j),'_u',num2str(i-1))},this.input_region(i).get_signal(j));
                        br.SetParam({strcat(this.input_name(j),'_u',num2str(i-1))},this.input_region(i).center(j));
                   end
               elseif i == this.stage
                    for j = 1:numel(this.input_name)
                        
                        br.SetParamRanges({strcat(this.input_name(j),'_u',num2str(i-1))},reg(j,:));
                        br.SetParam({strcat(this.input_name(j),'_u',num2str(i-1))}, (reg(j,1)+reg(j,2))/2);
                    end
               else 
                   for j = 1:numel(this.input_name)
                       br.SetParamRanges({strcat(this.input_name(j),'_u',num2str(i-1))}, this.input_range(j,:));%to do
                       br.SetParam({strcat(this.input_name(j),'_u',num2str(i-1))}, (this.input_range(j,1)+this.input_range(j,2))/2);
                   end
               end
           end
           
           falsif_pb = FalsificationProblem(br, phi);
           falsif_pb.setup_solver(solver);
           falsif_pb.max_time = time_out;
           falsif_pb.solve();
           
           
           rew = falsif_pb.obj_best;
           part_best = [];
           for m = 1:this.signal_dimen
               part_best = [part_best;falsif_pb.x_best(this.stage + (m-1)*(this.total_stage))];
           end
           
           
           [unit_region, s_reg] = this.return_to_region(part_best);
           
           state = State(this.stage+1,[this.input_region unit_region], this.total_children_list, this.input_name,this.input_range,this.total_stage,this.signal_unit);
           
       end
       
       function result_reg = compute_region(this)%a large region according to ban_list
           numel(this.children_list)
           i = randi(numel(this.children_list));
           small_reg = this.children_list(i);
           
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% only work for 2d
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% signal; 18.05.28 fix
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% this bug
           
           
           b_lb = [];
           b_rb = [];
           for u = 1: this.signal_dimen
               b_lb = [b_lb;small_reg.get_bound(u,1)];
               b_rb = [b_rb;small_reg.get_bound(u,2)];
           end
           lb = b_lb;
           rb = b_rb;
           
           margin = this.signal_unit/10;
           for k = 1:this.signal_dimen
               while true
                   
                   if abs(lb(k) - this.input_range(k,1)) < margin % reach the bound of the region
                       break;
                   elseif this.contain([lb rb], margin) %already expanded child is contained in the region
                   %    lb(k) = lb(k)+ this.signal_unit(k);
                       break;
                   end
                   lb(k) = lb(k) - this.signal_unit(k);
               end
               
                
               while true
                   
                   if abs(rb(k) - this.input_range(k,2)) < margin % reach the bound of the region
                       break;
                   elseif this.contain([lb rb], margin)  %already expanded child is contained in the region
                  %     rb(k) = rb(k) - this.signal_unit(k);
                       break;
                   end
                   rb(k) = rb(k) + this.signal_unit(k);
               end
               
           end
           result_reg = [lb rb];
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
       end
       
       function yes = contain(this,reg, margin) %the margin is not 0 but a reasonable range.
           
           yes = false;
           par_region = Region(reg);
           
           for r = this.children_remove_list
               
             %  if r.get_bound(1,1)-reg(1,1)>-1&&r.get_bound(1,2)-reg(1,2)<=1&& r.get_bound(2,1)-reg(2,1)>=-1&&r.get_bound(2,2)-reg(2,2)<=1
               if par_region.contains(r, margin) 
                   yes = true;
                   
                   break;
               end
           end
           
       end
       
       
       
       function [region,which] = return_to_region(this, point)%according to a point, work out a small region
           region = [];
           which = -1;
           
           for s = 1:length(this.children_list)
                ins = this.inside(point, this.children_list(s));
                
                if ins == true
                    region = this.children_list(s);
                    which = s;
                    
                    %add sth to ban list
                    new_ban_l = [];
                    new_ban_r = [];
                    for i = 1:this.signal_dimen
                         new_ban_l = [new_ban_l;region.get_bound(i,1)];
                         new_ban_r = [new_ban_r;region.get_bound(i,2)];
                    end
                    
                    break;
                end
           end
           
           this.children_remove_list = [this.children_remove_list this.children_list(which)];
           
       end
       
       function yes = inside(this, point, region)
           yes = true;
           for i = 1:this.signal_dimen
               if point(i) < region.get_bound(i,1) || point(i) > region.get_bound(i,2)
                    yes = false;
                    break;
               end
               
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