function ImageEncryptDecryptGUI
    % Create UI Figure
    fig = uifigure('Position', [500 300 600 400], 'Name', 'Image Encryption/Decryption GUI');

    % Global Variables
    global sha256_key;
    global selected_image_path;

    % UI Components
    ax = uiaxes(fig, 'Position', [20 180 240 180]);
    title(ax, 'Selected Image');
    axis(ax, 'off');

    lblKey = uilabel(fig, 'Position', [280 310 100 22], 'Text', 'SHA-256 Key:');
    txtKey = uitextarea(fig, 'Position', [280 240 280 70]);

    btnSelectImage = uibutton(fig, ...
        'Position', [280 200 280 30], ...
        'Text', '1. Select Image & Generate Key', ...
        'ButtonPushedFcn', @(btn, event) generateKey());

    btnEncrypt = uibutton(fig, ...
        'Position', [280 160 280 30], ...
        'Text', '2. Encrypt Image', ...
        'ButtonPushedFcn', @(btn, event) encryptImage());

    btnDecrypt = uibutton(fig, ...
        'Position', [280 120 280 30], ...
        'Text', '3. Decrypt Image', ...
        'ButtonPushedFcn', @(btn, event) decryptImage());

    %% --- Callback Functions ---

    function generateKey()
        [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files'}, 'Select Image');
        if isequal(file, 0)
            uialert(fig, 'No image selected.', 'Warning');
            return;
        end
        selected_image_path = fullfile(path, file);
        img = imread(selected_image_path);
        imshow(img, 'Parent', ax);
        image_vector = img(:);
        image_string = mat2str(image_vector);
        sha256_key = string(DataHash(image_string, struct('Method','SHA-256')));
        txtKey.Value = sha256_key;
    end

    function encryptImage()
        if isempty(txtKey.Value)
            uialert(fig, 'Key not found. Generate it first.', 'Error');
            return;
        end
        if isempty(selected_image_path)
            uialert(fig, 'No image selected.', 'Error');
            return;
        end
        sha256_key = txtKey.Value;
        encrypt_image_dna_scramble(selected_image_path, sha256_key);
    end

    function decryptImage()
        [file, path] = uigetfile({'*.png', 'Encrypted PNG Files'}, 'Select Encrypted Image');
        if isequal(file, 0)
            uialert(fig, 'No image selected for decryption.', 'Warning');
            return;
        end
        if isempty(txtKey.Value)
            uialert(fig, 'SHA-256 Key is required for decryption.', 'Error');
            return;
        end
        sha256_key = txtKey.Value;
        decrypt_image_dna_scramble(fullfile(path, file), sha256_key);
    end
end

%% 🔐 Encryption Function
function encrypt_image_dna_scramble(image_path, sha256_key)
    u1 = 3.99;
    x0 = 0.5;
    original_image = imread(image_path);
    [height, width, channels] = size(original_image);

    if channels ~= 3
        error('Input image must be an RGB image.');
    end

    R = double(original_image(:,:,1));
    G = double(original_image(:,:,2));
    B = double(original_image(:,:,3));
    scrambled_indices = logistic_scramble(height, width, u1, x0);

    encrypted_R = dna_encrypt(R, scrambled_indices, sha256_key);
    encrypted_G = dna_encrypt(G, scrambled_indices, sha256_key);
    encrypted_B = dna_encrypt(B, scrambled_indices, sha256_key);

    encrypted_image = uint8(cat(3, encrypted_R, encrypted_G, encrypted_B));

    figure;
    subplot(1,2,1), imshow(original_image), title('Original Image');
    subplot(1,2,2), imshow(encrypted_image), title('Encrypted Image');

    [~, name, ~] = fileparts(image_path);
    output_filename = [name '_encrypted.png'];
    imwrite(encrypted_image, output_filename);
    fprintf('Encrypted image saved as: %s\n', output_filename);
end

%% 🔓 Decryption Function
function decrypt_image_dna_scramble(encrypted_image_path, sha256_key)
    u1 = 3.99;
    x0 = 0.5;
    encrypted_image = imread(encrypted_image_path);
    [height, width, channels] = size(encrypted_image);

    if channels ~= 3
        error('Input image must be an RGB image.');
    end

    R_enc = double(encrypted_image(:,:,1));
    G_enc = double(encrypted_image(:,:,2));
    B_enc = double(encrypted_image(:,:,3));
    scrambled_indices = logistic_scramble(height, width, u1, x0);

    R_dec = dna_decrypt(R_enc, scrambled_indices, sha256_key);
    G_dec = dna_decrypt(G_enc, scrambled_indices, sha256_key);
    B_dec = dna_decrypt(B_enc, scrambled_indices, sha256_key);

    decrypted_image = uint8(cat(3, R_dec, G_dec, B_dec));

    figure;
    subplot(1,2,1), imshow(encrypted_image), title('Encrypted Image');
    subplot(1,2,2), imshow(decrypted_image), title('Decrypted Image');

    [~, original_name, ~] = fileparts(encrypted_image_path);
    output_filename = ['decrypted_' original_name '.png'];
    imwrite(decrypted_image, output_filename);
    fprintf('Decrypted image saved as: %s\n', output_filename);
end

%% 🔄 Logistic Scramble
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

%% 🧬 DNA Encrypt
function encrypted = dna_encrypt(channel, scrambled_indices, sha256_key)
    [height, width] = size(channel);
    total_pixels = height * width;
    binary_str = string(dec2bin(channel, 8));
    dna_sequence = replace(binary_str, ["00", "01", "10", "11"], ["A", "T", "C", "G"]);

    key_str = char(sha256_key);
    seed = mod(hex2dec(key_str(1:8)), total_pixels);
    rng(seed);
    perm_indices = randperm(total_pixels);

    scrambled_dna = dna_sequence(:);
    scrambled_dna = scrambled_dna(perm_indices);

    binary_back = replace(scrambled_dna, ["A", "T", "C", "G"], ["00", "01", "10", "11"]);
    encrypted = reshape(uint8(bin2dec(binary_back)), height, width);
end

%% 🧬 DNA Decrypt
function decrypted = dna_decrypt(channel, scrambled_indices, sha256_key)
    [height, width] = size(channel);
    total_pixels = height * width;
    binary_str = string(dec2bin(channel, 8));
    dna_sequence = replace(binary_str, ["00", "01", "10", "11"], ["A", "T", "C", "G"]);
    dna_sequence = dna_sequence(:);

    key_str = char(sha256_key);
    seed = mod(hex2dec(key_str(1:8)), total_pixels);
    rng(seed);
    perm_indices = randperm(total_pixels);

    inverse_perm = zeros(size(perm_indices));
    inverse_perm(perm_indices) = 1:total_pixels;
    unscrambled_dna = dna_sequence(inverse_perm);

    binary_back = replace(unscrambled_dna, ["A", "T", "C", "G"], ["00", "01", "10", "11"]);
    decrypted = reshape(uint8(bin2dec(binary_back)), height, width);
end
