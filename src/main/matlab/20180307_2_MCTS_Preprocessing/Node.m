classdef Node < handle
    properties
        visit
        reward
        state
        
        children
        parent
        max_child_num

    end
    
    
    
    methods
        function this = Node(state, parent, mcn)
            this.visit = 0;
            this.reward = intmax;
            this.state = state;
            this.children = [];
            this.parent = parent;
            this.max_child_num = mcn;
        end
        
        function add_child(this, child)
            
            this.children = [this.children child];
        end
        
        
        
        function full = fully_expanded(this)
            full = false;
            if numel(this.children) == this.max_child_num
                full = true;
            end
        end
    end
end