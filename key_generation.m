function sha256_key = generate_sha256_key(image_path)
    image_data = imread(image_path);
    image_vector = image_data(:); 
    image_string = mat2str(image_vector); 
    sha256_key = string(DataHash(image_string, struct('Method','SHA-256')));
    disp('SHA-256 Key:');
    disp(sha256_key);
end