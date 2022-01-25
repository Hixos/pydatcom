function d = ndiag(A)
    n = length(size(A));
    L = min(size(A));
    d = zeros(n,1);
    
    for i=1:L
        c = num2cell(ones(1,n)*i);
        d(i) = A(c{:});
    end
end