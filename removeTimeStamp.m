function l = removeTimeStamp

Y = importdata('u1.base');

    % remove timestamp
    if size(Y,2)>3
        Y(:,4) = [];
    end
    
    
p = find([true;diff(Y(:,2))~=0;true])   
q = find([true;diff(Y(:,1))~=0;true])  
a = size(q)
b = size(p)


R = zeros(b(:,1),a(:,1))
 