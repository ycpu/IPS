%  Indoor Positioning System Using KNN and weighted KNN
function KNN_IPS
    clc,clear;
    [training_data, training_set]=read_training('training set.csv');
    A=xlsread('training set coordinates.xlsx'); % read the coordiantes of training points
    training_coord=A;
    A=xlsread('testing set.xlsx'); % read testing set
    test_data=A(:,2:7);
    test_set=A(:,1);
    A=xlsread('testing set coordinates.xlsx'); % read the coordiantes of testing points
    test_coord=A(:,2:3);
    
    % construct the KD tree for KNN
    Mdl = KDTreeSearcher(training_data);

    NCount=120;
    dist_err_knn=zeros(1,NCount);
    dist_err_wknn=zeros(1,NCount);
    err_sum_knn=0;
    err_sum_wknn=0;
    correct_rate=0;
    k=3;
    
    for count=1:NCount % test NCount times
        %ind=floor(rand()*120+1); % randomize the testing point
        ind=count;
        newpoint = test_data(ind,:); 
            %euclidean chebychev
            [n,d] = knnsearch(Mdl,newpoint,'k',k, 'distance','euclidean'); % find the k nearest points 
            
            %Frequency table
            %tbl = tabulate(training_set(n))           
            %   Value    Count   Percent
            %       B        7     70.00
            %       A        3     30.00            
            
          if k>=2 
             get_loc_knn = mean(training_coord(ceil(n/20),:));
             get_loc_wknn = ((1./d)*training_coord(ceil(n/20),:)) / sum(1./d);
          else
             get_loc_knn = training_coord(ceil(n/20),:);
             get_loc_wknn = ((1./d)*training_coord(ceil(n/20),:)) / sum(1./d);
          end

           test_loc = test_coord(ceil(ind/20),:);

           dist_err_knn(ind) = CalcDistance(get_loc_knn, test_loc); 
           dist_err_wknn(ind) = CalcDistance(get_loc_wknn, test_loc); 
       if dist_err_knn(ind)<=2, correct_rate=correct_rate+1; end
       err_sum_knn = err_sum_knn + dist_err_knn(ind); %¡@summerize the errors of KNN
       err_sum_wknn = err_sum_wknn + dist_err_wknn(ind); %¡@summerize the errors of wKNN
    end
    %axis([xmin, xmax, ymin, ymax])
    % Computer the average correct rate
    correct_rate = correct_rate / NCount
    
    ave_err_knn = err_sum_knn / NCount
    ave_err_wknn = err_sum_wknn / NCount
   
    cdfplot(dist_err_knn)
    hold on
    cdfplot(dist_err_wknn)
    
    axis auto
%     histogram(dist_err,30)%histfit(dist_err,10,'kernel')
%     xlabel('location error (m)')
%     ylabel('frequency')
end

function euclideanDistance = CalcDistance(z1, z2) 
   euclideanDistance = sqrt((z2(1)-z1(1))^2+(z2(2)-z1(2))^2);
end

function [ C, S ] = read_training( filename )
%read_training
%   read the file of the training set from 'filename'
%   return  array 'C' and its set attribute
    fp=fopen(filename);
    B = textscan(fp, '%c,%d,%d,%d,%d,%d,%d');
    S = B{1};
    C = [B{2} B{3} B{4} B{5} B{6} B{7}];
    C=double(C);
end