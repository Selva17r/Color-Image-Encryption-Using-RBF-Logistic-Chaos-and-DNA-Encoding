function decrypt_image_dna_scramble(encrypted_image_path, sha256_key)
    % Parameters for logistic map
    u1 = 3.99;
    x0 = 0.5;

    % Read the encrypted image
    encrypted_image = imread(encrypted_image_path);
    [height, width, channels] = size(encrypted_image);

    if channels ~= 3
        error('Input image must be an RGB image.');
    end

    % Extract encrypted R, G, B channels
    R_enc = double(encrypted_image(:,:,1));
    G_enc = double(encrypted_image(:,:,2));
    B_enc = double(encrypted_image(:,:,3));

    % Generate same logistic scrambling indices
    scrambled_indices = logistic_scramble(height, width, u1, x0);

    % Apply DNA-based decryption using the same SHA-256 key
    R_dec = dna_decrypt(R_enc, scrambled_indices, sha256_key);
    G_dec = dna_decrypt(G_enc, scrambled_indices, sha256_key);
    B_dec = dna_decrypt(B_enc, scrambled_indices, sha256_key);

    % Combine decrypted channels
    decrypted_image = uint8(cat(3, R_dec, G_dec, B_dec));

    % Display results
    figure;
    subplot(1,2,1), imshow(encrypted_image), title('Encrypted Image');
    subplot(1,2,2), imshow(decrypted_image), title('Decrypted (Recovered) Image');

    % Get original image name from encrypted file name
    [~, original_name, ~] = fileparts(encrypted_image_path);
    output_filename = ['decrypted_' original_name '.png'];

    % Save the recovered image
    imwrite(decrypted_image, output_filename);
    fprintf('Decrypted image saved as: %s\n', output_filename);
end

%% 🔹 Logistic Scramble (Same as Encryption)
function scrambled_indices = logistic_scramble(height, width, u1, x0)
    total_pixels = height * width;
    X = zeros(total_pixels, 1);
    X(1) = x0;

    for i = 2:total_pixels
        X(i) = u1 * X(i-1) * (1 - X(i-1));
    end

    scrambled_indices = mod(floor(X * total_pixels), total_pixels) + 1;
    scrambled_indices = unique(scrambled_indices);
end

%% 🔹 DNA-Based Decryption
function decrypted = dna_decrypt(channel, scrambled_indices, sha256_key)
    [height, width] = size(channel);
    total_pixels = height * width;

    % Convert to binary
    binary_str = string(dec2bin(channel, 8));

    % DNA encoding
    dna_sequence = replace(binary_str, ["00", "01", "10", "11"], ["A", "T", "C", "G"]);
    dna_sequence = dna_sequence(:); % Flatten

    % Generate permutation from SHA-256 key
    seed = mod(hex2dec(sha256_key(1:8)), total_pixels);
    rng(seed);
    perm_indices = randperm(total_pixels);

    % Reverse the permutation
    inverse_perm = zeros(size(perm_indices));
    inverse_perm(perm_indices) = 1:total_pixels;
    unscrambled_dna = dna_sequence(inverse_perm);

    % Convert DNA back to binary
    binary_back = replace(unscrambled_dna, ["A", "T", "C", "G"], ["00", "01", "10", "11"]);

    % Convert binary to decimal and reshape
    decrypted = reshape(uint8(bin2dec(binary_back)), height, width);
end

