function soundTone(duration, freq)
 fs = 8000;
        T = duration; % 2 seconds duration
        t = 0:(1/fs):T;
       f = freq;
       a = 0.5;
       y = a*sin(2*pi*f.*t);
       sound(y, fs);
       
end