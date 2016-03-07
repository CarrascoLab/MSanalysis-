function [ relation ] = catDir( theta, diag, tLoc )
%for analysis of PLatt
% theta is the direction of an eye-movement
% diag 1 = upper left & lower right; diag 2= upper right & lower left
% tLoc -> 1 = left, 2 = right
%
% quadrants
%                 |
%        2       |        1
% ___________________
%        3       |        4
%                 |

    
[quad,relation]= deal(nan(size(theta)));
% determine quadrant 
quad (sin(theta)>0 & cos(theta)>0)=1;
quad (sin(theta)>0 & cos(theta)<0)=2;
quad (sin(theta)<0 & cos(theta)<0)=3;
quad (sin(theta)<0 & cos(theta)>0)=4;

out={ [0 1 0 -1] [0 -1 0 1]; [-1 0 1 0] [1 0 -1 0]}; %matrix of output 
% out{diag,tLoc}(quad) returns the appropriate classification for each quadrant
% 1= congruent, -1= opposite, 0= incongruent

if numel(diag)==1 && numel(tLoc)==1 
    relation= out{diag,tLoc}(quad);
else 
    assert (numel(diag)==numel(quad) && numel(tLoc)==numel(quad))
    for n=1: numel(diag)
        relation(n)= out{diag(n),tLoc(n)}(quad(n));
    end
end
        

% switch quad
%     case 1
%         if diag==1
%             relation='incon';
%         elseif tLoc==1
%             relation='oppos';
%         elseif tLoc==2
%             relation='congr';
%         end
%         
%     case 2
%         if diag==2
%             relation='incon';
%         elseif tLoc==2
%             relation='oppos';
%         elseif tLoc==1
%             relation='congr';
%         end
%     case 3
%         if diag==1
%             relation='incon';
%         elseif tLoc==1
%             relation='congr';
%         elseif tLoc==2
%             relation='oppos';
%         end
%     case 4
%         if diag==2
%             relation='incon';
%         elseif tLoc==1
%             relation='oppos';
%         elseif tLoc==2
%             relation='congr';
%         end
% end


end

