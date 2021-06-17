function data = preprocess(datain)
data = datain;
for i = 1:length(datain)
    if datain(i) == 'falso' || datain(i) == 'Falso'
        data(i) = 'Falso';
    elseif datain(i) == 'verdadeiro' || datain(i) == 'Verdadeiro' || datain(i) == 'Verdadeiro, mas'
        data(i) = 'Verdadeiro';
    else
        data(i) = 'Semi-Verdadeiro';
    end
end