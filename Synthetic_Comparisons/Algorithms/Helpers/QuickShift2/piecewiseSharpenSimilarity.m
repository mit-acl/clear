%Sharpen a similarity in the [0,1] range
%function s=piecewiseSharpenSimilarity(s,threshold)
%Apply the function max(0,s-threshold/(1-threshold)). This has the effect
%of "sharpening" the similarities (simiarities that are at 1 remain at 1,
%while similarities below threshold are pushed to zero). The function is
%based on the use of bsxfun, so it has the same singleton expansion
%properties
function s=piecewiseSharpenSimilarity(s,threshold)

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

% Ver: 09-Mar-2017 09:02:58

% Roberto Tron (tron@bu.edu)

s=bsxfun(@rdivide,s,1-threshold);
if ~issparse(s)
    s=max(0,bsxfun(@minus,s,threshold./(1-threshold)));
else
    %perform same operation but avoid the fill-in of sparse matrices
    m=s>0;
    m=bsxfun(@times,m,threshold./(1-threshold));
    s=max(0,s-m);
end
