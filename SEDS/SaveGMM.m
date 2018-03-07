function SaveGMM(structGMM, Dir, fname)
% This function save GMM to text file
% The result file will be sored in the directory "dir" 
%  fname_mu.txt, fname_sigma.txt and fname_prio.txt
%
% Inputs -----------------------------------------------------------------
%   o structGMM : GMM structure 
%   o Dir       : Directory to be saved the GMM text files
%   o fname     : File name 
% ------------------------------------------------------------------------

        Mu = structGMM.Mu;
        Sigma = structGMM.Sigma;
        Priors = structGMM.Priors; 

        nbStates = length( Mu(1,:) );
        nbDim = length( Mu(:,1) );
        
        format_nbstates = repmat('%12.10f ', 1, nbStates);
        format_nbstates = [ format_nbstates  ' \n'];
        format_nbdim    = repmat('%12.10f ', 1, nbDim);
        format_nbdim    = [ format_nbdim  ' \n'];

       % Save 
        fid = fopen([Dir '/' fname '_mu.txt'],'wt');
        fprintf(fid, format_nbstates, Mu(:,[1:nbStates])');
        fclose(fid);	

        for i=1:nbStates,
            M(1+nbDim*(i-1):nbDim+nbDim*(i-1),1:nbDim) = Sigma(:,:,i);
        end;

        fid = fopen([Dir '/' fname '_sigma.txt'],'wt');
        fprintf(fid, format_nbdim,M');
        fclose(fid);	
        
        fid = fopen([Dir '/' fname '_prio.txt'],'wt');
        fprintf(fid, format_nbstates, Priors');
        fclose(fid);	
        
        
end