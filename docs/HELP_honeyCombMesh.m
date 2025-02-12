%% honeyCombMesh
% Below is a demonstration of the features of the |honeyCombMesh| function

%%
clear; close all; clc;

%%
% Plot settings
fontSize=15;
lineWidth1=3;
faceAlpha1=0.9;

%% 
% Control parameters

%Desired mesh point spacing
pointSpacing=2;

%Mesh region extrema
maxV=[10 10];
minV=[-10 -10];

%% CREATING A HONEY-COMB MESH

[F,V]=honeyCombMesh(minV,maxV,pointSpacing);

%%
% Plottting model

C=rand(size(F,1),1); %Random color for visualization

cFigure; hold on;
title('The honey-comb mesh','FontSize',fontSize);
gpatch(F,V,C,'k',1,lineWidth1);
% patchNormPlot(F,V);
colormap autumn; 
axisGeom(gca,fontSize);
drawnow;

%% 
%
% <<gibbVerySmall.gif>>
% 
% _*GIBBON*_ 
% <www.gibboncode.org>
% 
% _Kevin Mattheus Moerman_, <gibbon.toolbox@gmail.com>
 
%% 
% _*GIBBON footer text*_ 
% 
% License: <https://github.com/gibbonCode/GIBBON/blob/master/LICENSE>
% 
% GIBBON: The Geometry and Image-based Bioengineering add-On. A toolbox for
% image segmentation, image-based modeling, meshing, and finite element
% analysis.
% 
% Copyright (C) 2019  Kevin Mattheus Moerman
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
