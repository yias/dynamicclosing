function []=plotPowerCurve(latent,score,nbComp)


%% Power table

disp('Power Table:')
sum_p=sum(latent);

ss=0;

power=zeros(length(latent),1);
if length(latent)<size(score,1)
    for i=1:length(latent)

        ss=ss+latent(i);
        power(i)=(ss/sum_p)*100;
        disp(['using ' num2str(i) ' components you have ' num2str(power(i)) '% of the total information'])

    end
else
    for i=1:length(latent)

        ss=ss+latent(i);
        power(i)=(ss/sum_p)*100;

    end
    
    for i=1:20

        disp(['using ' num2str(i) ' components you have ' num2str(power(i)) '% of the total information'])

    end
    
    if length(latent)>100
        for i=30:10:100
            disp(['using ' num2str(i) ' components you have ' num2str(power(i)) '% of the total information'])
        end
    end
    
    if length(latent)>1000
        for i=100:100:1000
            disp(['using ' num2str(i) ' components you have ' num2str(power(i)) '% of the total information'])
        end
    end
    
    disp(['using ' num2str(length(latent)) ' components you have ' num2str(power(end)) '% of the total information'])
end
%% Sparsity plot

figure()
if length(latent)<=size(score,1)
    plot(1:length(latent),power,'LineWidth',3)
else
    plot(1:(min(find(power==100))+2),power(1:min(find(power==100))+2),'LineWidth',3)
end
hold on
plot(ones(nbComp,1)*nbComp,power(1:nbComp),'k--','LineWidth',3)
plot(0:nbComp,ones(nbComp+1,1)*power(nbComp),'k--','LineWidth',3)
xlabel('number of Components')
ylabel('sparsity')
title('Sparsity of the data VS number of PCs')
grid on




end