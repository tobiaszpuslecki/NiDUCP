clear
m=3; %minimalne m=3
signal_len = 20;
while(signal_len > power(2,m) - 1) 
    %pętla określająca m dla 2^m-1
    m=m+1;
end
n=power(2,m) - 1; %długość kodu
k=n-m; 
%długość przesyłanej wiadomości uzupełnionej zerami

signal = randi([0 1],signal_len,1); %sygnał
vec_len = k-signal_len; %długość wektora zer
vec=zeros(vec_len,1); %wektor zer
data = [signal; vec]; %wiadomość przesyłana


encData = encode(data,n,k,'hamming/binary'); %kodowanie wiadomości






canalMakeNoise2D( encData, n, 0.9);



%dekodowanie
decData = decode(encData,n,k,'hamming/binary'); %odkodowanie wiadomości

%skaracanie zer
data_len = numel(data);
decData = decData(1:data_len);
%wyświetlanie wiadomości o błędach
disp('Ilość błędów po odkodowaniu: ')
disp(biterr(data,decData))
%dla 0 dekoder prawidłowo odkodował wiadomość













function result = canalMakeNoise2D( arr, N, noiseProbability )
  result = arr;
    for j = 1:N
      if(rand()> noiseProbability )
        result(j) = result(j)*round(rand());
      end
    end
  return;
end

