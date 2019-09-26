clear

signal_length = input('Podaj dlugosc sygnalu: ');
signal = randi([0,1],signal_length,1); %generujemy sobie losowy wektor zerojedynek :)


%****************************       KODER       ***************************

%sygnal musi byc podzielny przez 4 poniewaz kazda paczka bedzie zawierala 3
%bity korygujace - w sumie wychodzi 7 tak jak w zalozeniu - n paczek po 7
%bitów.


%uzupelniamy dodatkowymi zerami
if mod(signal_length,4)~=0
zeros_num = 4 - mod(signal_length,4);
    for i = 1:zeros_num
        signal(signal_length+i) = 0;                
    end
else
%liczba dodatkowych zer
zeros_num = 0;
end
signal_length = signal_length + zeros_num;
nwords = signal_length/4; %ilosc slow
signal = vec2mat(signal, nwords); %zamiana na macierz po 4 slowa

% KODER %----------------------------------------------------------
encoded = zeros(7,nwords); %macierz zakodowanych słów (na razie pusta)
n = 7; %# liczba bitów na słowo
k = 4; %# liczba bitów informacyjnych na słowo
A = [ 1 1 1; 1 1 0; 1 0 1; 0 1 1 ]; %(dziesiętna komkinacja 7,6,5,3)            
G = [ eye(k) A ]; %macierz generująca
H = [ A' eye(n-k) ]; %macierz parzystości


for j=1:nwords
word = signal(1+(j-1)*4:4*j); %blok do zakodowania - dowolne 4 bity
code = mod(word*G,2); %kodowanie

encoded(1+(j-1)*7:7*j) = code; %dodawanie zakodowanych słów do macierzy

end

%wprowadzanie błędu w n-tym bicie k-tego słowa encoded(n,k)
%------------------------------------------------------------------
encoded_err = encoded; %otrzymany kod z błędem
encoded_err(1,2)=~encoded_err(1,2); %wprowadzanie błędu 
%encoded_err(1,3)=~encoded_err(1,3); %wprowadzanie błędu (na koniec pokaże 2)
%encoded_err(1,10)=~encoded_err(1,10); %etc... 
%encoded_err(1,13)=~encoded_err(1,13);


%obliczanie
%syndromu-----------------------------------------------------------

err_num = 0; %liczba słów z błędem

for i=1:nwords
    code = encoded_err(1+(i-1)*7:i*7);
    recd = code; %otrzymane słowo z błędem
    syndrome = mod(recd * H',2);
    
    find = 0;
    for ii = 1:n
        if ~find
            errvect = zeros(1,n);
            errvect(ii) = 1;
            search = mod(errvect * H',2);
            if search == syndrome
                find = 1;
                err_num = err_num+1;
                index = ii;
                disp(['Pozycja błędu= ',num2str(index), ' w słowie nr ', num2str(i)]);
                correctedcode = recd;
                correctedcode(index) = mod(recd(index)+1,2);%Poprawione słowo
                encoded_err(1+(i-1)*7:i*7) = correctedcode;
                disp('Poprawiono słowo');
            end
        end
    end
    if ~find
    disp(['Nie wykryto błędu w słowie nr ', num2str(i)]);
    end
end
disp(['Wykryta ilość słów z błędem= ', num2str(err_num)]);
% DEKODER %--------------------------------------------------------------

decoded = encoded_err;
decoded(7,:) = [];
decoded(6,:) = [];
decoded(5,:) = [];

err_ratio = err_num/nwords * 100; %stosunek wykrytych błedów do wszystkich słów w procentach
disp(['Stosunek wykrytych błędów do ogólnej liczby słów= ', num2str(err_ratio), '%']);

% KODY %----------------------------------------------------------------
%Pozycja błędu     Syndrom      Dziesiętnie   4 bity     zakodowane 
%    1               111             7         0000       0000000
%    2               110             6         0001       0001011   
%    3               101             5         0010       0010101   
%    4               011             3         0011       0011110   
%    5               100             4         0100       0100110   
%    6               010             2         0101       0101101   
%    7               001             1         0110       0110011   
%Brak błędu da syndrom 000                     0111       0111000   
%                                              1000       1000111   
%                                              1001       1001100    
%                                              1010       1010010    
%                                              1011       1011001     
%                                              1100       1100001     
%                                              1101       1101010     
%                                              1110       1110100     
%                                              1111       1111111