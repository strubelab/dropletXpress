
close all

%% MATLAB script Figure 3.
% Script written by Daniela A. García-Soriano. Modified by Ana M. Restrepo Sierra.

%% for droplets with DNA in solution

%The transmited light .tif is used to find the droplet positions on the image. Based 
%on this it then detects the intensity for each drop. Data has to have a 8-bit format. You can check that on ImajeJ-Fiji

%Transmitted light
White = tiffread('White_DNAsln.tif');
%Fluorescent channel
Black = tiffread('Black_DNAsln.tif');

%empty vector to save mean intensity values
curve_values = zeros(1,size(White,2));

%Read transmitted light data
I=White.data;

%GCA: automatic picking procedure
%Select the minumum radii. The function losses sensitivity below 5
Rmin = 20;
%Select the maximum radii
Rmax = 50;
%imfindcircles will find each droplet accordingly with the radii parameters
%given
[centers, radii, metric] = imfindcircles(I,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.9,  'Method','twostage');

%In case the function cannot find droplets, you will get a warning!
if (isempty(centers))
    h = errordlg('No rings found!', 'Auto picking error','modal');
    waitfor(h);
    close;
    return
end
    
%Screen rings to remove those too close to the edges
radLimit = 1.5*radii(:)+1;
    centersMask = (centers(:,1) - radLimit(:)) < 1;
    centersMask =  centersMask | ((centers(:,1) + radLimit(:)) > size(I,1));
    centersMask = centersMask | ((centers(:,2) - radLimit(:)) < 1);
    centersMask =  centersMask | ((centers(:,2) + radLimit(:)) > size(I,2));
    
    centers(centersMask,:) = [];
    radii(centersMask)  = [];
    metric(centersMask) = [];
    
%Draw circles. To have an idea of which droplets have been selected
h2 = figure;
imshow(I);
viscircles(centers, radii,'EdgeColor','b');
title(['N=',num2str(length(radii))]);

%Save the coordanates of each droplet
x0 = round(centers(:,1));
y0 = round(centers(:,2));
r = round(radii);

%Extract the raw intensity values from each drop in the channel.
%Read the data that corresponds to the fluorescent data
J=Black.data;
values = zeros(length(r),1);

for j = 1:1:length(r)
[W,H] = meshgrid(x0(j)-r(j):x0(j)+r(j),y0(j)-r(j):y0(j)+r(j));

values(j,1) = mean(mean(impixel(J, W, H)));
end

curve_values(i) = median(values);

values;
dropnumber_DNAsln=length(values);

% For calculating the concentration (micromolar) based on A.U
m_1=zeros(length(values),1);
for i=1:length(values)
    m=values(i);
    m_1(i)=(0.0607*m)+0.0759;
    
end

m_1;

%% For the droplets with beads

White_beads = tiffread('White_beads.tif');

I=White_beads.data;

%% Droplets pick 

%GCA: automatic picking procedure
%Select the minumum radii. The function losses sensitivity below 5
Rmin = 20;
%Select the maximum radii
Rmax = 50;
%imfindcircles will find each droplet accordingly with the radii parameters
%given
[centers1, radii1, metric1] = imfindcircles(I,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.9,  'Method','twostage');

%In case the function cannot find droplets, you will get a warning!
if (isempty(centers1))
    h1 = errordlg('No rings found!', 'Auto picking error','modal');
    waitfor(h1);
    close;
    return
end
    
%Screen rings to remove those too close to the edges
radLimit = 1.5*radii1(:)+1;
    centersMask = (centers1(:,1) - radLimit(:)) < 1;
    centersMask =  centersMask | ((centers1(:,1) + radLimit(:)) > size(I,1));
    centersMask = centersMask | ((centers1(:,2) - radLimit(:)) < 1);
    centersMask =  centersMask | ((centers1(:,2) + radLimit(:)) > size(I,2));
    
    centers1(centersMask,:) = [];
    radii1(centersMask)  = [];
    metric1(centersMask) = [];
    
%Draw circles. To have an idea of which droplets have been selected
h1 = figure;
imshow(I);
viscircles(centers1, radii1,'EdgeColor','b');
title(['N=',num2str(length(radii1))]);

%Save the coordanates of each droplet
x0 = (centers1(:,1));
y0 = (centers1(:,2));
r = (radii1);

%% Droplet detection program used for estimating were the beads are

%GCA: automatic picking procedure
%Select the minumum radii. Can lose sensitivity below 5
Rmi = 3;
%Select the maximum radii
Rma = 6;
%imfindcircles will find each droplet accordingly with the radii parameters
%given
[centers, radii, metric] = imfindcircles(I,[Rmi Rma],'ObjectPolarity','bright','Sensitivity',0.9,  'Method','twostage');

