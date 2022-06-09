function [fusion_SaliencyMap, S_nb, frameRecord] = getTopoComplexityMap(srcImg)
%% get topo-complexity map(OTS map) and topo-descriptors
% input: oringinal image
% outputs:  fusion_SaliencyMap: OTS with bias
%               S_nb: superpixels obtainded by UCM algorithm
%              frameRecord: image frame (if exists, else they are zeros and max width or hight)
%%
lamda = 8;
sel = strel('disk',1);
[sch, scw, ~] = size(srcImg);

%% --- remove frame------
[noFrameImg, frameRecord] = removeframeRBD(srcImg, 'canny');
[S_nb,ucm]= getUCM(noFrameImg); % get superpixels
ucm = ucm/max(ucm(:));
ucm = invRemoveFrame(ucm, frameRecord, sch, scw, 0);

%% generate rigions from ucm with thresholds.
ind = 0;
for lambda = 0.1:0.2:0.7
    temp_ucm = ucm>=(lambda);
    inv_temp_ucm = ~temp_ucm;
    ind = ind+1;
    edge_ucm{ind} = bwlabel(inv_temp_ucm);
    labeled_ucm{ind} = imdilate(edge_ucm{ind}, sel);
end

%% ------center bias-----------
    sig = 500; % 500
    cx = floor(scw/2);
    cy = floor(sch/2);

    temp_x = linspace(1,scw,scw);
    temp_y = linspace(1,sch,sch);

    [x, y]=meshgrid(temp_x, temp_y);
    W=exp(-((x-cx).^2+((y-cy).^2)/((sch/scw)^2))./sig.^2);
    cenBiasMap = W.*(ones(size(ucm)));
%%
    uwTopoDescriptors = {};
    topoDescriptors = zeros(4,5);

    %% remove the small region
    for ind_ucm = 1:length(labeled_ucm)
         ucmMat = labeled_ucm{ind_ucm};
         [w,h,~] = size(ucmMat);
         
         rigIndex = unique(ucmMat);
         for idx = 1:length(rigIndex)
             mask_rm = zeros(w,h); 
             rigLoc = find (ucmMat == rigIndex(idx));
             mask_rm(rigLoc) = 1;       
                if length(rigLoc) < 1/500*w*h  % ignore small regions
                    surRigion =unique(ucmMat(find(imdilate(mask_rm, sel) - mask_rm))); 
                    
                    ucmMat(rigLoc) = surRigion(randperm(length(surRigion),1));
                end
        end
         labeled_ucm{ind_ucm} = ucmMat;    
         
    end
   
    clear ucmMat rigIndex rigLoc mask_rm surRigion;
    
 %% ---some claims for saliency detection--------      
    
    fusion_SaliencyMap = zeros(w,h);   
 %% -----calculation topo-descriptors------------
    for ind_ucm = 1:length(labeled_ucm)
        i = [1,2,3,4,5];
        b = [1,0,0,0,0];
        c = [0,0,0,0,0];
        a = [0,0,0,0,0]; % the default topoDescriptors, we ignore c here;
        
        SaliencyMap = 0.1*ones(w,h);
        Inner_SaliencyMap = ones(w,h);       
        ucmMat = labeled_ucm{ind_ucm};
%         figure, imshow(ucmMat,[]),title(num2str(ind_ucm));
        rigIndex = unique(ucmMat);
        isUsedRig = zeros(length(rigIndex),1); % 
        len_rig = length(rigIndex);

        for idx = 1:len_rig
            
            if isUsedRig(idx)
                continue;
            else 
            rigLoc = find (ucmMat == rigIndex(idx));
            
            [x, y] = ind2sub(size(ucmMat), rigLoc);
            if min(x) == 1 || max(x) == w || min(y) == 1 || max(y) == h
                Inner_SaliencyMap(rigLoc) = 0.2; % 20% weight of topo-complexity of rigions 
            end
%             figure,imshow(Inner_SaliencyMap);
            
            mask_i =zeros(size(ucmMat));

            mask_i(rigLoc) = 1;
            [isNest, mask_next, bNum] = FindNestArea(ucmMat, mask_i);
