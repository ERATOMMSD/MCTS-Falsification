%Region represents a region of input signal.
%Say the signal is 2-dim: A B, then Region is represented as:
%[A_left A_right; B_left B_right]
classdef Region
    properties
        signal_region
        signal_dimen
    end
    
    methods
        function this = Region(sr)
            this.signal_region = sr;
            [signal_dimen, ~] = size(sr);
        end
        
        function r = get_signal(this, i)
            r = this.signal_region(i,:);
        end
        
        function b = get_bound(this,i,j)
            
            b = this.signal_region(i,j);
        end
        
        function c = center(this, i)
            r = this.signal_region(i,:);
            c = (r(1)+r(2))/2;
        end
        
        function l = left(this, i)
           l = this.signal_region(i,1);
        end
        
        function r = right(this, i)
            r = this.signal_region(i,2);
        end
        
        function disp(this)
            this.signal_region
        end
        
        function yes = contains(this, reg, margin)
            yes = true;
            for k = 1:this.signal_dimen
                if abs(this.signal_region(k,1)-reg.get_bound(k,1))>margin || abs(this.signal_region(k,2)-reg.get_bound(k,2)>margin)
                    yes = false;
                    break;
                end
            end
            
        end
    end
end