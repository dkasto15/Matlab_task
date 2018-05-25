% Physical parameters
h_bar_c = 197.327;  % MeV*fm
E_proton = 938.2723128; % MeV https: % newton.ex.ac.uk/research/qsystems/collabs/constants.html
E_neutron = 939.5656328; % MeV https: % newton.ex.ac.uk/research/qsystems/collabs/constants.html

K = 2*(E_proton*E_neutron/(E_proton + E_neutron))/h_bar_c^2;


%grid i fm
rmax = 20.0;
%antal steg
N=10000;
%ekvidistant steglängd
h=(rmax)/(N);
fprintf('stegl�ngd',h)

%initialisera grid, och potentialen V(r)
%för varje r. Använd ej exakt noll.
r=linspace(1e-16,rmax,N+1);
u=zeros(1,N+1);
Fvec=zeros(1,N+1);
Vr=zeros(1,N+1);
for i=1:N+1
  Vr(i)= MalflietTjon(r(i));
end

%parametrar
Emin = min(Vr);
Emax = 0.0;
E = 0.5*(Emin+Emax);
max_iter = 10000;
tol_kontinuitet=1e-10;
%iterera över energin E
for iter=1:max_iter
  % initialisera Fvec(r) (dvs. F i ekv. 15),
  % denna vektor beror på valet av E
  for i=1:N+1
    Fvec(i) = K*(Vr(i) - E);
  end
  % välj matchningspunkt (motsv. grid-index)
  [~, rmp_i] = min(abs(r - 1)); % find r idx corresp. to 1 fm

  fprintf("Match r=%.16f \n",r(rmp_i))
  %initialisera utåt-integrerad vågfunktion
  u(1)=0;
  u(2)=h^1;
  % Numerov utåt
  for i=3:rmp_i
    u(i) = (u(i-1)*(2 + (5/6)*h^2*Fvec(i-1)) - u(i-2)*(1 - (1/12)*h^2*Fvec(i-2)))/(1-(1/12)*h^2*Fvec(i));
  end
  u_out_mp = u(rmp_i);
  %initialisera inåt-integrerad vågfunktion
  kappa = sqrt(-K*E);
  u(N+1)= exp(-kappa*r(N+1)); % Set A=1, arbitrary because of later scaling
  u(N) = exp(-kappa*r(N)); % Set A=1, arbitrary because of later scaling
  % Numerov utåt
  for i=N-1:-1:rmp_i
    u(i) = -(u(i+2)*(1-(1/12)*h^2*Fvec(i+2)) - u(i+1)*(2 + (5/6)*h^2*Fvec(i+1)))/(1-(1/12)*h^2*Fvec(i));
  end

  u_in_mp = u(rmp_i);
  %skalfaktor mellan in/ut vågfunktioner
  skalfaktor = u_out_mp/u_in_mp;
  %matcha "höjden"
  u(rmp_i:N) = skalfaktor*u(rmp_i:N);
  %beräkna diskontinuitet av derivatan in mp
  matching = (u(rmp_i - 1) + u(rmp_i + 1) - u(rmp_i)*(2 + h^2*Fvec(rmp_i)))/h;
  if abs(matching) < tol_kontinuitet
    break;
  end

  if u(rmp_i)*matching > 0
    Emax=E;
  else
    Emin=E;
  end
  E=0.5*(Emax+Emin);
end

norm = trapz(abs(u).^2);
u = u / sqrt(norm);
fprintf('integ of abs(u)^2', trapz(abs(u).^2))

% normera vågfunktionen så att integralen = 1
% beräkna observabel radie i fm % plotta vågfunktion u(r)
% analysera resultat

%the r^2 scaling factor compensates for usage of u instead of R in r_exp_sq
r_exp_sq = trapz(conj(u).*(r/2).^2.*u);
r_d = sqrt(r_exp_sq)

plot(r, u)
xlabel('r [fm]')
ylabel('u()')
