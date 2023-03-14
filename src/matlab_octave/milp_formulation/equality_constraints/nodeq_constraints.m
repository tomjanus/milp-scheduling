function [Aeq_nodeq, beq_nodeq] = nodeq_constraints(vars, network, input)
  % Apply flow mass balance constraints in all nodes
  % For every node j for all time steps k = 1 .. N 
  % \sum q_{in}^j (k) - \sum q_{out}^j (k) = 0 
  Lc = network.Lc;
  no_equalities = size(Lc,1);
  number_time_steps = size(vars.x_cont.qel,1);
  % Initialize output arrays
  Aeq_nodeq = zeros(no_equalities*number_time_steps, var_struct_length(vars));
  beq_nodeq = zeros(no_equalities, number_time_steps)';
  row_counter = 1;
  for j = 1:no_equalities
    for i = 1:number_time_steps
      Aeq=vars;
      in_flows = find(Lc(j,:)==1);
      out_flows = find(Lc(j,:)==-1);
      Aeq.x_cont.qel(i,in_flows) = 1;
      Aeq.x_cont.qel(i,out_flows) = -1;
      d_ji = input.demands(j,i) * input.df;
      Aeq_nodeq(row_counter,:) = struct_to_vector(Aeq)';
      beq_nodeq(i,j)=d_ji;
      row_counter = row_counter + 1;
    end
  end
  beq_nodeq = tensor_to_vector(beq_nodeq); %beq_nodeq(:);
end
