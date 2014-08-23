%--------------------------------------------------------------------------
%  Examples of use of the method proposed in:
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
% The 'Lena' image used in this example can be downloaded from the USC-SIPI
% image database on:
% http://sipi.usc.edu/database/download.php?vol=misc&img=4.2.04
% For copyright information, please go to:
% http://sipi.usc.edu/database/copyright.php
%
%--------------------------------------------------------------------------
% This code is provided only for research purposes.
%--------------------------------------------------------------------------


% Clear all variables and close all figures
clear all; close all;

% add current path to the search path
addpath(genpath(cd));
% Read the image
RGB = imread('Lena.tiff');
% Take the Green channel
img = RGB(:,:,2);
% parameter settings
T = 10; B = 3; K = 2;
% GLF features
F_GLF = GLF_Chen(img,T,B,K);
% GPF features
F_GPF = F_GLF(1:K*2*(T+1));
% LCF features
F_LCF = F_GLF(K*2*(T+1)+1:end);