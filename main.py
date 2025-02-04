import ctypes
import timeit

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

TAG_LENGTH = 16

libmain = ctypes.CDLL("./libmain.so")
decrypt = libmain.decrypt

message = b"a secret message"
key = b"0123456789123456"
aesgcm = AESGCM(key)
nonce = b"012345678912"
ciphertext = aesgcm.encrypt(nonce, message, None)


def decrypt_python():
    return aesgcm.decrypt(nonce, ciphertext, None)


def decrypt_zig():
    text_len = len(ciphertext)
    result_buf = ctypes.create_string_buffer(text_len - TAG_LENGTH)
    decrypt(
        key,
        nonce,
        ciphertext,
        ctypes.c_uint32(text_len),
        result_buf,
        ctypes.c_uint32(len(result_buf)),
    )
    return result_buf.value


if __name__ == "__main__":
    print("python-decrypted ciphertext:", decrypt_python())
    print("zig-decrypted ciphertext:", decrypt_zig())

    python_time = timeit.timeit(lambda: decrypt_python(), number=10000)
    zig_time = timeit.timeit(lambda: decrypt_zig(), number=10000)

    print("python decryption time:", python_time)
    print("zig decryption time:", zig_time)
    print("python" if python_time < zig_time else "zig", "won")
