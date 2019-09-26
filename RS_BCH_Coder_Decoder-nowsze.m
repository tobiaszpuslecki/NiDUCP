
%****************************       KODER       ***************************

if mod(signal_length,4) == 0            %liczba dodatkowych zer
    zeros = 0;
else
    zeros = 4 - mod(signal_length,4);
end
           
%sygnal musi byc podzielny przez 4 poniewaz kazda paczka bedzie zawierala 3
%bity korygujace - w sumie wychodzi 7 tak jak w zalozeniu - n paczek po 7
%bit�w.
for i = 1:zeros
    signal(signal_length+i) = 0;                %uzupelniamy dodatkowymi zerami
end

signal_length = signal_length + zeros;          %korygujemy dlugosc sygnalu

nwords = signal_length/4;                       %jest to ilosc wszystkich slow

m = 3;                                          %liczba bitow koryguj?cych na slowo
n = 2^m - 1;                                    %dlugosc slowa
k = 4;                                          %liczba bitow niekorygujacych

t = bchnumerr(n,k);                             %zdolnosc poprawiania b??du

signal';                                        %debug sygnal przed pocieciem

signalx = reshape(signal,4,[])';                %przetworzenie sygnalu na postac (n x 4) wektor�w - pociecie go

beforeEnc = gf(signalx)                         %argument sygnalu musi byc tablica Galois

encSignal = bchenc(beforeEnc,n,k)               %zakodowanie sygnalu w postaci (n x 7) wektor�w

%****************************      DEKODER      ***************************

noisyCode = encSignal + randerr(nwords,n,1:t)   %tutaj dodanie szumu, tak podgladowo dla mnie

afterDec = bchdec(noisyCode,n,k)                %zdekodowany sygnal

isequal(beforeEnc,afterDec)                     %zwraca 1 gdy sygnal przed kodowaniem i po przejsciu przez szum oraz po dekodowaniu sa takie same

%beforeEnc - sygnal przed zakodowaniem

%afterDec - sygnal po zdekodowaniu

%endSignal - sygnal zakodowany

%**************************** LICZENIE % B??D�W ***************************
if afterDec(1,1) == 1                   
    afterDec(1,1) = 0;
else
    afterDec(1,1) = 1;
end

if afterDec(2,1) == 1
    afterDec(2,1) = 0;
else                            %Te 3 ify mo?esz wywali? s? podgl?dowo do zmiany warto?ci bit�w w 3 s?owach
    afterDec(2,1) = 1;          %Jak uruchomisz z tymi ifami do ilo?? b??d�w bedzie >= 3
end

if afterDec(3,1) == 1
    afterDec(3,1) = 0;
else
    afterDec(3,1) = 1;
end

mistakes = 0;
for i = 1:nwords  %nwords * 4 = d?ugosc sygnalu
    for j = 1:4
        if beforeEnc(i,j) ~= afterDec(i,j)
            mistakes = mistakes + 1;
        break
        end
    end
end

mistakes    %ilosc blednie rozkodowanych paczek
nwords      %ilosc wszystkich paczek