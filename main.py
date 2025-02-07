import ctypes
import timeit

from cffi import FFI
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

ffi = FFI()
ffi.cdef(
    """
    void decrypt(
        char* key,
        char* nonce,
        char* ciphertext,
        size_t ciphertext_len,
        char* message_buf,
        size_t message_len
    );
"""
)

ffi_libmain = ffi.dlopen("./libmain.so")

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


def decrypt_zig_ffi():
    text_len = len(ciphertext)
    result_buf = ffi.new("char[]", text_len - TAG_LENGTH)

    ffi_libmain.decrypt(
        key,
        nonce,
        ciphertext,
        text_len,
        result_buf,
        len(result_buf),
    )
    return ffi.buffer(result_buf)[:]


if __name__ == "__main__":
    print("python-decrypted ciphertext:", decrypt_python())
    print("zig-decrypted ciphertext:", decrypt_zig())
    print("zig-decrypted ciphertext (ffi):", decrypt_zig_ffi())

    python_time = timeit.timeit(lambda: decrypt_python(), number=10000), "python"
    zig_time = timeit.timeit(lambda: decrypt_zig(), number=10000), "zig"
    zig_ffi_time = timeit.timeit(lambda: decrypt_zig_ffi(), number=10000), "zig ffi"

    print("python decryption time:", python_time[0])
    print("zig decryption time:", zig_time[0])
    print("zig decryption time (ffi):", zig_ffi_time[0])

    winner = min(python_time, zig_time, zig_ffi_time)
    print(winner[1], "won")
