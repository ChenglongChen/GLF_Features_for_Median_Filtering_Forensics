#include "mex.h"

// This C-MEX programm rearranges diagonals of A to a horizontal direction
void diag2h_chen(double *A, double blank, double *B, mwSize mrows, mwSize ncols)
{   
    // initialize
    mwSize i,j,k,count,count2;
    mwSize mrows1,ncols1;
    
    mrows1=mrows+ncols-1;
    ncols1=min(mrows,ncols);
    // Note that matlab is column dominant
    // search column
    count=0;
    for ( k=ncols-1;k>=-mrows+1;k--)
    {   
        count2=0;
        // search column
        for (j=0; j<ncols ;j++)
        {
            i=j-k;
            if((i>=0)&(i<mrows))
            {
                *(B+count2*mrows1+count) = *(A+j*mrows+i);
                count2++;
            }
        }
        for(i=count2;i<ncols1;i++)
        {
            *(B+i*mrows1+count) = blank;
        }
        count++;
    }    
}
          

// the gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    // initialize
    double *A,blank, *B;
    mwSize mrows,ncols,ncols1,mrows1;
    
    // input image
    A = mxGetPr(prhs[0]);
    // get the dimensions of the input image
    mrows = (mwSize)mxGetM(prhs[0]);
    ncols = (mwSize)mxGetN(prhs[0]);
    blank= mxGetScalar(prhs[1]);
    
    // set the output pointer to matrix B
    mrows1=mrows+ncols-1;
    ncols1=min(mrows,ncols);
    plhs[0] = mxCreateDoubleMatrix(mrows1,ncols1, mxREAL);
    B = mxGetPr(plhs[0]);
    
    // call the computational routine
    diag2h_chen(A, blank,B, mrows, ncols);
  
}
