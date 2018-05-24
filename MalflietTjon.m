function V = MalflietTjon(r)
    % Realistisk nukleon-nukleon potential % av s.k. Malfliet-Tjon typ
    % Ref: R. A. Malfliet and J. A. Tjon
    % Nuclear Physics A127 (1969) 161-168 %
    % in: r - i 10^{-15}m ’fm’
    % ut: V - i MeV

    l1 = -586.04;
    l2 = +1458.19;
    l3 = -872.15;

    mu1 = 1.55;
    mu2 = 3.11;
    mu3 = 6.00;

    V1 = l1*exp(-mu1*r);
    V2 = l2*exp(-mu2*r);
    V3 = l3*exp(-mu3*r);

    V = (V1 + V2 + V3)/r;
end
