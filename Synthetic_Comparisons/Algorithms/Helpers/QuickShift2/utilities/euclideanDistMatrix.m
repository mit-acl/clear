%function dSq=euclideanDistMatrix(A,B)
%Compute the Euclidean squared distance between each sample of A and each sample
%of B
function dSq=euclideanDistMatrix(A,B)

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

% Ver: 13-Jul-2016 06:16:26

% Roberto Tron (tron@bu.edu)


if ~exist('B','var') || isempty(B)
    B=A;
end

NA=size(A,2);
NB=size(B,2);

dSq=sum(A.^2,1)'*ones(1,NB)+ones(NA,1)*sum(B.^2,1)-2*A'*B;
