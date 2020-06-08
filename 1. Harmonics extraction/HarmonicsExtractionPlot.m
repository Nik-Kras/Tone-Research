function [Fharm, pks] = HarmonicsExtractionPlot(x, fs, MinFreqStep...
                                                    ,MinAmplitude)
% HarmonicsExtractionPlot gives:
%   Fharm - vector of frequencies that according to harmonics of x audio
%   pks   - vector of amplitude of that harmonics
%   Also it gives plots of Raw and Done extracted harmonics
% HarmonicsExtractionPlot needs:
%   x            - audio samples
%   fs           - sampling frequency of x
%   MinFreqStep  - minimum base frequency. Can be 0(zero). Default value
%   MinAmplitude - minimum harm. amplitude. Can be 0(zero). Default value

% Initial phase
dt = 1/fs;
N  = length(x);
Ts = (N-1)*dt;
t  = 0:dt:Ts;
df = fs/N;
Fm = fs/2;
f = -Fm:df:Fm - df;

% Spectrum
X(:,1) = fft(x(:,1)) / N;
X(:,2) = fft(x(:,2)) / N;

Xp = abs(fftshift(X(:,1)));
Xp = Xp(N/2 + 1:end);
fp = f(N/2 + 1:end);

if MinFreqStep == 0
    MinFreqStep = 40;
end
if MinAmplitude == 0
    MinAmplitude = max(Xp)/100;
end

% Raw Harmonics
[pksRaw, FharmRaw] = findpeaks(Xp, fp, 'MinPeakDistance', MinFreqStep...
                          ,'MinPeakHeight', MinAmplitude);

figure
area(fp, Xp);
hold on
plot(FharmRaw, pksRaw, 'rv', 'MarkerFaceColor', 'r');
yScaleAdd = max(pksRaw)*0.05; 
cellpeaks = cellstr(num2str(round(FharmRaw', 0)));
text(FharmRaw, yScaleAdd+pksRaw, cellpeaks, 'FontSize', 16);
ylim([0 max(pksRaw)+2*yScaleAdd]);
xlim([fp(1) FharmRaw(end)])
hold off
title('Raw Spectrum harmonics');
xlabel('f, Hz');

% Search for a base tone
% It counts how many divisions were multiple (1:2, etc.)
% And choose frequency with maximum comparations

Nf = length(FharmRaw);
CompareVector = zeros(1, Nf);
ErrorTresholdDivision = 0.05;

for i = 1:Nf
   for j = 1:Nf
        if FharmRaw(i) < FharmRaw(j)
            integerVal = floor(FharmRaw(j)/FharmRaw(i));
            floatVal   = FharmRaw(j)/FharmRaw(i);
            freqDifference = abs(floatVal-integerVal);
            if freqDifference < ErrorTresholdDivision
                CompareVector(i) = CompareVector(i) + 1;
            end
        end
    end
end
disp(['????????? ???????? - ', num2str(CompareVector)]);

% Find index of Base tone
BaseVal = max(CompareVector);
BaseFreqIndex = 0;

for i = 1:length(CompareVector)
   if BaseVal == CompareVector(i)
       BaseFreqIndex = i;
   end
end

% Harmonics filtering by base tone (only multiple of base will go further)
F0 = FharmRaw(BaseFreqIndex);
ErrorThreshold = 0.05;
FharmCnt = 0;
Fharm    = 0;
pks      = 0;

for i = 1:length(FharmRaw)
    integerVal = floor(FharmRaw(i)/F0);
    floatVal   = FharmRaw(i)/F0;
    freqDifference = abs(floatVal-integerVal);
    if ( freqDifference < ErrorThreshold )
        FharmCnt = FharmCnt+1;
        Fharm(FharmCnt) = FharmRaw(i);
        pks(FharmCnt) = pksRaw(i);
    end
end

figure
area(fp, Xp);
hold on
plot(Fharm, pks, 'rv', 'MarkerFaceColor', 'r');
yScaleAdd = max(pks)*0.05; 
cellpeaks = cellstr(num2str(round(Fharm', 0)));
text(Fharm, yScaleAdd+pks, cellpeaks, 'FontSize', 16);
ylim([0 max(pks)+2*yScaleAdd]);
xlim([fp(1) Fharm(end)])
hold off
title('Spectrum harmonics');
xlabel('f, Hz');                      
                      
end

