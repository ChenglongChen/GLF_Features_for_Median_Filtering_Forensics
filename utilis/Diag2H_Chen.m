function B=Diag2H_Chen(A,blank)
% *************************************************************************
% Rearranges the diagonals of A along left-to-right direction, from k=col-1
% to k=-row+1 into horizontal direction. The blank elements are marked with
% value of 'blank', e.g. NaN.
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
% Input:         A .... the input matrix of any class
%            blank .... to mark the blank elements with value of 'blank'
% Output:        B .... the output matrix, the same class as A
% -------------------------------------------------------------------------
% Example:
% 
% For the following matrix,
% A=[1 4 7
%    2 5 8
%    3 6 9]
% the following command
% B=Diag2H_Chen(A,NaN);
% returns
% B=[7 NaN NaN
%    4  8  NaN
%    1  5   9
%    2  6  NaN
%    3 NaN NaN]
% 
% See 'spdiags' or 'diag' for more details.
% *************************************************************************

% convert data type to 'double' for running C-MEX file
class_of_A = class(A);
change_class = false;
if(~strcmp(class(A),'double'))
    A = double(A);
    change_class=true;
end


% call the C-MEX programm 'diag2h_chen'
B=diag2h_chen(A,blank);

% change the class back if necessary
if(change_class)
    B = feval(class_of_A,B);
end

end
    