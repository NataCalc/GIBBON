%% DEMO_FEBio_skin_sphere_indentation_tet10
% Below is a demonstration for: 
% 
% * The creation of an FEBio model for spherical indentation
% * Running an FEBio job with MATLAB
% * Importing FEBio results into MATLAB

%%

clear; close all; clc; 

%%
% Plot settings
figColor='w'; figColorDef='white';
fontSize=15;
faceAlpha1=0.8;
faceAlpha2=1;
edgeColor=0.25*ones(1,3);
edgeWidth=1.5;
markerSize1=25;

%%
% Control parameters

% path names
filePath=mfilename('fullpath');
savePath=fullfile(fileparts(filePath),'data','temp');

modelName=fullfile(savePath,'tempModel');

%Specifying dimensions and number of elements
sampleWidth=5;
sampleThickness=5; 
sampleHeight=3;
pointSpacing=0.75;

numElementsWidth=round(sampleWidth/pointSpacing);
numElementsThickness=round(sampleThickness/pointSpacing);
numElementsHeight=round(sampleHeight/pointSpacing);

contactInitialOffset=0.05;

nRefine=3; 
sphereRadius=sampleWidth/4;
sphereDisplacement=sphereRadius;%sampleHeight-(sampleHeight.*0.7);

%% Creating a meshed box (4-node tetrahedral elements)

boxDim=[sampleWidth sampleThickness sampleHeight]; %Dimensions
boxEl=[numElementsWidth numElementsThickness numElementsHeight]; %Number of elements

[Fq,Vq,faceBoundaryMarker_q]=quadBox(boxDim,boxEl);

%%
% Mesh using tetgen

[regionA]=tetVolMeanEst(Fq,Vq); %Volume for regular tets

stringOpt='-pq1.2AaYQ';
smeshName=[modelName,'.smesh'];

smeshStruct.stringOpt=stringOpt;
smeshStruct.Faces=Fq;
smeshStruct.Nodes=Vq;
smeshStruct.holePoints=[];
smeshStruct.faceBoundaryMarker=faceBoundaryMarker_q; %Face boundary markers
smeshStruct.regionPoints=[0 0 0]; %region points
smeshStruct.regionA=regionA;
smeshStruct.minRegionMarker=2; %Minimum region marker
smeshStruct.smeshName=smeshName;

[meshOutput]=runTetGenSmesh(smeshStruct); %Run tetGen 

%% 
% Access model element and patch data
% F1=meshOutput.faces;
V1=meshOutput.nodes;
C1=meshOutput.faceMaterialID;
E1=meshOutput.elements;
Fb1=meshOutput.facesBoundary;
faceBoundaryMarker=meshOutput.boundaryMarker;

%% Convert to tet10 

[E1,V1,~,ind_uni_2]=tet4_tet10(E1,V1,{});
[F1,Cs]=element2patch(E1,[],'tet10');

%Get boundary faces
Fb1=ind_uni_2(Fb1); %Fixing indices for Fb1 into V1

faceBoundaryRange=sort(unique(faceBoundaryMarker(:)));
faceBoundaryMarker_tet10=zeros(size(F1,1),1);
for q=1:1:numel(faceBoundaryRange)    
    logicMember=ismember(F1,Fb1(faceBoundaryMarker==faceBoundaryRange(q),:));
    logicBoundary=sum(logicMember,2)==3;    
    faceBoundaryMarker_tet10(logicBoundary)=faceBoundaryRange(q);
end

logicBoundary=faceBoundaryMarker_tet10>0;
faceBoundaryMarker=faceBoundaryMarker_tet10(logicBoundary);
Fb1=F1(logicBoundary,:);

%% CREATING MESHED SPHERE

[E2,V2,~]=geoSphere(nRefine,sphereRadius); 

%Offset indentor
minZ=min(V2(:,3));
V2(:,3)=V2(:,3)-minZ+(sampleHeight/2)+contactInitialOffset;

%%
% Plotting surface models
hf=figuremax(figColor,figColorDef);
title('Model surfaces','FontSize',fontSize);
xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
hold on;

patch('Faces',Fb1,'Vertices',V1,'FaceColor','flat','CData',faceBoundaryMarker,'FaceAlpha',faceAlpha1,'lineWidth',edgeWidth,'edgeColor',edgeColor,'Marker','.','MarkerSize',markerSize1);

