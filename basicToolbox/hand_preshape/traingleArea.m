function A=traingleArea(a1,a2,a3)


dist1=sqrt(sum((a1-a2).^2));
dist2=sqrt(sum((a2-a3).^2));
dist3=sqrt(sum((a3-a1).^2));

s=(dist1+dist2+dist3)/2;

A=sqrt(s*(s-dist1)*(s-dist2)*(s-dist3));

end