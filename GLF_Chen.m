function F=GLF_Chen(img,T,B,K)
% *************************************************************************
%  This function calculates the GLF feature in the difference domain for
%  median filtering (MF) detection.
%  Matlab version: 7.10.0 (2010a)
% -------------------------------------------------------------------------
%  Copyright (c) Chenglong Chen
%  All Rights Reserved.
%  Contact: c.chenglong@gmail.com
% -------------------------------------------------------------------------
%  Permission to use, copy, modify, and distribute this software for
%  educational, research and non-profit purposes, without fee, and without
%  a written agreement is hereby granted, provided that this copyright
%  notice appears in all copies. The end-user understands that the program
%  was developed for research purposes and is advised not to rely
%  exclusively on the program for any reason.
% 
%  Please do not forget to cite the appropriate publications.
% 
%  References:
% 
%  [1] Chenglong Chen, Jiangqun Ni, Rongbin Huang and Jiwu Huang.
%  Blind median filtering detection using statistics in difference domain.
%  in Proc. 14th Int. Conf. Inf. Hiding, May 2012, pp. 1-15.
% 
%  [2] Chenglong Chen, Jiangqun Ni, and Jiwu Huang.
%  Blind Detection of Median Filtering in Digital Images: A Difference
%  Domain Based Approach.
%  IEEE Trans. Image Process., vol. 22, no. 12, pp. 4699 - 4710, Dec. 2013.
% 
% -------------------------------------------------------------------------
%  Input: 
%    img .... input image (one channel)
%        T .... calculate the GPF feature in the range [0...T]
%        B .... the scanning length to construct LCF feature
%        K .... the order of the GLF feature to be computed
% ------------------------------------------------------------------------- 
%  Output:
%        F .... resulting GLF feature
% -------------------------------------------------------------------------
%  Notes:
%  The GLF feature set (K[2(T+1)+B(B-1)] emlements) is combined of the
%  following two feature set:
%  1. Global Probability Feture Set (GPF), K*2(T+1) elements;
%  2. Local Correlation Feature Set (LCF), K*B(B-1) elements.
% -------------------------------------------------------------------------
%  Example:
%    img = imread('Lena.bmp'); % read image
%    T=10; B=3; K=2; % parameter settings
%    F_GLF = GLF_Chen(img,T,B,K); % GLF features
%    F_GPF = F_GLF(1:K*2*(T+1)); % GPF features
%    F_LCF = F_GLF(K*2*(T+1)+1:end); % LCF features
% *************************************************************************

% % test time
% tic

% convert data type to 'double' when necessary
if(~strcmp(class(img),'double'))
    img = double(img);
end


% Calculate GPF feature in 4 directions
F_gpf=GPF4(img,T,K);

% Calculate LCF feature in 8 directions
F_lcf=LCF8(img,B,K);

% the final GLF feature
F=[F_gpf,F_lcf];

% toc
end



%%
%%% Function GPF4
%%% Calculate GPF feature in 4 directions, i.e. horizontal, vertical,
%%% major diagonal and minor diagonal direction (left-to-right)
function F_gpf=GPF4(img,T,K)

% -------------------------------------------------------------------------
% Note that GPF is based on the absolute difference, so the GPF feature of
% 'left-to-right' is equal to that of 'right-to-left'. For this reason we
% can only compute the GPF feature of 'left-to-right'.
% -------------------------------------------------------------------------

% *****************  Horizontal and Vertical Direction  *******************
% Horizontal and Vertical Direction
Direction = 'H';
% Horizontal Direction
% -----------------------  Horizontal Direction  --------------------------
% horizontal left-to-right
Mh1 = GetGPF(img,Direction,T,K);
% % horizontal right-to-left
% % using <fliplr(img)> to transform to 'horizontal left-to-right'
% Mh2 = GetGPF(fliplr(img),Direction,T,K);