%In case the function cannot find droplets, you will get a warning!
if (isempty(centers))
    h = errordlg('No rings found!', 'Auto picking error','modal');
    waitfor(h);
    close;
    return
end
    
%Screen rings to remove those too close to the edges
radLimit = 1.5*radii(:)+1;
    centersMask = (centers(:,1) - radLimit(:)) < 1;
    centersMask =  centersMask | ((centers(:,1) + radLimit(:)) > size(I,1));
    centersMask = centersMask | ((centers(:,2) - radLimit(:)) < 1);
    centersMask =  centersMask | ((centers(:,2) + radLimit(:)) > size(I,2));
    
    centers(centersMask,:) = [];
    radii(centersMask)  = [];
    metric(centersMask) = [];
    
%Draw circles. To have an idea of which droplets have been selected
h = figure;
imshow(I);
viscircles(centers, radii,'EdgeColor','b');
title(['N=',num2str(length(radii))]);

%Save the coordanates of each identified bead
x01 = (centers(:,1));
y01 = (centers(:,2));
r01 = (radii);

%% Find the droplets that have beads inside.

A=[];
B=[];
D=[];
for i=1:length(x0);
    for j=1:length(x01);
        d = sqrt((x01(j)-x0(i))^2 + (y01(j)-y0(i))^2);
            if (( d + r01(j)) <= r(i))
                A=[A; x0(i)]; % x values
                B=[B; y0(i)]; % y values
                D=[D; r(i)]; % r values
                %C=[A B];
            end
    end
end

C=[A B D];
G=[A B];

%% Delete coordinates for droplets that have more than one bead inside.

% check for the droples that have more than one bead inside
E=[];
F=[];
for i=1:length(C(:,1))
    E=[];
    for j=1:length(C(:,1))
        if C(i,:)==C(j,:)
            E=[E; 0];
        else E=[E; 1];
        end
    end
    m=numel(E)-nnz(E);
    if m>2
        F=[F; i];
    end
end 

% convert the repeated rows in zeros
for i=F
    C(i,:)=zeros
end

% take out the rows with zeros
C1=C(any(C,2),:);
xs=(C1(:,1));
ys=(C1(:,2));
rs=(C1(:,3));
Z=[xs ys];

% draw the ones with more than one bead
h3 = figure;
imshow(I);
viscircles(G,D);

%draw the ones with just one bead
h4 = figure;
imshow(I);
viscircles(Z,rs);

%% Analyze the fluorescent channel

%Fluorescent channel
Black_beads = tiffread('Black_beads.tif');

%% Droplets with beads

%Extract the raw intensity values from each drop in the channel.
%Read the data that corresponds to the fluorescent data.
J=Black_beads.data;
values1 = zeros(length(D),1);
    
for j = 1:1:length(D)
[W,H] = meshgrid(A(j)-D(j):A(j)+D(j),B(j)-D(j):B(j)+D(j));

values1(j,1) = mean(mean(impixel(J, W, H)));
end

% For calculating the concentration (micromolar) based on A.U
m_2=zeros(length(values1),1);
for i=1:length(values1)
    m=values1(i);
    m_2(i)=(0.0607*m)+0.0759;
end

values1;
dropnumber_beads1=length(values1);

m_2;

%% Fluorescence from droplets with aproximately one bead.

%Extract the raw intensity values from each drop in the channel.
%Read the data that corresponds to the fluorescent data
J=Black_beads.data;
values1 = zeros(length(rs),1);
    
for j = 1:1:length(rs)
[W,H] = meshgrid(xs(j)-rs(j):xs(j)+rs(j),ys(j)-rs(j):ys(j)+rs(j));

values1(j,1) = mean(mean(impixel(J, W, H)));
end

% For calculating the concentration (micromolar) based on A.U
m_3=zeros(length(values1),1);
for i=1:length(values1)
    m=values1(i);
    m_3(i)=(0.0607*m)+0.0759;
end

values1;
dropnumber_beadsONE=length(values1);

m_3;

% Figure 5
figure
box on
title('Droplets mostly with only one bead')
%No beads (droplets with DNA in solution)
histogram(m_1(:,1),'binwidth',0.05,'facecolor','#000000','FaceAlpha',0.6);
hold on
%With beads (droplets with aproaximately one bead)
histogram(m_3(:,1),'binwidth',0.05,'facecolor','#00FF00','FaceAlpha',0.6);
set(gca,'yscale','log')
ylim([1 10^3])
xticks(0:0.4:1.2);
xlabel('\muM ','FontSize',25);
ylabel('log(counts)','FontSize',25);
set(gca,'fontsize',25)
print('-dpng')

