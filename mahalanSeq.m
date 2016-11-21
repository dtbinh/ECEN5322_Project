function I = mahalanSeq(sample,Gauss,set)
    x = sample;
    seq = zeros(length(x),length(set)); %Sequence of coefs
        
    %Test each against the mfccs
    for ii = 1:length(set)
        %Test against each
        cov1 = Gauss{set(ii),1};
        m = Gauss{set(ii),2};

        %Find the mahalanobis vector for all of the points
        diff = bsxfun(@minus,x,m);

        %Figure out the closest mean to distribution
        seq(:,ii) = sqrt(sum((diff'*cov1^-1).*diff',2));        
    end
    
    %Get the minimum, I is the state sequence (closest distribution)
    [~,I] = min(seq,[],2);
end