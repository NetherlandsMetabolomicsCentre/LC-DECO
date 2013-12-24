function q = deco_entropy(data)
%----------------------------

data = deco_transform(data);
idx = find(data>0); % remove zero elements
data = data(idx); % make column vector
len  = sqrt(sum(data .^ 2)); % get length of vector
data=  ( data ./ len) .^ 2; % normalize vector

id = find(data<=0);
if (length(id)>0) 
    data(id) = []; 
end 
q =-sum(data .* log(data)); % calculate entropy of vector
end

function data = deco_transform(data)

for i=1:size(data,2)-1
    data(i) = min(data(i), data(i+1));
    
end

end