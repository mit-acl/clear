%% Find connected components of graph via BFS algorithm
%
% Input:
%        A:   Adjacency matrix
%
% Output:
%       labels =[1 1 1 2 2 3 3 ...].  lenght(labels)=L, label for each vertex
%       labels(i) is order number of connected component, i is vertex number
%
%       (disabled) rts - roots, numbers of started vertex in each component 
%
% (c) Based on code by Maxim Vedenyov, vedenev@ngs.ru
% http://simulations.narod.ru/
%
% Modified by Kaveh Fathian to improve speed
% kavehfathian@gmail.com
% https://sites.google.com/view/kavehfathian/home
%
%
function [labels, rts] = GraphConnectedComp(A)

sizA = size(A,1); % number of vertex


% Breadth-first search (BFS):

labels = zeros(1,sizA); % all vertex unexplored at the begining
rts = [];
ccc = 0; % connected components counter


while true
    idx = find(labels==0);
    if ~isempty(idx)
        fue = idx(1); % first unexplored vertex
%         rts = [rts fue];
        list = fue;
        ccc = ccc + 1;
        labels(fue) = ccc;
        while true
            list_new = zeros(1,sizA);
            cntr = 0; % counter
            lenList = length(list);
            for lc = 1 : length(list)
                p = list(lc); % point
                cp = find(A(p,:)); % points connected to p
                cp1 = cp(labels(cp)==0); % get only unexplored vertecies
                labels(cp1) = ccc;    
                lencp1 = length(cp1);
                list_new(cntr+1:cntr+lencp1) = cp1;
                cntr = cntr + lencp1;
            end
            list = list_new(1:cntr);
            if isempty(list)
                break;
            end
        end
    else
        break;
    end
end


% while true
%     idx = find(labels==0);
%     if ~isempty(idx)
%         fue = idx(1); % first unexplored vertex
% %         rts = [rts fue];
%         list = fue;
%         ccc = ccc + 1;
%         labels(fue) = ccc;
%         while true
%             list_new = [];
%             for lc = 1 : length(list)
%                 p = list(lc); % point
%                 cp = find(A(p,:)); % points connected to p
%                 cp1 = cp(labels(cp)==0); % get only unexplored vertecies
%                 labels(cp1) = ccc;
%                 list_new = [list_new cp1];
%             end
%             list = list_new;
%             if isempty(list)
%                 break;
%             end
%         end
%     else
%         break;
%     end
% end