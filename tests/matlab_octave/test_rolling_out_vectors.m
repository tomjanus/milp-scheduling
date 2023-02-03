function y = test_rolling_out_vectors()
  %
  i_dim = 3;
  j_dim = 2;
  k_dim = 4;
  
  A = zeros(i_dim*j_dim*k_dim,1);
  b = zeros(k_dim, j_dim, i_dim);
 
  row = 1;
  for i = 1:i_dim
    for j = 1:j_dim
      for k = 1:k_dim
        A(row) = row;
        b(k,j,i) = row;
        row = row + 1;
      end
    end
  end
  b = b(:);
  if A == b
    y = 1;
  else
    y = 0;
  end
end
