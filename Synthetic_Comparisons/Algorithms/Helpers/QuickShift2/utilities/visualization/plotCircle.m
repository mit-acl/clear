function varargout = plotCircle(x,y,r,varargin)
N=size(x,1);
if N>1
    h=repmat(struct(),N,1);
    flagHold=ishold;
    for iN=1:N
        plotCircle(x(iN,:),y(iN,:),r(iN),varargin{:})
        hold on
    end
    if ~flagHold
        hold off
    end
else
    d = r*2;
    px = x-r;
    py = y-r;
    h = rectangle('Position',[px py d d],'Curvature',[1,1],varargin{:});
end
if nargout>0
    varargout{1}=h;
end
