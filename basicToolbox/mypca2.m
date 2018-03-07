function [coeff,score,eigenvalues]=mypca2(matrix)

% Description
%
% This function performs Proncipal Component Analysis (PCA) of the data
% matrix using Singular Value Decomposition (SVD). It returns the matrix
% with the coefficients, the score and the eigenvaleues after PCA. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           
% Inputs: 
%       
%       matrix:         a matrix that contains the data to apply PCA. The
%                       matrix should be arranged as follows: the collumns
%                       should correspont to the dimensions (variables) and
%                       the rows should correspond to the images (samples)
%
% Outputs:
%   
%       coeff:          the transformation matrix from the initial space to
%                       the new hyperplane. Each column correspods to an
%                       eigenvector of the new hyperplane. The order the
%                       eigenvectors corresponds to the order of the
%                       eigenvalues. So, the first collumn "coeff(:,1)" of
%                       the matrix 'coeff' corresponds to the eigenvector
%                       of the 1st eigenvalue "eigenvalues(1)", the second
%                       column of the coeff "coeff(:,2)" corresponds to the
%                       second eigenvalue "eigenvalues(2)", etc.
%                
%       score:          the projected images to the new hyperplane. Each
%                       row corresponds to an image projected to the new
%                       hyperplane. 
%
%       eigenvalues:    a vector containing the eigenvalues in a descending
%                       order
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% substract the means (centralize the data)
cntrdImgMatrix=matrix-repmat(mean(matrix,1),size(matrix,1),1);

% apply singular value dicompozition ('econ' is for returning only the 
% non-zero eigenvalues) 
[U,S,V] = svd(cntrdImgMatrix,'econ');

% calculate the eigevalues
eigenvalues=(diag(S).^2)/(size(matrix,1)-1);

% calculate the progection of the data to the new hyperplane
score=U*S;

% place the coefficient
coeff=V;





end