function [Aeq, beq] = set_Aeq_beq_matrices(vars, network, input, lin_pipes, ...
                                           sparse_out)
  % Calculate all equality constraints and create Aeq and beq matrices
  [Aeq_ht, beq_ht] = ht_constraints(vars, network);
  [Aeq_qpipe, beq_qpipe] = ww_constraints(vars, network);
  [Aeq_bb, beq_bb] = bb_constraints(vars);
  [Aeq_dhpipe, beq_dhpipe] = pipe_headloss_constraints(vars, network, ...
    input, lin_pipes);

  [Aeq_ss, beq_ss] = ss_constraints(vars);
  [Aeq_qq, beq_qq] = qq_constraints(vars);
  [Aeq_aa, beq_aa] = aa_constraints(vars);
  [Aeq_nodeq, beq_nodeq] = nodeq_constraints(vars, network, input);
  [Aeq_pumpgroup, beq_pumpgroup] = pumpgroup_constraints(vars, network);

  % Concatenate all Aeq matrices and beq vectors
  Aeq = [Aeq_ht; Aeq_qpipe; Aeq_bb; Aeq_dhpipe; Aeq_ss; Aeq_qq; Aeq_aa; ...
    Aeq_nodeq; Aeq_pumpgroup];
  beq = [beq_ht; beq_qpipe; beq_bb; beq_dhpipe; beq_ss; beq_qq; beq_aa; ...
    beq_nodeq; beq_pumpgroup];

  %Aeq = [Aeq_ht; Aeq_qpipe; Aeq_bb; Aeq_ss; Aeq_qq; Aeq_aa; Aeq_pumpgroup];
  %beq = [beq_ht; beq_qpipe; beq_bb; beq_ss; beq_qq; beq_aa; beq_pumpgroup];

  Aeq = [Aeq_qpipe; Aeq_nodeq; Aeq_pumpgroup];
  beq = [beq_qpipe; beq_nodeq; beq_pumpgroup];

  if (sparse_out == true)
    Aeq = sparse(Aeq);
    beq = sparse(beq);
  end
end
