#include "mex.h"

// This C-MEX programm rearranges image blocks into columns
void im2col_chen(double *A, mwSize Bx, mwSize By,double block_type,
                 double *Y, mwSize mrows, mwSize ncols)
{   
    // initialize
    mwSize i,j,kx,ky,count=0;
    mwSize num_x,num_y,step_x,step_y;
    
    if(block_type==0)
    {
        //non-overlapping
        //number of instance in a row of A
        num_x = (mwSize)floor(((double)ncols)/(double)Bx);
        //number of instance in a column of A
        num_y = (mwSize)floor(((double)mrows)/(double)By);
        // search step of column
        step_x = Bx;
        // search step of row
        step_y = By;
    }
    
    else
    {
        // overlapping
        // number of instance in a row of A
        num_x = ncols-Bx+1;
        // number of instance in a column of A
        num_y = mrows-By+1;
        // search step of column
        step_x = 1;
        // search step of row
        step_y = 1;
    }
    
    // Note that matlab is column dominant
    // search column
    for (j=0; j<num_x*step_x; j=j+step_x )
    {   // search row
        for (i=0; i<num_y*step_y; i=i+step_y)
        {   // search column   
            for (kx=0; kx<Bx;kx++)
            {   // search row
                for (ky=0; ky<By; ky++)
                    *(Y+count*Bx*By+kx*By+ky) = *(A+(j+kx)*mrows+i+ky);
            }
            count++;
        }
    }
}

// the gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    // initialize
    double *A, *Y;
    mwSize mrows,ncols;
    mwSize Bx,By,block_type;
    mwSize num_x,num_y,totalnum;
    
    // input image
    A = mxGetPr(prhs[0]);
    // get the dimensions of the input image
    mrows = (mwSize)mxGetM(prhs[0]);
    ncols = (mwSize)mxGetN(prhs[0]);
    // scan length
    Bx = (mwSize)mxGetScalar(prhs[1]); 
    By = (mwSize)mxGetScalar(prhs[2]);
    // non-overlapping scan of overlapping scan
    block_type = (mwSize)mxGetScalar(prhs[3]);
    
    // initialize matrix Y
    if(block_type==0)
    {
        // non-overlapping block
        // number of instance in a mrows of A
        num_x = (mwSize)floor(((double)ncols)/(double)Bx);
        num_y = (mwSize)floor(((double)mrows)/(double)By);
    }
    else
    {
        // overlapping scan
        // number of instance in a mrows of A
        num_x = ncols-Bx+1;
        num_y = mrows-By+1;
    }
    
    // total number of instance of A
    totalnum = num_x*num_y;
    // set the output pointer to matrix Y
    plhs[0] = mxCreateDoubleMatrix(Bx*By,totalnum, mxREAL);
    Y = mxGetPr(plhs[0]);
    
    // call the computational routine
    im2col_chen(A, Bx,By, block_type, Y, mrows, ncols);
  
}
