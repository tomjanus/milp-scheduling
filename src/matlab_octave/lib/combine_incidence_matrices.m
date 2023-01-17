function out = combine_incidence_matrices(Lc, Lf)
  % Combines the incidence matrices for calculated and
  % fixed nodes, respectively
  % Returns:
  %   structure with fields `matrix` with the combined incidence
  %   matrix and `limits` with two 2x1 arrays of row indices 
  %   defining the ranges of the Lc and Lf matrices within L
  out.matrix = [Lc;Lf];
  out.limits.Lc = [1 size(Lc,1)];
  out.limits.Lf = [size(Lc, 1)+1, size(out.matrix, 1)];
