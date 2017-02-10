% Create pairwise matrix from ratings
function P = createPairwise(R)

M = 1000000;

full_total = size(R, 1)

pp = M/(full_total*(full_total - 1)/2);

s = size(R,1) * 100;
P = zeros(s, 3);
c  =0; 
[Rs,indx] = sort(R(:,1));
Rs = R(indx,:);
i = 1;

while (i<=size(Rs,1))
    user_i = Rs(i,1);
    if (c > s)
      break
     end 
    j=i;
    items=[];
    ratings=[];
    
    %loop through items for user
    while (j<=size(Rs,1) && Rs(j,1)==user_i)
        items=[items;Rs(j,2)];
        ratings=[ratings;Rs(j,3)];
        j=j+1;
    end
    i=j;

    % sort ratings and items
    urats=unique(ratings);
    [srats,indx]=sort(ratings);
    items=items(indx);
    
    
    xtab=zeros(length(urats)+1,1);    
    xtab(1) = 1; 
    u = urats(1); 
    
    %sets tab for rating of sorted item
    l = 1;
    for k=1:length(srats),
        if (srats(k) ~= u)
            u = srats(k);
            l = l+1;
            xtab(l) = k;
        end
    end
    xtab(end)=length(items)+1;

    %loops through tabs of ratings, sets higher rated item for all at that rating
    for k=1:length(urats),
        for j=xtab(k):(xtab(k+1)-1),
            for l=xtab(k+1):length(items),
            
              if (rand < pp)
              
                c=c+1;
                P(c,:) = [user_i, items(l), items(j)];
               end 
            end
        end
    end
  end
 c
save test.mat c ;
P = P(1:c, :)