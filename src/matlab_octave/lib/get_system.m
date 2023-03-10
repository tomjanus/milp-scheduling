function sw = get_system()
    % Identify whether we are running MATLAB or OCTAVE
    if exist('OCTAVE_VERSION', 'builtin') == 5
        sw = 'Octave';
    else
        sw = 'MATLAB';
    end
end
