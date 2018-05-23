classdef MCTS < handle
   properties
       Br
       max_value
       budget
       scalar
       phi
       T
       total_stage
       
       solver
       time_out
       
       input_name
       input_range
       div
       signal_unit
       
       child_num
       falsified
       
       root_node
       
       
       best_children_range
       
       stop
   end
   
   methods
       function this = MCTS(br, budget, scalar, phi, T, ts, solver, time_out, input_name, input_range, div)
            this.max_value = 0;
            this.Br = br;
            this.budget = budget;
            this.scalar = scalar;
            
            this.phi = phi;
            this.T = T;
            this.total_stage = ts;
            
            this.solver = solver;
            this.time_out = time_out;
            
            this.input_name = input_name;
            this.input_range = input_range;
            this.div = div;
            
            this.stop = 0;
            
            signal_dimen = numel(div);
            
            unit = [];
            for u = 1:signal_dimen
                unit = [unit (input_range(u,2)-input_range(u,1))/div(u)];
            end
            this.signal_unit = unit;
            
            children_list = [];
            i = ones(1,signal_dimen);
            k = 1;
            
            while true
                region = [];
                for j = 1:signal_dimen
                    region = [region; [input_range(j,1)+unit(j)*(i(j)-1) input_range(j,1)+unit(j)*i(j)]];
                end
                r = Region(region);
                children_list = [children_list r];
                
                
                break_f = 0;
                while true
                    if i(k)+1 > div(k)
                        i(k) = 1;
                        if k+1 > signal_dimen
                            break_f = 1;
                            break;
                        else
                            k = k+1;
                        end
                    else
                        i(k) = i(k) + 1;
                        k = 1;
                        break;
                    end
                end
                
                if break_f == 1
                    break;
                end
            end
            
            this.child_num = prod(div);
            
            this.falsified = 0;
            this.best_children_range = [Region([])];
            
            root_state = State(1,[], children_list, input_name,input_range,ts,this.signal_unit);
            this.root_node = Node(root_state, NaN, this.child_num);
            for k = 1:budget
                
                this.uctsearch(this.root_node);
                
                if this.stop == 1
                    break;
                end
            end
       end
       
       
       function uctsearch(this, node)
            node.visit = node.visit+1;

            if numel(node.state.children_remove_list)>=0.7*(node.visit^0.85)||node.fully_expanded()
                
                front = this.best_child(node);
                this.uctsearch(front);
%                this.backup(front, front.reward);
                
            else %not fully expanded
                
                [reward, state, bottom] = this.default_policy(node);%region is a small region
                if bottom
                    return;
                end
               
                child = this.expand(node, state);
                this.backup(child, reward);
                if reward > this.max_value
                    this.max_value = reward;
                end
                if reward < 0
                    this.falsified = 1;
                    this.stop = 1;
                end
                
                %this.plottree();
                %pause(1);
            end
            
            
       end
       
       function [rew, state, bottom] = default_policy(this, node)
            
            
            sta = node.state;
            
            if sta.stage >= this.total_stage+1
                rew = node.reward;
                state = sta;
                bottom = true;
            else
            
                [rew, reg, state] = sta.reward(this.Br.copy(), this.T, this.phi, this.solver, this.time_out);
                node.state.children_list(reg) = [];
                bottom = false;
            end
            
       end
       
       function child = best_child(this, node)
            best_score = -1;
            best_children = [];
            
            for c = node.children
                exploitation = 1.0-(c.reward/(this.max_value));
                exploration = sqrt((2.0*log(node.visit))/c.visit);
                score = exploitation+ this.scalar*exploration;
                
                if score == best_score
                    best_children = [best_children c];
                end
                if score > best_score
                    best_children = c;
                    best_score = score;
                end
            end
            
            n = numel(best_children);
            if n>1
                child = best_children(randi(n));
            else
                child = best_children(1);
            end
       end
       
       function child = expand(this, node, state)
           child = Node(state, node, this.child_num);
           child.visit = child.visit+1;
           node.add_child(child);
       end
       
       function backup(this, node, reward)
           
           if reward < this.root_node.reward
                this.best_children_range = node.state.input_region;
           end
           
           while true
                
               
               
                
                if reward < node.reward
                    node.reward = reward;
                end
                
                
                if node.state.stage == 1
                    break;
                else
                    node = node.parent;
                end
            end
       end
       
       function plottree(this)
            queue = CQueue();
            queue.push(this.root_node);
            nodes = [0];
            node_id = 1;
            str = [];
            while ~queue.isempty()
                curr = queue.pop();
                %curr.state.stage
                if curr.state.stage-1 == 0
                    mat = 'NaN';
                else
                    %curr.state.input_region(curr.state.stage).signal_region
                    mat = mat2str(curr.state.input_region(curr.state.stage-1).signal_region);
                end
                curr_str = convertCharsToStrings(strcat('v:', num2str(curr.visit),' r:',num2str(curr.reward), mat,num2str(curr.state.stage)));
                str = [str;curr_str];
                
                for c = curr.children
                    queue.push(c);
                    nodes = [nodes node_id];
                end
                node_id = node_id + 1;
                
            end
            
            my_treeplot(nodes);
            
            [x,y] = my_treelayout(nodes);
            x = x';
            y = y';

            name1 = str;

            text(x(:,1), y(:,1), name1, 'VerticalAlignment','bottom','HorizontalAlignment','right')
        end

       
   end
end