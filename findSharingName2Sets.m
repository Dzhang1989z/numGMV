%% built-in function
function [SharingName idx1 idx2 ] =  findSharingName2Sets(SubName1, SubName2)
% get sharing name from 2 sets
SharingName = intersect(SubName1, SubName2);
% get idx of the sharing name in the 2 sets
idx1 = [];
for p = 1:length(SharingName)
   idx1(end+1) = find(strcmp(SubName1, SharingName{p,1})); 
end
idx2 = [];
for p = 1:length(SharingName)
   idx2(end+1) = find(strcmp(SubName2, SharingName{p,1})); 
end
end