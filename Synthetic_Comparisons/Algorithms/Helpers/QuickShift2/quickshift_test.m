%Example of using QuickShift for clustering with different strategies
function quickshift_test

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

% Ver: 14-Oct-2017 18:09:46

% Roberto Tron (tron@bu.edu)

resetRands(1)

%Change the test name to check different strategies to break the tree
testNameList={'threshold','descendents'};

%Options corresponding to each strategy to test
optsCluster.threshold={'methodBreakTree','threshold','optsBreakTree',{'threshold',2}};
optsCluster.descendents={'methodBreakTree','descendents',...
    'optsBreakTree',{'ratio',1,'distancesDefault',2,'debuginfo'}};%,'debugshowtree',X}};


for iTest=1:length(testNameList)
    testName=testNameList{iTest};
    disp(testName)

    %generate points in 4 clusters
    X=quickshift_test_datasets();



    %compute pairwise distances
    D=sqrt(euclideanDistMatrix(X,X));

    %Gaussian kernel
    phi=@(x) exp(-x.^2/2);

    %Do the clustering
    [membershipCluster,info]=quickshift_cluster(D,'phi',phi,optsCluster.(testName){:});

    %Visualize results
    K=length(unique(membershipCluster));
    disp([num2str(K) ' clusters'])

    figure(iTest)
    plotGroups(X,membershipCluster)
    hold on

    %Plot the 2-D tree on the 2-D points
    quickshift_plotTree(X,info.treeEdges,'color',0.8*[1 1 1])
    quickshift_plotTree(X,info.treeEdgesClusters)
    hold off
    title(testName)
end


