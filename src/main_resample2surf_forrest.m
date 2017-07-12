clc;clear cll;close all;
addpath(genpath('/home/ajoshi/coding_ground/svreg/src'))
addpath(genpath('/home/ajoshi/coding_ground/svreg/3rdParty'))


l=dir('/deneb_disk/studyforrest/sub*');

for subno = 1:length(l)
    fname = l(subno).name;
    if exist(['/deneb_disk/studyforrest/',fname,'/fmrit_reduce3_v2.mat'],'file')
        subno
        continue;
    end
    if ~exist(['/deneb_disk/studyforrest/',fname,'/func/rest_res2standard.nii.gz'],'file')
        continue;
    end

    v=load_nii_BIG_Lab(['/deneb_disk/studyforrest/',fname,'/func/rest_res2standard.nii.gz']);
    sl=readdfs(['/deneb_disk/studyforrest/',fname,'/anat/BrainSuite/mri2mni.left.mid.cortex.svreg.dfs']);
    sr=readdfs(['/deneb_disk/studyforrest/',fname,'/anat/BrainSuite/mri2mni.right.mid.cortex.svreg.dfs']);
    al=readdfs(['/deneb_disk/studyforrest/',fname,'/anat/BrainSuite/atlas.left.mid.cortex.svreg.dfs']);
    ar=readdfs(['/deneb_disk/studyforrest/',fname,'/anat/BrainSuite/atlas.right.mid.cortex.svreg.dfs']);

    datal=zeros(length(sl.vertices),size(v.img,4));
    datar=zeros(length(sr.vertices),size(v.img,4));
    datal_atlas=zeros(length(al.vertices),size(v.img,4));
    datar_atlas=zeros(length(ar.vertices),size(v.img,4));

    res=v.hdr.dime.pixdim(2:4);
    vimg=double(v.img);
    parfor j=1:size(v.img,4)
        datal(:,j)=interp3(vimg(:,:,:,j), sl.vertices(:,2)/res(2) + 1,sl.vertices(:,1)/res(1) + 1, sl.vertices(:,3)/res(3) + 1);
        datar(:,j)=interp3(vimg(:,:,:,j), sr.vertices(:,2)/res(2) + 1,sr.vertices(:,1)/res(1) + 1, sr.vertices(:,3)/res(3) + 1);
    end

    v1=var(datal,[],2);
    v2=var(datar,[],2);
    sl2=sl; v1=(v1==0); ind=(sum(v1(sl2.faces),2)>0); sl2.faces(ind,:)=[];[sl2,locl]=myclean_patch_cc(sl2);
    sr2=sr; v2=(v2==0); ind=(sum(v2(sr2.faces),2)>0); sr2.faces(ind,:)=[];[sr2,locr]=myclean_patch_cc(sr2);

    parfor j=1:size(v.img,4)
        datal_atlas(:,j)=map_data_flatmap(sl2,datal(locl,j),al);
        datar_atlas(:,j)=map_data_flatmap(sr2,datar(locr,j),ar);
        fprintf('%d,',j);
    end

    save(['/deneb_disk/studyforrest/',fname,'/anat/BrainSuite/fmri_surf_dat_v2.mat'],'datal_atlas','datar_atlas','datal','datar');
    subno

end