% -------------------------  Vertical Direction  --------------------------
% vertical top-to-bottom
% using <img'> to transform to 'left-to-right'
Mv1 = GetGPF(img',Direction,T,K);
% % vertical bottom-to-top
% % using <fliplr(img')> to transform to 'horizontal left-to-right'
% Mv2 = GetGPF(fliplr(img'),Direction,T,K);

% Average the horizontal and vertical matrices
% F1 = (Mh1+Mh2+Mv1+Mv2)/4;
F1 = (Mh1+Mv1)/2;

% ************  Major Diagonal and Minor Diagonal Direction  **************
% Major Diagonal and Minor Diagonal Direction
Direction = 'D';
% ---------------------  Major Diagonal Direction  ------------------------
% major diagonal left-to-right
Md1 = GetGPF(img,Direction,T,K);
% % major diagonal right-to-left
% % using <rot90(img,2)> to transform to 'major diagonal left-to-right'
% Md2 = GetGPF(rot90(img,2),Direction,T,K);

% ---------------------  Minor Diagonal Direction  ------------------------
% minor diagonal left-to-right
% using <flipud(img)> to transform to 'major diagonal left-to-right'
Mm1 = GetGPF(flipud(img),Direction,T,K);
% % minor diagonal right-to-left
% % using <fliplr(img)> to transform to 'major diagonal left-to-right'
% Mm2 = GetGPF(fliplr(img),Direction,T,K);

% Average the major diagonal and minor diagonal matrices
% F2 = (Md1+Md2+Mm1+Mm2)/4;
F2 = (Md1+Mm1)/2;
% *******************  The Final GPF Feature Sets  ***********************
F_gpf = ([F1,F2]);

end

%%% Function GetGPF
%%% Calculate GPF feature
%%% in horizontal or major diagonal direction (left-to-right)
function gpf=GetGPF(img,Direction,T,K)
% Global Probability Features in Horizontal Direction

% **************************  Initialization  *****************************
% a switch to control Horizontal or Major Diagonal direction
if(strcmp(Direction,'H'))
    % switch to 'horizontal left-to-right direction'
    sw = 0;
elseif(strcmp(Direction,'D'))
    % switch to 'major diagonal left-to-right direction'
    sw = 1;
end

% GPF feature
gpf=zeros(T+1,K);

% ***********************  Calculate GPF feature  *************************

D0=img;
for k=1:K
    % k-th order difference array
    D1=(D0(1+sw:end,2:end)-D0(1:end-sw,1:end-1));
    % k-th order absolute difference array (arrange to a column vector)
    D1Abs=abs(D1(:));
    % calculate gpf
    for t=0:T
        gpf(t+1,k)=sum(D1Abs<=t);
    end
    gpf(:,k)=gpf(:,k)/length(D1Abs);
    % for calculation of (k+1)-th order difference array
    D0=D1;
end

gpf=gpf(:)';

end


%%
%%% LCF8 function
%%% Calculate LCF feature in 8 directions, i.e. four: horizontal, vertical,
%%% major diagonal and minor diagonal direction (left-to-right), the other
%%% four directions are the corresponding right-to-left.
function F_lcf=LCF8(img,B,K)

% LCF feature in Horizontal/Vertical Direction
lcf_hv=LCF_HV(img,B,K);
% LCF feature in Major/Minor Diagonal Direction
lcf_d=LCF_D(img,B,K);
% the final LCF feature set
F_lcf=[lcf_hv,lcf_d];

end


%%% LCF_HV function
%%% Calculate LCF feature in Horizontal/Vertical Direction
function lcf_hv=LCF_HV(img,B,K)
    

% **************************  Initialization  *****************************

% adopt non-overlapping or overlapping scan according to the size of image
[row,col]=size(img);
Blocksize=64;
if(row*col<=Blocksize*Blocksize)
    % overlapping scan
    block_type='overlapping';
else
    % non-overlapping scan
    block_type='non-overlapping';
end

% initialize lcf feature matrix
lcf_hv=zeros((B^2-B)/2,K);

% 0-th order difference array along horizontal left-to-right direction
D0_h1=img;
% 0-th order difference array along vertical top-to-bottom direction
% using <img'> to transform to 'horizontal left-to-right'
D0_v1=img';

% *********************  Calculate LCF feature  ***************************

for k=1:K

% ------------------  k-th Order Difference Array  ------------------------

    % k-th order difference
    % horizontal left-to-right
    D1_h1=D0_h1(:,1:end-1)-D0_h1(:,2:end);
    % horizontal right-to-left
    % using <fliplr(-D1_h1)> to transform to 'horizontal left-to-right'
    D1_h2=fliplr(-D1_h1);
    % vertical top-to-bottom
    % D0_v1 has already been transformed to 'horizontal left-to-right'
    D1_v1=D0_v1(:,1:end-1)-D0_v1(:,2:end);
    % vertical bottom-to-top
    % using <fliplr(-D1_v1)> to transform to 'horizontal left-to-right'
    D1_v2=fliplr(-D1_v1);

% ------------------  Scan to Generate Matrix Y_HV  -----------------------

    % horizontal left-to-right
    Y1_h1=HorizontalScan(D1_h1,B,block_type);
    % horizontal right-to-left
    Y1_h2=HorizontalScan(D1_h2,B,block_type);
%     Y1_h2=flipud(-Y1_h1);
    
    % vertical top-to-bottom
    Y1_v1=HorizontalScan(D1_v1,B,block_type);
    % vertical bottom-to-top
    Y1_v2=HorizontalScan(D1_v2,B,block_type);
%     Y1_v2=flipud(-Y1_v1);
    
    % Y1_HV
    Y1_hv=[Y1_h1,Y1_h2,Y1_v1,Y1_v2]';
    
% -------  Calculate LCF feature in Horizontal/Vertical Direction  --------
    
    % compute correlation coefficients as lcf feature
    lcf_hv(:,k)=lcf(Y1_hv);
    
    % for calculation of (k+1)-th order difference array
    D0_h1=D1_h1;
    D0_v1=D1_v1;
end

% arrange to a row vector
lcf_hv=lcf_hv(:)';

end


%%% LCF_D function
%%% Calculate LCF feature in Major/Minor Diagonal Direction
function lcf_d=LCF_D(img,B,K)

% **************************  Initialization  *****************************

% adopt non-overlapping or overlapping scan according to the size of image
[row,col]=size(img);
Blocksize=64;
if(row*col<=Blocksize*Blocksize)
    % overlapping scan
    block_type='overlapping';
else
    % non-overlapping scan
    block_type='non-overlapping';
end    

% initialize lcf feature matrix
lcf_d=zeros((B^2-B)/2,K);


% 0-th order difference array along major diagonal left-to-right direction
D0_d1=img;
% 0-th order difference array along minor diagonal left-to-right direction
% using <flipud(img)> to transform to 'major diagonal left-to-right'
D0_m1=flipud(img);

for k=1:K
    
% ------------------  k-th Order Difference Array  ------------------------    

    % major diagonal left-to-right
    D1_d1=(D0_d1(1:end-1,1:end-1)-D0_d1(2:end,2:end));
    % major diagonal right-to-left
    % using <rot90(-D1_d1,2)> to transform to 'major diagonal left-to-right'
    D1_d2=rot90(-D1_d1,2);
    % minor diagonal left-to-right
    % D0_m1 has already been transformed to 'major diagonal left-to-right'
    D1_m1=(D0_m1(1:end-1,1:end-1)-D0_m1(2:end,2:end));
    % minor diagonal right-to-left
    % using <rot90(-D1_m1,2)> to transform to 'major diagonal left-to-right'
    D1_m2=rot90(-D1_m1,2);
    
% ------------------  Scan to Generate Matrix Y_HV  -----------------------

    % major diagonal left-to-right
    Y1_d1=MajorDiagonalScan(D1_d1,B,block_type);
    % major diagonal right-to-left
    Y1_d2=MajorDiagonalScan(D1_d2,B,block_type);
%     Y1_d2=flipud(-Y1_d1);
    % minor diagonal left-to-right
    Y1_m1=MajorDiagonalScan(D1_m1,B,block_type);
    % minor diagonal right-to-left
    Y1_m2=MajorDiagonalScan(D1_m2,B,block_type);
%     Y1_m2=flipud(-Y1_m1);
    
    % Y1_D
    Y1_D=[Y1_d1,Y1_d2,Y1_m1,Y1_m2]';
      
% -------  Calculate LCF feature in Horizontal/Vertical Direction  --------

    % compute correlation coefficients as lcf feature
    lcf_d(:,k)=lcf(Y1_D);
    
    % for calculation of (k+1)-th order difference array
    D0_d1=D1_d1;
    D0_m1=D1_m1;
end

% arrange to a row vector
lcf_d=lcf_d(:)';

end


%%%
%%% Function lcf
%%% Compute the lcf feature
function r=lcf(Y)

if(size(Y,1)<=1)
    B=size(Y,2);
    r=ones(1,(B^2-B)/2);
else
    r=corrcoef(Y);
    % coefficients in the lower triangular
    r= tril(r,-1);
    index=ones(size(r));
    index=(tril(index,-1)==1);
    r=r(index)';
    
    % set NaN to 0
    r(isnan(r))=0;
end

end

%%% this function make use of C-MEX file Im2Col_Chen
function Y=HorizontalScan(img,B,block_type)
% Horizontal Scan of size B from left to right

if(strcmp(block_type,'non-overlapping'))
    % non-overlapping scan
    block_type='distinct';
else
    % overlapping scan
    block_type='sliding';
end

% test time
% tic
% call C-MEX file Im2Col_Chen. This function is provided as a C-MEX version
% of the Matlab function 'im2col' and is much faster.
% -------------------------------------------------------------------------
% Notes:
% When block_type='sliding' or block_type='distinct' with option='pad', 
% this function becomes the same as the Matlab function 'im2col', but runs
% much faster.
% See 'Im2Col_Chen' and 'im2col' for more details.
% -------------------------------------------------------------------------
option='cut';
Y=Im2Col_Chen(img,[1,B],block_type,option);
% or use Matlab function 'im2col' as follow
% Y=im2col(img,[1,B],block_type);
% toc

% delete staurated columns (all zero values)
s=sum(abs(Y),1);
index=(s==0);
Y(:,index)=[];

end


function Y=MajorDiagonalScan(img,B,block_type)
% Major Diagonal Scan of size B from left to right

% transform Diagonal to Horizonal
% use NaN to locate the blank elements
blank=NaN;
img1=Diag2H_Chen(img,blank);

% make use of horizontal scan
Y=HorizontalScan(img1,B,block_type);

% delete NaN columns
s=sum(isnan(Y),1);
index=(s~=0);
Y(:,index)=[];

% delete staurated columns (all zero values)
s=sum(abs(Y),1);
index=(s==0);
Y(:,index)=[];

end