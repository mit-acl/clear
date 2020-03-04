%Examples of using QuickMatch (matching based on QuickShift) on a synthetic
%dataset with different parameters
function quickshift_matching_test
resetRands(1)

%common parameters to all tests
paramsMatchingCommon={'gaussian',...
    'ratioDensity',0.25,...
    'ratioInterCluster',0.67,...
    'threshold',Inf,...
    'densityLogAmplify'};

%number of outliers to introduce in the synthetic dataset
paramsDataset={'nOutliersClass',5};

%change testNumber to check different strategies
for testNumber=1:3
    testName=sprintf('Test #%d',testNumber);
    disp(testName) %#ok<DSPS>
    switch testNumber
        case 1
            %No additional criteria for matching
            paramsMatching={};
        case 2
            %Use prior membership during matching
            paramsMatching={'useMembershipPriorInTree'};
        case 3
            %Use distances with neighbors already in same cluster to compute
            %the scale of each edge
            paramsMatching={'optsScales',{'proportionalInterNeighbor',4},...
                'ratioInterCluster',0.5};
    end


    %generate points in 4 "images"
    [X,membershipPrior,NPoints]=quickshift_test_datasets('matching',...
        'NPointsClass',20,paramsDataset{:});

    %compute pairwise distances
    D=sqrt(euclideanDistMatrix(X,X));

    %Do the clustering
    [membershipMatches,info]=quickshift_matching(D,membershipPrior,...
        paramsMatchingCommon{:},...
        paramsMatching{:});

    quickshift_checkMembershipsClusters(membershipMatches,membershipPrior)

    %Visualize results
    NMatches=length(unique(membershipMatches));
    disp([num2str(NMatches) ' clusters'])
    
    figure(testNumber)
    
    cmap=parula(NMatches);
    plotGroups([X(:,1:NPoints); info.density(1:NPoints)],membershipPrior(1:NPoints))
    hold on
    plotPoints([X(:,NPoints+1:end); info.density(NPoints+1:end)],'bx')
    plotLines([X; zeros(1,size(X,2))],[X;info.density])

    for iCluster=1:NMatches
        plot(X(1,membershipMatches==iCluster),X(2,membershipMatches==iCluster),'o',...
            'markeredgecolor',cmap(iCluster,:),'markersize',15)
    end

    %Plot the 2-D tree on the 2-D points
    quickshift_plotTree(X,info.treeEdges,'color',0.8*[1 1 1])
    quickshift_plotTree(X,info.treeEdgesClusters,'color',[1 0.5 0.5])
    %quickshift_plotTree(X,info.treeDistances)
    quickshift_plotScales(X,info.scales,'edgecolor',0.8*[1 1 1])

    %mark roots of clusters
    flagRoots=quickshift_treeRoots(info.treeEdgesClusters);
    XRoots=X(:,flagRoots);
    for iRoot=1:sum(flagRoots)
        text(XRoots(1,iRoot),XRoots(2,iRoot),'R')
    end

    %mark top 3 roots
    idxRootsTop=quickshift_treeRootsTopK(info.treeEdgesClusters,info.density,3);
    for iRoot=idxRootsTop
        text(X(1,iRoot),X(2,iRoot),info.density(iRoot),'T','HorizontalAlignment','right')
    end
    
%     convert roots to cluster indices:
%     membershipMatchesTop=membershipMatches(idxRootsTop)
    
    hold off
    view(2)
    axis equal
    title(testName)
end

fprintf('# Plot description\n - Crosses: outliers.\n - Small circles: class ("image") prior.\n - Large circles: correspondences.\n - Red arrows: tree after breaking.\n - Grey arrows: tree before breaking.\n - Nodes marked with R: Roots of the connected component.\n - Nodes marked with T: Top 3 roots\n ')
fprintf('Rotate the graph to see the values of the density at each point.\n')
fprintf('Observe the small differences in clustering due to the different parameters where the points are dense.\n')

