function vector = inject_vector(recipient_vec, injection_vec, start_position)
  % Take the injection vector and place it into the recipient vector at a
  % position (index) given in argument `start_position'
  
  % * * * * * *                   (recipient vector)
  %     ^
  %     |   injection position
  %     |
  % x x x                         (injection vector)
  %                 produces
  % * * x x x *                   (result)
  
  length_recipient = length(recipient_vec);
  length_injection = length(injection_vec);
  end_position = start_position + length_injection - 1;
  % Check if the injection vector will fit into the recipient vector
  if end_position > length_recipient
    difference = end_position - length_recipient;
    max_length = length_injection - difference;
    error("Injected vector of length %d too long. Max. Length = %d\n",...
      length_injection, max_length);
  end
  vector = recipient_vec;
  vector(start_position:end_position)=injection_vec;
end
