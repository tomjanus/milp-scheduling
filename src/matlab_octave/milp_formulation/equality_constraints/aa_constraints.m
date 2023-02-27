function [Aeq_aa, beq_aa] = aa_constraints(vars)
  % Applies constraints to pump segment selection variables aa
  % for all k = 1..K for all j in E_{pump} \sum_i^{n_seg} aa_i^j - n_j = 0
  
  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  
  number_time_steps = size(vars.x_bin.aa, 2);
  number_pumps = size(vars.x_bin.n, 2);
  number_segments = size(vars.x_bin.aa, 1);
  % Initialize output arrays
  Aeq_aa = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  beq_aa = zeros(number_time_steps,number_pumps);
  row_counter = 1;
  % TODO: This loop will need to be generalized into groups and pumps per group
  %       and the variable n will have to be a 3D array with additional
  %       dimension defining every pump group in the model
  for j = 1:number_pumps
      for i = 1:number_time_steps
        Aeq = vars;
        Aeq.x_bin.aa(:,i,j) = 1;
        Aeq.x_bin.n(i,j) = -1;
        Aeq_aa(row_counter,:) = struct_to_vector(Aeq)';
        beq_aa(i,j)=0;
        row_counter = row_counter + 1;
      end
  end
  beq_aa = beq_aa(:);
end