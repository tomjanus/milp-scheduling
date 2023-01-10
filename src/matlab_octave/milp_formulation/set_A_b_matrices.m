function [A, b] = set_A_b_matrices(sparse_out)
  %
  A = [];
  b = [];
  if (sparse_out == true)
    A = sparse(A);
    b = sparse(b);
  end
end
