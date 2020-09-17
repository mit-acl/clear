function D = PairDist(fi, fj, Hij)


sizi = size(fi,2);
sizj = size(fj,2);

Mi = Hij * [fi; ones(1,sizi)]; % Order of multiplication matter!
Mj = [fj; ones(1,sizj)];

D = zeros(sizi, sizj);

for i = 1 : sizi
    mi = Mi(:,i);
    scr = bsxfun(@rdivide, Mj,mi);        
    D(i,:) = var(scr, 0 ,1);
end




% sizi = size(fi,2);
% sizj = size(fj,2);
% 
% Mi = [fi; ones(1,sizi)];
% Mj = [fj; ones(1,sizj)];
% 
% D = zeros(sizi, sizj);
% 
% for i = 1 : sizi
%     for j = 1 : sizj
%         mi = Mi(:,i);
%         mj = Mj(:,j);
%         scr = (Hij*mi) ./ mj;        
%         D(i,j) = var(scr);
%     end
% end
% 


















































































