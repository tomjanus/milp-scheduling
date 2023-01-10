function [Aeq, beq] = set_Aeq_beq_matrices(sparse_out)
  %
  Aeq = [];
  beq = [];
  if (sparse_out == true)
    Aeq = sparse(Aeq);
    beq = sparse(beq);
  end
end
