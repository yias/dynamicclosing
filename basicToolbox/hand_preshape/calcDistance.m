function Distane=calcDistance(thumb,index,little,tab)


switch tab
    case 1
        Distane=sqrt(sum((index-thumb).^2));
    case 2
        Distane=sqrt(sum((index-thumb).^2));
    case 3
        Distane=sqrt(sum((index-thumb).^2));
    case 4
        Distane=sqrt(sum((index-thumb).^2));
    case 5
        Distane=sqrt(sum((thumb-little).^2));
    otherwise
        error('wrong defenition of the grasp type. tab should be between 1-5')
end



end