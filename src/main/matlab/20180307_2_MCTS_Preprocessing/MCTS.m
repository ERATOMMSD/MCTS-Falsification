classdef MCTS < handle
    properties
        root_node
        
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
        div%array, [a b] the signals are divided into a parts and b parts
        falsified
        child_num
        
        best_children_range
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
            
            signal_dimen = numel(div);
            
            unit = [];
            for u = 1:signal_dimen
                unit = [unit (input_range(u,2)-input_range(u,1))/div(u)];
            end
            
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
                
                %i(k) = i(k)+1;
                
                %if i(k) > div(k)
                    
                 %   k = k + 1;
                  %  if k > signal_dimen
                  %      break;
                  %  end
                %end
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
            
            %for t = 1: numel(children_list)
            %    children_list(t).disp();
            %end
            
            this.child_num = prod(div);
            
            %children_list
            this.falsified = 0;
            this.best_children_range = [Region([])];
            root_state = State(0,[], children_list, input_name,ts);
            %root_state.children_list
            this.root_node = Node(root_state, NaN, this.child_num);
            this.uctsearch(this.root_node);
            
            
        end
        
        function uctsearch(this, node)
            for k = 1:this.budget
                front = this.tree_policy(node);
                reward = this.default_policy(front);

                if reward > this.max_value
                    this.max_value = reward;
                end
                if reward < 0
                    disp('falsified');
                    this.falsified = 1;
                    this.backup(front, reward);
                    break;
                end
                this.backup(front, reward);
                
                %this.plottree();
                %pause(0.5);
            end
            %this.falsified
            %if this.falsified == 0
            %    disp('aaaaaaaaa')
            %    cr = [];
            %    t = node;
            %    while numel(t.children)~=0
            %        t = this.best_child(t);
            %        t.reward
            %        tp = t.state.input_region(t.state.stage)
            %        cr = [cr tp];
            %    end
            %    
            %    this.best_children_range = cr;
            %    this.best_children_range
            %end
        end
        
        
        
        function front = tree_policy(this, node)
            while node.state.terminal() == false
                
                if node.fully_expanded() == false
                    front = this.expand(node);
                    return;
                else
                    node = this.best_child(node);
                    node
                end
            end
            front = node;
        end
        
        
        
        function child = expand(this,node)
            s = node.state.next_state_tp();
            child = Node(s, node, this.child_num);
            node.add_child(child);
        end
        
        
        
        
        function child = best_child(this,node)
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
        
        
        
        
        function reward = default_policy(this, node)
            state = node.state;
            while state.terminal() == false
                state = state.next_state_dp();
            end
            reward = state.reward(this.Br.copy(), this.T, this.phi, this.solver, this.time_out);
        end
        
        
        
    
        
        function backup(this, node, reward)
            
            if reward < this.root_node.reward
                this.best_children_range = node.state.input_region;
            end
            
            while true
                node.visit = node.visit+1;
                if reward < node.reward
                    node.reward = reward;
                    
                end
                
                
                if node.state.stage == 0
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
                if curr.state.stage == 0
                    mat = 'NaN';
                else
                    %curr.state.input_region(curr.state.stage).signal_region
                    mat = mat2str(curr.state.input_region(curr.state.stage).signal_region);
                end
                curr_str = convertCharsToStrings(strcat('v:', num2str(curr.visit),' r:',num2str(curr.reward), mat));
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