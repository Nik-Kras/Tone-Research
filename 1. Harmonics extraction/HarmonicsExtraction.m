function [Fharm, pks] = HarmonicsExtraction(x, fs, MinFreqStep...
                                                    ,MinAmplitude)
% HarmonicsExtraction gives:
%   Fharm - vector of frequencies that according to harmonics of x audio
%   pks   - vector of amplitude of that harmonics
% HarmonicsExtraction needs:
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
X = fft(x(:,1)) / N;

Xp = abs(fftshift(X));
Xp = Xp(N/2 + 1:end);
fp = f(N/2 + 1:end);

if MinFreqStep == 0
    MinFreqStep = 10;
end
if MinAmplitude == 0
    MinAmplitude = max(Xp)/100;
end

% Raw Harmonics
[pksRaw, FharmRaw] = findpeaks(Xp, fp, 'MinPeakDistance', MinFreqStep...
                          ,'MinPeakHeight', MinAmplitude);

% Search for a base tone
% It counts how many divisions were multiple (1:2, etc.)
% And choose frequency with maximum comparations

Nf = length(FharmRaw);
CompareVector = zeros(1, Nf);
ErrorTresholdDivision = 0.04;

for i = 1:Nf
   for j = 1:Nf
        if FharmRaw(i) < FharmRaw(j)
            integerVal = round(FharmRaw(j)/FharmRaw(i));
            floatVal   = FharmRaw(j)/FharmRaw(i);
            freqDifference = abs(floatVal-integerVal);
            if freqDifference < ErrorTresholdDivision
                CompareVector(i) = CompareVector(i) + 1;
            end
        end
    end
end

% Find index of Base tone
BaseVal = max(CompareVector);
BaseFreqIndex = 0;

for i = 1:length(CompareVector)
   if BaseVal == CompareVector(i)
       BaseFreqIndex = i;
       break;
   end
end

% Harmonics filtering by base tone (only multiple of base will go further)
F0 = FharmRaw(BaseFreqIndex);
ErrorThreshold = 0.04;
FharmCnt = 0;
Fharm    = 0;
pks      = 0;

for i = 1:length(FharmRaw)
    integerVal = round(FharmRaw(i)/F0);
    floatVal   = FharmRaw(i)/F0;
    freqDifference = abs(floatVal-integerVal);
    if ( freqDifference < ErrorThreshold )
        FharmCnt = FharmCnt+1;
        Fharm(FharmCnt) = FharmRaw(i);
        pks(FharmCnt) = pksRaw(i);
    end
end
                      
                      
end

