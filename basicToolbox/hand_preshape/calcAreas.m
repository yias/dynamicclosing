function Area=calcAreas(thumb,index,middle,ring,little,tab)


switch tab
    case 1
        Area=traingleArea(thumb,index,little)+traingleArea(index,ring,little)+traingleArea(index,middle,ring);
    case 2
        Area=traingleArea(thumb,index,middle);
    case 3
        Area=traingleArea(thumb,index,middle);
    case 4
        Area=traingleArea(thumb,index,little);
    case 5
        Area=traingleArea(thumb,index,little);
    otherwise
        error('wrong defenition of the grasp type. tab should be between 1-5')
end








end