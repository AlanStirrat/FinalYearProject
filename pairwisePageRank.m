% Calculate PageRank for Pairwise Preferences
function x = pairwisePageRank(P)

pMax = max([P(:,2);P(:,3)]);
indx = unique([P(:,2);P(:,3)]);
vals = ones(size(P,1),1);

% adding the Loser node
L = [indx, (pMax+1)*ones(length(indx),1)];
vals = [vals;ones(length(L),1)];

% adding the Winner node
Wt = [(pMax+2)*ones(length(indx),1),indx];
vals = [vals;ones(length(Wt),1)];

ip = [P(:,2);L(:,1);Wt(:,1)];
jp = [P(:,3);L(:,2);Wt(:,2)];

dim = pMax+2;

% Creates a sparse adjacency matrix
A = sparse(ip,jp,vals,dim,dim);

% connection between winner and lsoer
A(pMax+1,pMax+2)=1;
A(pMax+2,pMax+1)=1;

%checks to make sure column sums are greater than 0
mask = ((sum(A)>0)' + (sum(A,2)>0))>0;

% set diagonal to 0.5
A = A + sparse(1:dim,1:dim, 0.5*mask);

% sum of columns - degree
D=ones(dim,1);
D(mask) = sum(A(mask,mask));

% diagonal matrix of 1/degree
D = sparse(1:dim,1:dim, 1./D);

% normalises A to sum to 1
Y = A*D;
x = rand(size(A,1), 1);
x = Y*x;

% converge x
xold = x;
x = Y*x;
while (norm(x-xold)>0.00001)
    xold = x;
    for i=1:10,
        x = Y*x;
    end
end

%remove winner and loser nodes and normalise
x = x(1:pMax);
x = x/sum(x);