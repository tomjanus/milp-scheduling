function array_indices = get_array_indices(input_array)
    % Output a Nx1 cell with indices pointing to all elements of
    % a multidimensional array
    array_size = size(input_array)
    index_vectors = cell(length(array_size), 1);
    for n_dim = 1:length(array_size)
        index_vectors{n_dim} = 1:array_size(n_dim);
    end
    if length(index_vectors) == 1
        m = ngrid(index_vectors{1});
        array_indices = [m(:)];
    elseif length(index_vectors) == 2
        [m,n] = ndgrid(index_vectors{1},index_vectors{2});
        array_indices = [m(:),n(:)];
    elseif length(index_vectors) == 3
        [m,n,o] = ndgrid(index_vectors{1},index_vectors{2},index_vectors{3});
        array_indices = [m(:),n(:),o(:)];
    else
        error("Only input arrays of dim 1-3 are supported");
        array_indices = [];
    end
