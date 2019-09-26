% # Koder:
% # a) Hamming (D)
% # b) Reed-Salamon (M)
% # c) CRC (E)
% # Koder dzieli na pakiety po x paczek 7b
% # Każda paczka jest kodowana korekcyjnie
%
%
% # Kanał:
%
% # Dekoder:
% # Dekoder odwraca proces kodowania i buduje dużą tablicę z paczek
%
% # Analiza:
% # Wyliczyć ile błędów wyszło
%
%# CONFIG ############
clear;
clc;

numberOfArrays = 5;
numberOfBits   = 1000;
noiseProbability = 0.9; % Prawdopodobieństwo przejścia bitu w stan przeciwny
%#####################

disp("NiDUC2P Szybkie Sumatory")
disp("Temat: FEC")
disp("In : Tablica losowa 1000bit")
disp("Out: Procent poprawnego przesłania")
disp("Koder->Kanał->Dekoder->Analiza")
disp(" ")


% Generator n ciągów m-bitowych
randomBitsArrays = generateRandomBitsArrays(numberOfBits,numberOfArrays);

signal_len = numberOfBits;
signal = randi([0,1],signal_len,1);


%# Kodowanie

    %CRC
    signal_CRC = signal;
    signal_len_CRC = signal_len;
    while mod(signal_len_CRC,7)~=0 %dopoki dlugosc niepodzielna przez 7 to uzupelniamy zerami
        signal_CRC(signal_len_CRC+1)=0;
        signal_len_CRC=signal_len_CRC+1;
    end
    frames_CRC = length(signal_CRC)/7; %ile paczek po 7b
    generator_CRC = comm.CRCGenerator([1,0,1,0,1],'ChecksumsPerFrame',frames_CRC); %wielomian generatora ma postac x^4+x^2+1
    codeword_CRC = step(generator_CRC,signal_CRC); %zakodowany sygnal
    %/CRC

    %Hamming

    signal_H = signal;
    signal_length_H = signal_len;

    if mod(signal_length_H,4)~=0 %uzupelniamy dodatkowymi zerami
    zeros_num_H = 4 - mod(signal_length_H,4);
        for i = 1:zeros_num_H
            signal_H(signal_length_H+i) = 0;
        end
    else

    zeros_num_H = 0;  %liczba dodatkowych zer
    end
    signal_length_H = signal_length_H + zeros_num_H;
    nwords_H = signal_length_H/4; %ilosc slow
    signal_H = vec2mat(signal_H, nwords_H); %zamiana na macierz po 4 slowa

    % KODER %----------------------------------------------------------
    encoded_H = zeros(7,nwords_H); %macierz zakodowanych słów (na razie pusta)
    n = 7; %# liczba bitów na słowo
    k = 4; %# liczba bitów informacyjnych na słowo
    A = [ 1 1 1; 1 1 0; 1 0 1; 0 1 1 ]; %(dziesiętna komkinacja 7,6,5,3)
    G = [ eye(k) A ]; %macierz generująca
    H = [ A' eye(n-k) ]; %macierz parzystości


    for j=1:nwords_H
    word = signal_H(1+(j-1)*4:4*j); %blok do zakodowania - dowolne 4 bity
    code = mod(word*G,2); %kodowanie

    encoded_H(1+(j-1)*7:7*j) = code; %dodawanie zakodowanych słów do macierzy

    end


    %/Hamming

    %RS
    signal_RS = signal;
    signal_length_RS = signal_len;


    if mod(signal_length_RS,4) == 0            %liczba dodatkowych zer
        zeros_RS = 0;
    else
        zeros_RS = 4 - mod(signal_length_RS,4);
    end

    %sygnal musi byc podzielny przez 4 poniewaz kazda paczka bedzie zawierala 3
    %bity korygujace - w sumie wychodzi 7 tak jak w zalozeniu - n paczek po 7
    %bit�w.
    for i = 1:zeros_RS
        signal_RS(signal_length_RS+i) = 0;                %uzupelniamy dodatkowymi zerami
    end

    signal_length_RS = signal_length_RS + zeros_RS;          %korygujemy dlugosc sygnalu

    nwords_RS = signal_length_RS/4;                       %jest to ilosc wszystkich slow

    m_RS = 3;                                          %liczba bitow koryguj?cych na slowo
    n_RS = 2^m_RS - 1;                                    %dlugosc slowa
    k_RS = 4;                                          %liczba bitow niekorygujacych

    t = bchnumerr(n_RS,k_RS);                             %zdolnosc poprawiania b??du

    signal_RS';                                        %debug sygnal przed pocieciem

    signalx = reshape(signal_RS,4,[])';                %przetworzenie sygnalu na postac (n x 4) wektor�w - pociecie go

    beforeEnc = gf(signalx);                         %argument sygnalu musi byc tablica Galois

    encSignal_RS = bchenc(beforeEnc,n_RS,k_RS);               %zakodowanie sygnalu w postaci (n x 7) wektor�w



    %/RS






%# Kanal
    %noiseBitsArrays = canalMakeNoise(randomBitsArrays, numberOfArrays,numberOfBits, noiseProbability );

    codewordNoised_CRC   = canalMakeNoise2D(codeword_CRC, signal_len_CRC, noiseProbability);
    encodedNoisedHamming = canalMakeNoise2D(encoded_H, signal_length_H, noiseProbability);
    encSignalNoisedRS    =  canalMakeNoise2D(encSignal_RS, signal_length_RS, noiseProbability);

%# Dekoder



    %CRC
    detect_CRC = comm.CRCDetector([1,0,1,0,1],'ChecksumsPerFrame',frames_CRC); %dekodujemy sygnal

    %/CRC

    %Hamming

        err_num = 0; %liczba słów z błędem

    for i=1:nwords_H
        code = encodedNoisedHamming(1+(i-1)*7:i*7);
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
                    %disp(['Pozycja błędu= ',num2str(index), ' w słowie nr ', num2str(i)]);
                    correctedcode = recd;
                    correctedcode(index) = mod(recd(index)+1,2);%Poprawione słowo
                    encodedNoisedHamming(1+(i-1)*7:i*7) = correctedcode;
                    %disp('Poprawiono słowo');
                end
            end
        end
        if ~find
        %disp(['Nie wykryto błędu w słowie nr ', num2str(i)]);
        end
    end
    %disp(['Wykryta ilość słów z błędem= ', num2str(err_num)]);
    % DEKODER %--------------------------------------------------------------

    decoded = encodedNoisedHamming;
    decoded(7,:) = [];
    decoded(6,:) = [];
    decoded(5,:) = [];



    %/Hamming


    %RS
    afterDec = bchdec(encSignalNoisedRS,n,k);                %zdekodowany sygnal

    isequal(beforeEnc,afterDec);                     %zwraca 1 gdy sygnal przed kodowaniem i po przejsciu przez szum oraz po dekodowaniu sa takie same

    %beforeEnc - sygnal przed zakodowaniem

    %afterDec - sygnal po zdekodowaniu

    %endSignal - sygnal zakodowany


    %/RS


%# Analiza

    %CRC
    [~, err_CRC] = step(detect_CRC,signal_CRC); %wektor ktory ma dlugosc taka jaka jest liczba ramek, do sprawdzania gdzie wystapil blad

    err_scalar_CRC = sum(err_CRC(:)==0);
    disp("CRC Error %      :  " + err_scalar_CRC/frames_CRC*100 + "%");
    %/CRC

    %Hamming
    err_ratio = err_num/nwords_H * 100; %stosunek wykrytych błedów do wszystkich słów w procentach
    disp(['Hamming Error %  :  ', num2str(err_ratio), '%']);
    %/Hamming

    %RS
    mistakes = 0;
    for i = 1:nwords_RS  %nwords * 4 = d?ugosc sygnalu
        for j = 1:4
            if beforeEnc(i,j) ~= afterDec(i,j)
                mistakes = mistakes + 1;
            break
            end
        end
    end

    err_scalar_RS = mistakes/nwords_RS*100;
    disp("RS Error %       :  " + err_scalar_RS + "%");
    %/RS









function result = canalMakeNoiseND( arr, n, N, noiseProbability )
  result = arr;
  for i = 1:n
    for j = 1:N
      if(rand()> noiseProbability )
        result(i,j) = result(i,j)*round(rand());
      end
    end
  end

  return;
end

function result = canalMakeNoise2D( arr, N, noiseProbability )
  result = arr;
    for j = 1:N
      if(rand()> noiseProbability )
        result(j) = result(j)*round(rand());
      end
    end
  return;
end

function result = generateRandomBitsArrays( n,N ) %# n - how many arrays, N - how many bits
 result = randi([0,1],N,n);
 return;
end
