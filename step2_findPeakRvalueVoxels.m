clear all; close all; clc;

%% loading part
tmp = load_untouch_nii('ROIs_p_005_3dClustSim_NC_FSL_rValue.nii.nii');
img = tmp.img;

tmp2 = load_untouch_nii('/home/dzhang/workPrograms/BNUproject/matlab codes/atlas/MNI152_T1_2mm_brain.nii');
MRI2MNI_matrix = [tmp.hdr.hist.srow_x; tmp.hdr.hist.srow_y; tmp.hdr.hist.srow_z];    %% 3x4

tmpAAL = load_untouch_nii('/home/dzhang/workPrograms/BNUproject/matlab codes/atlas/aal_MNI152.nii');
imgAAL = tmpAAL.img;


tmpP = load_untouch_nii('ROIs_p_value_NC_FSL.nii');
tmpP = tmpP.img;


%% overlapping part
BW = double(abs(img)>0);
[L,NUM] = bwlabeln(BW,26);

howmany = [];
count = 1;
for p = 1:NUM
   ROIidx = find(L(:)==p);
   voxelNum = length(ROIidx);
   RidxArray = img(ROIidx);
   [C1 C2 C3] = ind2sub(size(L), ROIidx);
   
   maxRvalue = max(abs(RidxArray));
   idxPeakInCluster = find(abs(RidxArray)==maxRvalue);

   nodes{count}.MRIcoordPeak= [C1(idxPeakInCluster) C2(idxPeakInCluster) C3(idxPeakInCluster)];
   nodes{count}.MNIcoordPeak =  [(nodes{count}.MRIcoordPeak-1) 1]*MRI2MNI_matrix';
   nodes{count}.AALIdxPeak = imgAAL(ROIidx(idxPeakInCluster));
   nodes{count}.rvalue = RidxArray(idxPeakInCluster);
   nodes{count}.Pvalue = tmpP(ROIidx(idxPeakInCluster));
   
   count = count + 1;
end

save('nodes_peak', 'nodes')


