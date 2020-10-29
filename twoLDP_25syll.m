function twoLDP_25syll(refDataPath, testdataPath)

%     refDataPath = '/data/RINI/Rini_bckp/timit_data/Reference_Sa1.mat';
%     testdataPath = '/data/RINI/Rini_bckp/timit_data/my_dtw_sa1.mat';
    
    ref = load(refDataPath);
    referData = ref.best_template;
    test = load(testdataPath);
    testDataTotal = test.ref_template_sa1_init;
    
    sizeOfReferData = size(referData);
    sizeOfTestDataTotal = size(testDataTotal);
    noOfSyllable = sizeOfReferData(2);
    noOfTestData = size(testDataTotal,1);
    
    Acc=zeros(noOfTestData);
    
    for testDataNum = sizeOfTestDataTotal(1)-noOfTestData+1 : sizeOfTestDataTotal(1)
        testData = testDataTotal(testDataNum,:);

        %concatenating the test data
        testDataConcatenated = testData(1);
        testDataConcatenated = cell2mat(testDataConcatenated);
        for i = 2:sizeOfReferData(2)
            testDataConcatenated = [testDataConcatenated cell2mat(testData(i))];
        end
        sizeOftestDataConcatenated = size(testDataConcatenated);
        M = sizeOftestDataConcatenated(2);
        %pp = testDataConcatenated.shape
        D_cap = ones(M,M,noOfSyllable)*Inf;
        
        
      %Finding D_cap matrix
        for v = 1:noOfSyllable
            rv = referData(1,v);
            rv = cell2mat(rv);
            sizeOfRV = size(rv);
            N = sizeOfRV(2);
            for b = 1:M
                e1 = b + floor(N/2);
                e2 = b + 2*N;
                for e = min(e1,M-1):min(e2,M)
                    testVector = testDataConcatenated(:,b:e);
                    %euclidean_norm = lambda testVector, rv: np.abs(testVector - rv)
                    d = dtw(testVector, rv);%, dist=euclidean_norm)
                    D_cap(b,e,v) = d;
                end
            %disp("v: "+num2str(v)+" b: "+num2str(b));    
            end
            disp("v: "+num2str(v)+" b: "+num2str(b));
        end 
        disp("v: "+num2str(v)+" b: "+num2str(b));
    
        D_tilda = ones(M,M)*Inf;
        N_tilda = ones(M,M)*Inf;
        for b = 1:M
            for e = 1:M
                for v = 1:noOfSyllable
                    if D_tilda(b,e) >= D_cap(b,e,v)
                        D_tilda(b,e) = D_cap(b,e,v);
                        N_tilda(b,e) = v;
                    end
                end
            end
        end
        %Initializing the D_bar matrix
        D_bar = ones(M,noOfSyllable)*Inf;
        N_bar = ones(M,noOfSyllable)*Inf;

        %finding the D1_bar Matrix
        for iter = 1:M
            D_bar(iter,1) = D_tilda(1,iter);
        end
        %finding the Dl_bar Matrices
        for v = 2:noOfSyllable
            for e = v+1:M
                for b = 2:e-1
                    if((D_tilda(b,e)+D_bar(b-1,v-1)) <= D_bar(e,v))
                       D_bar(e,v) = (D_tilda(b,e)+D_bar(b-1,v-1));
                       N_bar(e,v) = b;
                    end
                end
            end
        end

%         noOfSy = 2;
        [x, noOfSyllableFound] = min(D_bar(M,:));
        pos = ones(noOfSyllableFound);

        pos(noOfSyllableFound,1) = M;

        for i = noOfSyllableFound-1:-1:1
            pos(i) = N_bar(pos(i+1),i+1);
        end

        result = ones(M,1);
        groundTruth = ones(M,1);
        start = 1;
        i=1;
        while i<noOfSyllableFound
            endd = pos(i);
            for j = start:endd
                result(j) = N_tilda(start,endd);
            end
            start = endd+1;
            i = i+1;
        end

        lengthReferData = ones(sizeOfReferData(2),1);
        lengthTestData = zeros(sizeOfReferData(2),1);
        lengthTestDataActual = zeros(sizeOfReferData(2),1);
        %concatenating the refer data
        referDataConcatenated = referData(1);
        referDataConcatenated = cell2mat(referDataConcatenated);
        lengthReferData(1,1) = size(cell2mat(referData(1)),2);
        
        for i = 1:sizeOfReferData(2)
             lengthTestDataActual(i) = size(cell2mat(testData(i)),2);
        end
        
        for i = 2:sizeOfReferData(2)
            referDataConcatenated = [referDataConcatenated cell2mat(referData(i))];
            lengthReferData(i,1) = size(cell2mat(referData(i)),2) + lengthReferData(i-1,1);
        end
        [dist Dref Dtest] = dtw(referDataConcatenated, testDataConcatenated);
        j=1;
        for i = 1 : length(Dref)
            if Dref(i) == lengthReferData(j)+1;
                if j ~= 1
                    lengthTestData(j) = Dtest(i-1) - sum(lengthTestData);
                else
                    lengthTestData(j) = Dtest(i-1);
                end
                j= j+1;
            end

        end
        lengthTestData(j) = Dtest(i-1)- sum(lengthTestData)+1;
%         start = 1;
%         for it = 1 : length(lengthTestData)
%             for ik = start : lengthTestData(it)+start-1
%                 groundTruth(ik,1) = it;
%             end
%             start = start + lengthTestData(it);
%         end
        
        start = 1;
        for it = 1 : length(lengthTestDataActual)
            if isempty(testData{it})
                continue
            else
                for ik = start : lengthTestDataActual(it)+start-1
                    groundTruthActual(ik,1) = it;
                end
            end
            start = start + lengthTestDataActual(it);
        end
%         count =0;
%         for i = 1 : M
%         	if result(i)==groundTruth(i)
%         		count = count + 1;
%             elseif result(i) == 1 && groundTruth(i) == 15
%         		count = count + 1;
%             elseif result(i) == 15 && groundTruth(i) == 1
%         		count = count + 1;
%             end
%         end
        
        countActual =0;
        for i = 1 : M
            if result(i)==groundTruthActual(i)
                countActual = countActual + 1;
            elseif result(i) == 1 && (groundTruthActual(i) == 15 || groundTruthActual(i) == 16 || groundTruthActual(i) == 29 )
                countActual = countActual + 1;
            elseif result(i) == 15 && (groundTruthActual(i) == 1 || groundTruthActual(i) == 16 || groundTruthActual(i) == 29 )
                countActual = countActual + 1;
            elseif result(i) == 16 && (groundTruthActual(i) == 15 || groundTruthActual(i) == 1 || groundTruthActual(i) == 29 )
                countActual = countActual + 1;
            elseif result(i) == 29 && (groundTruthActual(i) == 15 || groundTruthActual(i) == 16 || groundTruthActual(i) == 1 )
                countActual = countActual + 1;
            end
        end

%         disp("Accuracy Using Calculated Ground Truth: " + (count)/M*100 + "%");
        disp("Accuracy Using Known Ground Truth: " + (countActual)/M*100 + "%");
        Acc(testDataNum)=(countActual)/M*100;
    end
    
    disp("avg accuracy over trials is " + mean(Acc) + "%");
end