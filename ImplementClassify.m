%% Use this script to test shit out

%% Generate M matrix, and MFCCs
%M = KullbackAdjacency();

%% Now, get a subset
rm = [5,5,5,5,5,5]; %Let's experiment with a subset of 25 songs, 5 from each genre
%Get the unique genres
g = {'classical','electronic','jazz_blues','metal_punk','rock_pop','world'};
n = length(M);

R = zeros(sum(rm),1);
cur = 1;
for i = 1:length(g)
    ind = find(strcmp(genres,g{i}));
    
    %Now, remove rm(i) of these
    r = randi([min(ind) max(ind)],rm(i),1);
    
    %We have the indices to be removed, gotta reformat the M matrix
    R(cur:(cur-1)+rm(i)) = r;
    cur = cur + rm(i);
end

%Now, remove these colums/rows from M
Mt = M;
Mt(:,R) = [];
Mt(R,:) = [];

% New covariance, mean array
Gauss = cell(length(mfcc),2);
for i = 1:length(Gauss)
    Gauss{i,1} = cov(mfcc{i}');
    Gauss{i,2} = mean(mfcc{i},2);
end

set = 1:length(mfcc); %The total length of the set of test items
%Now, remove the test indices
set(R) = [];

%% Now, get the clustered bins using spectrum of Lsym
K = 20; %Number of bins, clusters
P = 0; %Cutoff threshold, leave it connected
states = Laplacian(Mt,K,P); %Reduced M matrix, get state space

%% Okay, using the maximum of states, time to create the transition matrices
T = cell(length(g),1);
n = max(states);
Tmin = 0.001; %Minimum transition probability

for i = 1:length(g)
    %We need to train the transistion matrix using all of the samples of
    %that genre
    T{i} = zeros(n);
    for j = 1:length(set) %Length of training set
        if strcmp(genres{j},g{i}) %See if its part of the same genre
            display(j)
            x = mfcc{set(j)};
            %Correct set to not include self
            setN = set;
            setN(j) = []; %Remove self element
            I = mahalanSeq(x,Gauss,setN); %Get the Mahalanobis sequence of similarities (will they always bin to the same place?)
            X = states(I); %Pull the bin states

            %Now, let's use to train the Markov Matrix
            T{i} = T{i} + full(sparse(X(1:end - 1) , X(2 : end),1,n,n)); %Add connections
        end
    end
    display('Next Matrix')
    display(i)
    
    sum_T = sum(T{i} , 2);
    
    %Normalize transistion matrix
    %NO zero prob allowed!
%     T{i}(T{i}==0) = Tmin;
    %Normalize once
    T{i} = (T{i}./sum_T(:,ones(1,size(T{i} , 1))));
    T{i}(isnan(T{i})) = Tmin; %Get rid of nonzero probabilities
    %Renormalize again
    T{i} = (T{i}./sum_T(:,ones(1,size(T{i} , 1))));
end

save('T.mat','T')

%% FINALLY- Time to classify genre
for i = 1:length(R)
    x = mfcc{R(i)};
    I = mahalanSeq(x,Gauss,set); %Get the Mahalanobis sequence
    
    %% First test, count the numbers of each similarity
    [genre,P] = gCount(genres,I);

    %% Let's compare it to the transistion matrix implementation
    specState = states(I);
    %Now, compute probability using the transition matrices
    
    
    %Make the confusion matrix
%     C = zeros(length(R));
end