function xd = decimatef( x, fs, decRate )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
N  = length(x(:,1));
dt = 1/fs;
Ts = (N-1)*dt;
t  = 0:dt:Ts;

df = fs/N;
Fm = fs/2;
f  = -Fm:df:Fm - df;
Fc = Fm/decRate;


Ns       = ceil(N/2 - (N/(2*Fm))*Fc);
Ne       = ceil(N/2 + (N/(2*Fm))*Fc);
H        = zeros(1,N);
H(Ns:Ne) = ones(1,Ne-Ns+1);
H        = fftshift(H);

Rf =  fft(x(:,1)) .* H';
Lf =  fft(x(:,2)) .* H';

xf(:,1) = real(ifft(Rf));
xf(:,2) = real(ifft(Lf));

xd(:,1) = decimate(xf(:,1), decRate, 'fir');
xd(:,2) = decimate(xf(:,2), decRate, 'fir');

sound(xd, fs/decRate);

f  = -Fc:df:Fc-df;
figure
subplot(2,1,1);
plot(f, abs(fftshift(fft(xd(:,1)))));
title('Right chanel spectrum and ideal LPF');
xlabel('f, Hz');

subplot(2,1,2);
plot(f, abs(fftshift(fft(xd(:,2)))));
title('Left chanel spectrum and ideal LPF');
xlabel('f, Hz');

end

