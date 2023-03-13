clear all; close all; clc;


%% loading data 
load('GM_mask_in91x109x91_FSL.mat');
load -ascii VBMArray_FSL.mat ;          %% 655x92258
load('VBM_NameArray.mat');          %% 655 subjects

load('SubjectHaveAcc_NC.mat');      %% 290 subject got rs-fMRI, VBM and NC performance
load('behav_vec_Acc_NC.mat');       %% 290 subject got rs-fMRI, VBM and NC performance

[sharingID idxIn655 drop2] = findSharingName2Sets(VBM_NameArray, SubjectHaveAcc);
VBMArray_NC = VBMArray_FSL(idxIn655, :);   %% 290x92258


% load gender and age information
load('SubInfo.mat');                    %% 439 subjects

% extract subjects has  rs-fMRI, VBM, NC performance, and SubInfo
[drop1 idxIn290 idxIn439] = findSharingName2Sets(sharingID, SubInfo.ID);
behav_vec = behav_vec(idxIn290);        %% 249x1
VBMArray_NC = VBMArray_NC(idxIn290, :); %% 249x99258

gender_vec = SubInfo.Gender(idxIn439);  %% 249x1
age_vec = SubInfo.Age(idxIn439);        %% 249x1
raven_vec = SubInfo.Raven(idxIn439);    %% 249x1

VBMtotal_vec = sum(VBMArray_NC,2);      

id_vec = SubInfo.ID(idxIn439);           %% 249x1

%% correlation part 
[r_mat,p_mat] = partialcorr(VBMArray_NC, behav_vec, [age_vec gender_vec VBMtotal_vec]);        % r_mat: 92258x1, p_mat: 92258x1


img = zeros([91,109,91]);
img(GM_mask_in91x109x91) = p_mat;
tmp = load_untouch_nii('/home/dzhang/workPrograms/BNUproject/matlab codes/atlas/smwc1S0001_anat.nii');
tmp.img = img;
save_untouch_nii(tmp, 'ROIs_p_value_NC_FSL.nii');

%% method 3: 3dClustSim
% dClustSim -mask ROIs_p_value_NC.nii  -FWHM 6 -prefix ./3dClustSim/VBM_cluster_Size_NC
% p = 0.05, a = 0.01, cluster size, ThresNum = 307
voxel_idx_in92258 = find(p_mat<0.05);
ThresNum = 307;

img = zeros([91,109,91]);
img(GM_mask_in91x109x91(voxel_idx_in92258)) = r_mat(voxel_idx_in92258);

BW = double(abs(img)>0);
[L,NUM] = bwlabeln(BW,26);

tmp = load_untouch_nii('/home/dzhang/workPrograms/BNUproject/matlab codes/atlas/MNI152_T1_2mm_brain.nii');
MRI2MNI_matrix = [tmp.hdr.hist.srow_x; tmp.hdr.hist.srow_y; tmp.hdr.hist.srow_z];    %% 3x4

howmany = [];
count = 1;
for p = 1:NUM
   howmany(p) = length(find(L(:)==p));
   if howmany(p) < ThresNum
        img(find(L==p)) = 0; 
   else
      nodes{count}.ClusterSize = howmany(p);
      [C1 C2 C3] = ind2sub(size(L), find(L==p));
      nodes{count}.MRIcoord = [C1 C2 C3];
      nodes{count}.MRIcoordMean = mean(nodes{count}.MRIcoord);
      nodes{count}.MRIcoordMean = mean(nodes{count}.MRIcoord);
      nodes{count}.MNIcoordMean =  [(nodes{count}.MRIcoordMean-1) 1]*MRI2MNI_matrix';
      count = count +1;
   end
end
length(find(howmany>ThresNum))
save('nodes_NC_005','nodes');

tmp = load_untouch_nii('./anat.nii');
tmp.img = img;
save_untouch_nii(tmp, 'ROIs_p_005_3dClustSim_NC_FSL_rValue.nii');


