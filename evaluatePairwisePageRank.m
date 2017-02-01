function evaluatePairwisePageRank

% ----- Variables -----
subset = .8; % percentage size of subset of rating items
k = 60; %neighbours
it = 5; %cross validation iterations
N = 10; %top N items

dataFromFile = false;  % read the pairwise data directly from a file 
calculateDis = false;



% start evaluation
fprintf('Computes Recomendations Based on PageRank for Each User \n');
fprintf('Subset %f, N %i, k %i \n\n', subset, N, k);
fflush(stdout);

tStart=tic;

if (dataFromFile)
    load 'pairData_1M.mat';
end

if (~dataFromFile)
    % format: user id  item id  rating  timestamp.
    Y = importdata('u1.base');

    % remove timestamp
    if (size(Y,2)>3)
        Y(:,4) = [];
    end

     % only use percent subset of data
    Y = Y(1:ceil(subset*size(Y,1)), :);
    
    p = randperm(length(Y));

    Y(:,1) = Y(p,1);
    Y(:,2) = Y(p,2);
    Y(:,3) = Y(p,3);
     
end



first=1;
testSize=floor(length(Y)/5);
last = testSize;
totalPrecision=0.0;
totalRecall = 0.0;
counter = 0;
precision=0.0;
recall = 0.0;
rowSize = 0;
colSize = 0;
ArrayPlot = cell(it,2);
RecallPlot = cell(it,2);
prec_count = 0;
recall_count = 0;
mean_prec = 0;
mean_recall = 0;



% cross validation loop
for i_it=1:it,
    
        % ratings
        testY = Y(first:last,:);
        trainY = [Y(1:(first-1),:);Y((last+1):end,:)];
        
        first = first+testSize;
        last = last+testSize; 
        
        if (~dataFromFile) 
          % pairwise
          P = createPairwise(trainY);
          testP = createPairwise(testY);
        end

        
    % ----- Create user profile matrix -----   
    uMax = max([P(:,1);testP(:,1)]);
    itemsMax = max([P(:,2); P(:,3); testP(:,2); testP(:,3)]);
    
    u_disagree_total = 0;
    u_pr_total= 0;
            
    if (~dataFromFile)   
        % user profile matrix
        u = sparse([],[],[],uMax, itemsMax);
        
        tempUserP = [];
        r_user = [];
        
  
     %get pairs for each user
        for i = 1:uMax           
            tempUserP = P(P(:,1)==i,:);
            
            if ~isempty(tempUserP)
            
                %sort using pagerank, add to user matrix
                r_user = pairwisePageRank(tempUserP);
                rs = sparse(r_user(:,1)');
                u(i,1:length(rs)) = rs;
                
                %calculate pairwise disagreements
                if (calculateDis)           
                  u_disagree = calculateDisagreements (tempUserP, r_user);
                  u_disagree_total = u_disagree_total + u_disagree;
                  u_pr_total= length(tempUserP(:,1)) + u_pr_total;
                end 
            end
            
            tempUserP = [];
            r_user = [];
        end
    end
    
    
      
    % ----- Get Test Values -----
    
    disagree_total = 0;
    pr_total= 0;
    
    % loop through each of the test users
    testusers = unique(testP(:,1));
    for x=1:length(testusers),
        activeUser = testusers(x);
              
        if (activeUser ~= 0) 
            
            ratedItems = trainY(trainY(:,1)==activeUser, 2);
            
            sim = computeSimilarities(activeUser,u);
            
            if any(sim)
                
                sim(activeUser)=-1;            
                [s,indx]=sort(sim,'descend');
                
                %most similar neighbours
                neighbours = indx(1:k);
                neighbours = neighbours(sim(neighbours)>0);
                
                %highest rated items by neighbours
                neighborP = P(ismember(P(:,1),neighbours),:);
                R_neighbour = pairwisePageRank(neighborP);
                
                %calculate pairwise disagreements
                if (calculateDis)           
                  disagree = calculateDisagreements (neighborP, R_neighbour);
                  disagree_total = disagree_total + disagree;
                  pr_total= length(neighborP(:,1)) + pr_total;
                end 
                
                %remove rated items from rec
                R_neighbour(ratedItems)=-1;
                              
                [sortedR,ind] = sort(R_neighbour,'descend');
                recommendedItems = ind(1:N) ;
                
                
                % ----- Evaluate -----
                
                % items actually liked by user
                actualItems = testY(testY(:,1)==activeUser,:); 
                actualItems = actualItems((actualItems(:,3) >= 4),2);
                      
                % common items between actual and recommended lists
                commonItems = intersect(actualItems, recommendedItems);
                
                % calculate precision and recall of lists
                if length(recommendedItems) ~= 0
                    precision =  length(commonItems) / length(recommendedItems);
                    
                    prec_count++;
                    
                else
                    precision = 0;
                end
                
                if length(actualItems) ~= 0
                    recall = length(commonItems) / length(actualItems);
                    recall_count++;
                else
                    recall = 0;
                end
                
                totalRecall = totalRecall + recall;
                totalPrecision = totalPrecision + precision;
                
                counter = counter+1;
                
            end
        end
    end
    
    mean_prec = totalPrecision/prec_count
    mean_recall = totalRecall/recall_count
    
    % ----- Print Results -----
    
    if (calculateDis) 
      if (pr_total ~= 0)
      fprintf('Total NB Disagreements: %f, Percent: %f\n', disagree_total, disagree_total/pr_total );  
      end
      
      if (u_pr_total ~= 0)
      fprintf('Total User Disagreements: %f, Percent: %f\n\n', u_disagree_total, u_disagree_total/u_pr_total );  
      end     
   end 
    
    fprintf('Total Precision: %f, Total Recall: %f\n', totalPrecision, totalRecall );
    
    if counter ~= 0
        percentPrecision = totalPrecision / counter;
        percentRecall = totalRecall /counter;
        fprintf('Percent Precision: %f, Percent Recall: %f\n', percentPrecision, percentRecall );
        fscore = 2 * (percentRecall * percentPrecision)/(percentRecall + percentPrecision);
        fprintf('F1 Score: %f \n', fscore );
    end
    
    fprintf('Amount Total Ratings: %i , Amount Pairwise: %i \n', length(Y), length(P) );
    fprintf('Amount Train Users: %i, Amount Test Users: %i \n', length(unique(P(:,1))),  length(testusers));

    tElapsed=toc(tStart);
    fprintf('Runtime Total: %f, Runtime Per Iteration: %f\n', tElapsed, tElapsed/i_it );
    
    if length(testusers) ~= 0
      fprintf('Runtime Per User: %f\n\n',  (tElapsed/i_it)/length(testusers) );
    end
    
   S = load('test.mat','c')
   Comp_num = struct2cell(S)
  ArrayPlot(i_it,1) = Comp_num;
  ArrayPlot(i_it,2) = mean_prec;
  RecallPlot(i_it,1) = Comp_num;
  RecallPlot(i_it,2) = mean_recall;
  
    
    fflush(stdout);
    
      
end %cross validaton loop

celldisp (ArrayPlot, "ArrayPlot")
x = ArrayPlot(:,1)
y = ArrayPlot(:,2)
a = cell2mat(x)
b = cell2mat(y)

plot(sort(a),sort(b))

celldisp (RecallPlot, "RecallPlot")
c = RecallPlot(:,1)
d = RecallPlot(:,2)
results = generateData(a,b)
#a = cell2mat(c)
#b = cell2mat(d)

#plot(sort(e),sort(f))

% Compute similarities between users
function sim=computeSimilarities(user,userSet)
user_row = userSet(user,:);
sim = userSet*user_row';



