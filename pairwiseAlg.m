% Create pairwise matrix from ratings
function P = pairwiseAlg(R)
  
  
r = zeros(1000,1000);
ans = 0;

#for x=1:size(R(:,1))
  
 # r(R(x,1),R(x,2)) = R(x,3);
  
 # end
  
  #b = (r > 0)
  
  trainMat = sparse(R(:,1), R(:,2), R(:,3))
  z = trainMat(:,123).* trainMat(:,456)
  
 # for i = 1: size(unique(R(:,2)))
  
    
  
  
  #end
  
  z
  
  
P = trainMat;  