function H = Hinv(h)
    R = h(1:3, 1:3);
    t = h(1:3, 4);
    H = [R'         -(R'*t)
         zeros(1,3)     1 ];
end