signal_len = input('Podaj dlugosc sygnalu: ');

signal = randi([0,1],signal_len,1) %generujemy sobie losowy wektor zerojedynek :)

while mod(signal_len,7)~=0 %dopoki dlugosc niepodzielna przez 7 to uzupelniamy zerami
    signal(signal_len+1)=0;
    signal_len=signal_len+1;
end    

frames = length(signal)/7; %ile paczek po 7b
generator = comm.CRCGenerator([1,0,1,0,1],'ChecksumsPerFrame',frames); %wielomian generatora ma postac x^4+x^2+1
codeword = step(generator,signal) %zakodowany sygnal


detect = comm.CRCDetector([1,0,1,0,1],'ChecksumsPerFrame',frames); %dekodujemy sygnal
[~, err] = step(detect,codeword); %wektor ktory ma dlugosc taka jaka jest liczba ramek, do sprawdzania gdzie wystapil blad 

if(err==0) %jak wszedzie sa zera to nie wystapil blad :)
    disp('No error founded');
end
