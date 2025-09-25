# Color Image Encryption Using RBF, Logistic Chaos and DNA Encoding

## Project Overview

This project presents a robust color image encryption technique combining Radial Basis Function (RBF) scrambling, Logistic Chaotic Map diffusion, and DNA-based pixel encoding. The system is designed for high security, randomness, and resilience against cryptographic attacks, making it suitable for real-time digital image protection on cloud platforms and during online transmissions 

## Key Features

- **Hybrid Encryption Algorithm:** Uses RBF for non-linear pixel position confusion and Logistic Chaotic Map for diffusion, maximizing unpredictability.
- **Secure Key Generation:** Integrates user input and image properties, processed with SHA-256 hashing, to create strong initialization keys for the algorithm.
- **Localized Block Scrambling:** Processes images in 8x8 or 16x16 pixel blocks, enabling high confusion within every block.
- **DNA-Based Cryptography:** Applies DNA encoding/decoding with logical and arithmetic operations (XOR, addition) for irreversible pixel value encryption.
- **Comprehensive Security Analysis:** Evaluated with statistical tests (entropy, NPCR, UACI, PSNR, correlation) to ensure resilience to attacks and randomness 

## System Architecture

1. **Key Generation:** User/image driven, SHA-256 hashed, initializes RBF and chaotic systems.
2. **Confusion Phase:** RBF-based non-linear pixel permutation with block-wise shuffling.
3. **Diffusion Phase:** Logistic Chaotic Map alters pixel values using sequences seeded by the key.
4. **DNA Operations:** Additional encryption and decryption steps using DNA sequences.
5. **Validation:** Security validated by entropy, NPCR/UACI, PSNR, and correlation coefficient analysis 

## Performance Metrics

Performance has been validated using:
- **Peak Signal-to-Noise Ratio (PSNR)**
- **Structural Similarity Index (SSIM)**
- **Number of Pixels Change Rate (NPCR)**
- **Unified Average Changing Intensity (UACI)**
- **Mean Squared Error (MSE)**
- **Entropy and Correlation Coefficient Analysis**

## Results

Statistical tests confirm that the system achieves:
- High randomness (verified by entropy close to ideal values)
- Low pixel correlation after encryption
- Robust resistance to brute-force, differential, and statistical attacks
- Efficient computation suitable for real-time applications

## Future Enhancement

Potential improvements include:
- Real-time video encryption support
- Integration with deep learning for intelligent key management
- Optimization for higher-resolution images (e.g., 4K, 8K)
- GPU acceleration for faster processing
- Broader attack model validation (chosen-plaintext, -ciphertext)

---


