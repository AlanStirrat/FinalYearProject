% Create pairwise matrix from ratings
function P = pairwiseAlg(R)
  
  
r = zeros(1000,1000);
ans = 0;
ruij = 0;

#for x=1:size(R(:,1))
  
 # r(R(x,1),R(x,2)) = R(x,3);
  
 # end
  
  #b = (r > 0)
  
  trainMat = sparse(R(:,1), R(:,2), R(:,3))
  user_item = trainMat > 0
  y = size(unique(R(:,2)));
  no_of_items = y(:,1)
  
  
  #for i = 1: size(unique(R(:,2)))
    
    
  
  
  #end
  
 
  ind1 = z(:,1) == 1
  x = sum(z);
  no_of_users = full(x)
  
  for i = 1: no_of_items
    for j = 1: no_of_items
       z = user_item(:,i).* user_item(:,j)
       ind1 = z(:,1) == 1
        x = sum(z);
        no_of_users = full(x)
       for z =1: sizeof(ind1)
        ruij += trainMat(ind1(z,i)) - trainMat(ind1(z,j));
       end
       r(i,j) = (1/no_of_users)*ruij
    end
  end
  
  z
  
  
P = z;  