patch('Faces',E2,'Vertices',V2,'FaceColor','r','FaceAlpha',faceAlpha1,'lineWidth',edgeWidth,'edgeColor',edgeColor);

colormap(jet(6)); colorbar; 
set(gca,'FontSize',fontSize);
view(3); axis tight;  axis equal;  grid on;
drawnow; 

%% MERGING NODE SETS
V=[V1;V2;]; %Nodes
E2=E2+size(V1,1);

%%
% Plotting surface models
hf=figuremax(figColor,figColorDef);
title('Merged node sets','FontSize',fontSize);
xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
hold on;
patch('Faces',Fb1,'Vertices',V,'FaceColor','b','FaceAlpha',faceAlpha1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
patch('Faces',E2,'Vertices',V,'FaceColor','r','FaceAlpha',faceAlpha1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
colormap(jet(6)); colorbar; 
set(gca,'FontSize',fontSize);
view(3); axis tight;  axis equal;  grid on;
drawnow; 

%% Define contact surfaces

Fc1=E2;

logicContactSurf1=faceBoundaryMarker==2;
Fc2=fliplr(Fb1(logicContactSurf1,:));

% Plotting surface models
hf=figuremax(figColor,figColorDef);
title('Contact sets','FontSize',fontSize);
xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
hold on;
patch('Faces',Fb1,'Vertices',V,'FaceColor','b','FaceAlpha',0.2,'edgeColor','none');

patch('Faces',Fc1,'Vertices',V,'FaceColor','g','FaceAlpha',1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
[hp]=patchNormPlot(Fc1,V,pointSpacing/2);

patch('Faces',Fc2,'Vertices',V,'FaceColor','r','FaceAlpha',1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
[hp]=patchNormPlot(Fc2,V,pointSpacing/2);

set(gca,'FontSize',fontSize);
view(3); axis tight;  axis equal;  grid on;
drawnow; 

%% Create shell layer based on contact layer 
%Convert tri6 boundary faces to 
[Fc2_shell]=tri6_subtri3(Fc2,V);

%%
% Plotting surface models
hf=figuremax(figColor,figColorDef);
title('Shell layer','FontSize',fontSize);
xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
hold on;
patch('Faces',Fb1,'Vertices',V,'FaceColor','b','FaceAlpha',0.2,'edgeColor','k');

patch('Faces',Fc1,'Vertices',V,'FaceColor','g','FaceAlpha',1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
% [hp]=patchNormPlot(Fc1,V,pointSpacing/2);

patch('Faces',Fc2_shell,'Vertices',V,'FaceColor','r','FaceAlpha',1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
[hp]=patchNormPlot(Fc2_shell,V,pointSpacing/2);

set(gca,'FontSize',fontSize);
view(3); axis tight;  axis equal;  grid on;
drawnow; 

%% DEFINE BC's

%Supported nodes
logicRigid=faceBoundaryMarker==1;
Fr=Fb1(logicRigid,:);
bcRigidList=unique(Fr(:));

%Prescribed displacement nodes
bcConstraintPrescribeList=unique(E1(:));
bcPrescribeMagnitudes=[0 0 -(sphereDisplacement+contactInitialOffset)];

%%
% Visualize BC's
hf=figuremax(figColor,figColorDef);
title('Complete model','FontSize',fontSize);
xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
hold on;

patch('Faces',Fb1,'Vertices',V,'FaceColor','b','FaceAlpha',faceAlpha1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
patch('Faces',E2,'Vertices',V,'FaceColor','r','FaceAlpha',faceAlpha1,'lineWidth',edgeWidth,'edgeColor',edgeColor);
patch('Faces',Fc2,'Vertices',V,'FaceColor','g','FaceAlpha',faceAlpha1,'lineWidth',edgeWidth,'edgeColor',edgeColor);

plotV(V(bcRigidList,:),'k.','MarkerSize',markerSize1);
set(gca,'FontSize',fontSize);

view(3); axis tight;  axis equal;  grid on;
drawnow; 

%% CONSTRUCTING FEB MODEL

FEB_struct.febio_spec.version='2.0';
FEB_struct.Module.Type='solid';

% Defining file names
FEB_struct.run_filename=[modelName,'.feb']; %FEB file name
FEB_struct.run_logname=[modelName,'.txt']; %FEBio log file name

%Creating FEB_struct
FEB_struct.Geometry.Nodes=V;
FEB_struct.Geometry.Elements={E1  E2 Fc2_shell}; %The element sets
FEB_struct.Geometry.ElementType={'tet10','tri3','tri3'}; %The element types
FEB_struct.Geometry.ElementMat={[1*ones(1,size(E1,1))]; [2*ones(1,size(E2,1))]; [3*ones(1,size(Fc2,1))];};
indentorShellThickness=0.01;
skinShellThickness=0.01;
FEB_struct.Geometry.ElementData.Thickness=[indentorShellThickness*ones(size(E2,1),1); skinShellThickness*ones(size(Fc2,1),1)];
FEB_struct.Geometry.ElementData.IndicesForThickness=[ (size(E1,1)+1):1:(size(E1,1)+size(E2,1)) (size(E1,1)+size(E2,1)+1):1:(size(E1,1)+size(E2,1)+size(Fc2,1))];
FEB_struct.Geometry.ElementsPartName={'Block','Sphere','Skin'};

% DEFINING MATERIALS

%Material 1 uncoupled hyperelastic
c1=1e-3;
m1=12;
k=1e3*c1;
FEB_struct.Materials{1}.Type='Ogden';
FEB_struct.Materials{1}.Properties={'c1','m1','k'};
FEB_struct.Materials{1}.Values={c1,m1,k};

%Material 2 Rigid sphere
FEB_struct.Materials{2}.Type='rigid body';
FEB_struct.Materials{2}.Properties={'density','center_of_mass'};
FEB_struct.Materials{2}.Values={1,[0,0,0]};

%Material 3 uncoupled hyperelastic
c1=1e-3*5;
m1=12;
k=1e3*c1;
FEB_struct.Materials{3}.Type='Ogden';
FEB_struct.Materials{3}.Properties={'c1','m1','k'};
FEB_struct.Materials{3}.Values={c1,m1,k};

%Control sections
FEB_struct.Control.AnalysisType='static';
FEB_struct.Control.Properties={'time_steps','step_size',...
    'max_refs','max_ups',...
    'dtol','etol','rtol','lstol'};
FEB_struct.Control.Values={40,0.025,...
    25,5,...
    0.001,0.01,0,0.9};
FEB_struct.Control.TimeStepperProperties={'dtmin','dtmax','max_retries','opt_iter','aggressiveness'};
FEB_struct.Control.TimeStepperValues={1e-4,0.025,5,15,1};

%Defining surfaces
FEB_struct.Geometry.Surface{1}.Set=Fc1;
FEB_struct.Geometry.Surface{1}.Type='tri3';
FEB_struct.Geometry.Surface{1}.Name='Contact_master';

FEB_struct.Geometry.Surface{2}.Set=Fc2;
FEB_struct.Geometry.Surface{2}.Type='tri6';
FEB_struct.Geometry.Surface{2}.Name='Contact_slave';

%Defining node sets
FEB_struct.Geometry.NodeSet{1}.Set=bcRigidList;
FEB_struct.Geometry.NodeSet{1}.Name='bcRigidList';

%Adding BC information
FEB_struct.Boundary.Fix{1}.bc='x';
FEB_struct.Boundary.Fix{1}.SetName=FEB_struct.Geometry.NodeSet{1}.Name;
FEB_struct.Boundary.Fix{2}.bc='y';
FEB_struct.Boundary.Fix{2}.SetName=FEB_struct.Geometry.NodeSet{1}.Name;
FEB_struct.Boundary.Fix{3}.bc='z';
FEB_struct.Boundary.Fix{3}.SetName=FEB_struct.Geometry.NodeSet{1}.Name;

%Constraint section
FEB_struct.Constraints{1}.RigidId=2;

FEB_struct.Constraints{1}.Prescribe{1}.bc='x';
FEB_struct.Constraints{1}.Prescribe{1}.Scale=bcPrescribeMagnitudes(1);
FEB_struct.Constraints{1}.Prescribe{1}.lc=1;

FEB_struct.Constraints{1}.Prescribe{2}.bc='y';
FEB_struct.Constraints{1}.Prescribe{2}.Scale=bcPrescribeMagnitudes(2);
FEB_struct.Constraints{1}.Prescribe{2}.lc=1;

FEB_struct.Constraints{1}.Prescribe{3}.bc='z';
FEB_struct.Constraints{1}.Prescribe{3}.Scale=bcPrescribeMagnitudes(3);
FEB_struct.Constraints{1}.Prescribe{3}.lc=1;

FEB_struct.Constraints{1}.Fix{1}.bc='Rx';
FEB_struct.Constraints{1}.Fix{2}.bc='Ry';
FEB_struct.Constraints{1}.Fix{3}.bc='Rz';

%Adding contact information
FEB_struct.Contact{1}.Surface{1}.SetName=FEB_struct.Geometry.Surface{1}.Name;
FEB_struct.Contact{1}.Surface{1}.Type='master';

FEB_struct.Contact{1}.Surface{2}.SetName=FEB_struct.Geometry.Surface{2}.Name;
FEB_struct.Contact{1}.Surface{2}.Type='slave';

FEB_struct.Contact{1}.Type='facet-to-facet sliding';
FEB_struct.Contact{1}.Properties={'penalty','auto_penalty','two_pass',...
                                          'laugon','tolerance',...
                                          'gaptol','minaug','maxaug',...
                                          'fric_coeff','fric_penalty',...
                                          'seg_up',...
                                          'search_tol'};
FEB_struct.Contact{1}.Values={100,1,0,...
                                      0,0.05,...
                                      0,0,10,...
                                      0,1,...
                                      0,...
                                      0.05};

%Adding output requests
FEB_struct.Output.VarTypes={'displacement','stress','relative volume','shell thickness'};

%Specify log file output
run_node_output_name=[FEB_struct.run_filename(1:end-4),'_node_out.txt'];
FEB_struct.run_output_names={run_node_output_name};
FEB_struct.output_types={'node_data'};
FEB_struct.data_types={'ux;uy;uz'};

%Load curves
FEB_struct.LoadData.LoadCurves.id=1;
FEB_struct.LoadData.LoadCurves.type={'linear'};
FEB_struct.LoadData.LoadCurves.loadPoints={[0 0;1 1];};

%% SAVING .FEB FILE

FEB_struct.disp_opt=0; %Display waitbars option
febStruct2febFile(FEB_struct);

%% RUNNING FEBIO JOB

% FEBioRunStruct.FEBioPath='C:\Program Files\febio-2.1.1\bin\FEBio2.exe';
FEBioRunStruct.run_filename=FEB_struct.run_filename;
FEBioRunStruct.run_logname=FEB_struct.run_logname;
FEBioRunStruct.disp_on=1;
FEBioRunStruct.disp_log_on=1;
FEBioRunStruct.runMode='external';%'internal';
FEBioRunStruct.t_check=0.25; %Time for checking log file (dont set too small)
FEBioRunStruct.maxtpi=1e99; %Max analysis time
FEBioRunStruct.maxLogCheckTime=3; %Max log file checking time

[runFlag]=runMonitorFEBio(FEBioRunStruct);%START FEBio NOW!!!!!!!!

%%
if runFlag==1 %i.e. a succesful run
    
    %IMPORTING NODAL DISPLACEMENT RESULTS
    % Importing nodal displacements from a log file
    [~, N_disp_mat,~]=importFEBio_logfile(FEB_struct.run_output_names{1}); %Nodal displacements
    
    DN=N_disp_mat(:,2:end,end); %Final nodal displacements
    
    % CREATING NODE SET IN DEFORMED STATE
    V_def=V+DN;
    DN_magnitude=sqrt(sum(DN.^2,2));
    
 
    % Plotting the deformed model
    
    [CF]=vertexToFaceMeasure(Fb1,DN_magnitude);
    
    hf1=figuremax(figColor,figColorDef);
    title('The deformed model','FontSize',fontSize);
    xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize); hold on;
    
    hps=patch('Faces',Fb1,'Vertices',V_def,'FaceColor','flat','CData',CF);
    hps=patch('Faces',E2,'Vertices',V_def,'FaceColor',0.5*ones(1,3),'EdgeColor','none','FaceAlpha',0.25);
    
    view(3); axis tight;  axis equal;  grid on;
    colormap jet; colorbar;
    % camlight headlight;
    set(gca,'FontSize',fontSize);
    drawnow;
end

%% 
%
% <<gibbVerySmall.gif>>
% 
% _*GIBBON*_ 
% <www.gibboncode.org>
% 
% _Kevin Mattheus Moerman_, <gibbon.toolbox@gmail.com>