%             figure, imshow(mask_next,[]),title(num2str(ind_ucm)); %
            %% the 2nd

            SaliencyMap(rigLoc) = SaliencyMap(rigLoc) + 1;

            if isNest
                isUsedRig(ismember(rigIndex, bNum)) = 1;
                b(2) = b(2) + length(bNum) + 1;
                SaliencyMap(find(mask_next)) = SaliencyMap(find(mask_next)) + max(max(SaliencyMap(mask_i == 1))) + exp(-2*1); % 0.2==>exp(-2*),

            for j = 1:length(bNum)
                mask_i = zeros(size(ucmMat));
                mask_i(ucmMat == bNum(j)) = 1;
                [isNest, mask_next, bNum2] =  FindNestArea(ucmMat, mask_i);

                %% the 3rd
                if isNest
                    b(3) = b(3) + length(bNum2) + 1;
                    SaliencyMap(mask_next == 1) = SaliencyMap(mask_next == 1)  + max(max(SaliencyMap(mask_i == 1))) + exp(-2*2);% 0.2==>exp(-2*),exp(-2*2)

                for j3 = 1:length(bNum2)
                    mask_i = zeros(size(ucmMat));
                    mask_i(ucmMat == bNum2(j3)) = 1;
                    [isNest, mask_next, bNum3] =  FindNestArea(ucmMat, mask_i);

                    %% the 4th
                    if isNest
                        b(4) = b(4) + length(bNum3) + 1;
                        SaliencyMap(mask_next == 1) = SaliencyMap(mask_next == 1) + max(max(SaliencyMap(mask_i == 1))) + exp(-2*3);% 0.2==>exp(-2*),

                    for j4 = 1:length(bNum3)
                        mask_i = zeros(size(ucmMat));
                        mask_i(ucmMat == bNum3(j4)) = 1;
                        [isNest, mask_next, bNum4] = FindNestArea(ucmMat, mask_i);

                        %% the 5th
                        if isNest
                            SaliencyMap(mask_next == 1) = SaliencyMap(mask_next == 1) +  max(max(SaliencyMap(mask_i == 1))) + exp(-2*4);% 0.2==>exp(-2*)

                            b(5) = b(5) + length(bNum4) + 1;
                        end
                    end
                    else
                        b(4) = b(4)+1;
                    end

                end
                else
                    b(3) = b(3)+1;
                end

            end

            else
                b(2) = b(2)+1;
            end      
            end       
        end
        temp_b = b;
        temp_b(4) = temp_b(4) - temp_b(5); % visit too many times, so remove them ,b(4)--> 3*b(5)
        temp_b(3) = temp_b(3) - temp_b(4); % b(3)--> 2*b(4)
        temp_b(2) = temp_b(2) - temp_b(3); % b(2)--> 1*b(3)
        
        temp_b(4) = temp_b(4) - temp_b(5);
        temp_b(3) = temp_b(3) - temp_b(4); 
        
        temp_b(4) = temp_b(4) - temp_b(5);
           
        b = temp_b;
        a(1) = sum(b);
        uwTopoDescriptors{ind_ucm} = [i;b;c;a];

        SaliencyMap = SaliencyMap./(max(SaliencyMap(:))+eps);
%         FcMap = FcMap + (2./(1 + exp((0-SaliencyMap)*lamda))-1);
        SaliencyMap = Inner_SaliencyMap.*(2./(1 + exp((0.0-SaliencyMap)*lamda))-1);
   
        fusion_SaliencyMap = fusion_SaliencyMap + SaliencyMap;
%         figure,imshow(fusion_SaliencyMap,[]),title('fusion_SaliencyMap');
%         flatMap = flatMap + Inner_SaliencyMap;
    end

        thFu = unique(fusion_SaliencyMap);
        
        for ith = 2:length(thFu)        
            smallSal_Idx = find(fusion_SaliencyMap == thFu(ith));
            
            if (length(smallSal_Idx) < 0.005*w*h)
 
                fusion_SaliencyMap(smallSal_Idx) = thFu(ith - 1);
            end
        end
  %%
    fusion_SaliencyMap = (fusion_SaliencyMap-min(SaliencyMap(:)))./(max(fusion_SaliencyMap(:))-min(SaliencyMap(:))+eps);

    FlattenedData = fusion_SaliencyMap(:)'; 
    FlattenedData = 1./(1 + exp((0.5 - FlattenedData)*10));
    MappedFlattened = mapminmax(FlattenedData, 0, 1); %  normalized
    noBiasMap = reshape(MappedFlattened, size(fusion_SaliencyMap)); % no bias saliency map;
    fusion_SaliencyMap = noBiasMap.*cenBiasMap;
    clear FlattenedData  MappedFlattened thFu ucmMat
       
    %% ----topo-descriptors------------------
    for ind_topo = 1:max(ind_ucm)
        topoDescriptors = topoDescriptors + uwTopoDescriptors{ind_topo}/max(ind_ucm);
    end
