import ctypes
import timeit

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

libmain = ctypes.CDLL("./libmain.so")
decrypt = libmain.decrypt

data = b"super a secret message" * 100
key = b"0123456789123456"
aesgcm = AESGCM(key)
nonce = b"012345678912"
ct = aesgcm.encrypt(nonce, data, None)
tag = ct[-16:]
ct_wo_tag = ct[:-16]


def decrypt_python(ciphertext):
    return aesgcm.decrypt(nonce, ciphertext, None)


def decrypt_zig(ciphertext):
    ct_len = len(ciphertext)
    result_buf = ctypes.create_string_buffer(ct_len)
    decrypt(
        key,
        nonce,
        tag,
        ciphertext,
        ctypes.c_uint32(ct_len),
        result_buf,
        ctypes.c_uint32(ct_len),
    )
    return result_buf.value


print(decrypt_python(ct) == decrypt_zig(ct_wo_tag))

pd = timeit.timeit(lambda: decrypt_python(ct), number=10000)
zd = timeit.timeit(lambda: decrypt_zig(ct_wo_tag), number=10000)
print("python", pd)
print("zig", zd)
print("python" if pd < zd else "zig", "won")
