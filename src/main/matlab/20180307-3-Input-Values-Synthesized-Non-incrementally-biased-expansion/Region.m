classdef Region
    properties
        signal_region
    end
    
    methods
        function this = Region(sr)
            this.signal_region = sr;
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
    end
end