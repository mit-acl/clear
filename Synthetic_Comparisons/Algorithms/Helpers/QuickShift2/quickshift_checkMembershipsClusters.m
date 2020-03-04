%Function to check self-consistency properties in the the output of quickshift_matching
function quickshift_checkMembershipsClusters(membershipCluster,membershipPrior,clusterIndicators)

%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Ver: 09-Jul-2018 15:50:16

% Roberto Tron (tron@bu.edu)

%check that clusters with non-zero indicators are the same as
%the unique clusters referenced by the membership
clusters=unique(membershipCluster);
if exist('clusterIndicators','var')
    fprintf('Indeces of referred clusters...')
    clusterDiff=setdiff(clusters,find(sum(clusterIndicators,2)));
    if isempty(clusterDiff)
        disp('OK')
    else
        disp('Inconsistent')
    end
end

%check that each cluster does not contain points from the same prior
fprintf('Check that clusters contain points from different priors...')
flagPass=true;
for kCluster=clusters
    flagPoints=membershipCluster==kCluster;
    pointsPrior=membershipPrior(flagPoints);
    flagPass=and(flagPass,length(unique(pointsPrior))==length(pointsPrior));
end

if flagPass
    disp('OK')
else
    disp('Conflicts')
end
