function Y=Im2Col_Chen(A,block_dim,block_type,option)
% *************************************************************************
% Rearranges image blocks into columns.
% -------------------------------------------------------------------------
%  Copyright (c) Chenglong Chen
%  All Rights Reserved.
%  Contact: c.chenglong@gmail.com
% -------------------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software for
% educational, research and non-profit purposes, without fee, and without a
% written agreement is hereby granted, provided that this copyright notice
% appears in all copies. The end-user understands that the program was
% developed for research purposes and is advised not to rely exclusively on
% the program for any reason.
% -------------------------------------------------------------------------
% Input:
%     A          .... the input matrix of any class
%     block_dim  .... the dimension of block (a 2-D vector)
%     block_type .... block_type is a string that can have one of these
%                       values
%                       'distinct' - non-overlapping block
%                       'sliding'  - overlapping block
%     option     .... option is a string that can have one of these
%                        values
%                       'cut' - delete the boundary elements
%                       'pad' - pad A with 0's (zeros)
% Output: 
%     Y          .... the output matrix, the same class as A
% -------------------------------------------------------------------------
% Notes:
% When block_type='sliding' or block_type='distinct' with option='pad', 
% this function becomes the same as the Matlab function 'im2col', but runs
% much faster.
% See 'im2col' for more details.
% *************************************************************************


% convert data type to 'double' for running C-MEX file
class_of_A = class(A);
change_class = false;
if(~strcmp(class(A),'double'))
    A = double(A);
    change_class=true;
end

% each dimension of th block
if(length(block_dim)==1)
    By=block_dim;
    Bx=block_dim;
elseif(length(block_dim)==2)
    By=block_dim(1);
    Bx=block_dim(2);
else
    error('Wrong block dimension!! Must be a 1-D or 2-D vector!!');
end

if(strcmp(block_type,'distinct'))
    % non-overlapping
    block_type=0;
    [row,col]=size(A);
    % number of instance in a row of A
    nx=floor(col/Bx);
    % number of instance in a column of A
    ny=floor(row/By);

    if(strcmp(option,'cut'))
        % delete the boundary elements to avoid padding with zeros
        A1=A(1:ny*By,1:nx*Bx);
    else
        % pads A with 0's (zeros), now, 'Im2Col_Chen' becomes the same as
        % Matlab function 'im2col'
        A1=padarray(A,[By*ceil(row/By)-row,Bx*ceil(col/Bx)-col],0,'post');
    end
elseif(strcmp(block_type,'sliding'))
    % overlapping
    block_type=1;
    A1=A;
else
    error('Wrong block type!! Must bo ''distinct'' for non-overlapping block or ''sliding'' for overlapping block!!');
end

% call the C-MEX programm 'im2col_chen'
Y=im2col_chen(A1,Bx,By,block_type);

% change the class back if necessary
if(change_class)
    Y = feval(class_of_A,Y);
end

end
    