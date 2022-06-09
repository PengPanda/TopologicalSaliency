function NorMap = NormalizeMap(Img)

[~,~,D] = size(Img);

if D ~= 1
    fprintf(2,'Wrong Dimension!');
end

maxValue  = max(Img(:));
minValue  = min(Img(:));

NorMap = (Img - minValue)./(maxValue - minValue + 0.001);