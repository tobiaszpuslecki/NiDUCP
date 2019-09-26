

%****************************       KODER       ***************************

zeros = 4 - mod(signal_length,4);               %liczba dodatkowych zer
%sygnal musi byc podzielny przez 4 poniewaz kazda paczka bedzie zawierala 3
%bity korygujace - w sumie wychodzi 7 tak jak w zalozeniu - n paczek po 7
%bit�w.
for i = 1:zeros
    signal(signal_length+i) = 0;                %uzupelniamy dodatkowymi zerami
end

signal_length = signal_length + zeros;          %korygujemy dlugosc sygnalu
nwords = signal_length/4;                       %nie chodzi o s?ynne s?owo NWORD... jest to ilo?? wszystkich s?�w
m = 3;                                          %liczba bit�w koryguj?cych na slowo
n = 2^m - 1;                                    %dlugosc slowa
k = 4;                                          %liczba bitow niekoryguj?cych
t = bchnumerr(n,k);                             %zdolno?? poprawiania b??du
signal';                                        %debug sygna? przed poci?ciem
signalx = reshape(signal,4,[])';                %przetworzenie sygna?u na posta? (n x 4) wektor�w - poci?cie go
beforeEnc = gf(signalx)                         %argument sygnalu musi byc tablic? Galois
encSignal = bchenc(beforeEnc,n,k)               %zakodowanie sygna?u w postaci (n x 7) wektor�w

%****************************      DEKODER      ***************************

noisyCode = encSignal + randerr(nwords,n,1:t)   %tutaj dodanie szumu, tak podgl?dowo dla mnie

afterDec = bchdec(noisyCode,n,k)                %zdekodowany sygna?
isequal(beforeEnc,afterDec)                     %zwraca 1 gdy sygna? przed kodowaniem i po przejsciu przez szum oraz po dekodowaniu sa takie same