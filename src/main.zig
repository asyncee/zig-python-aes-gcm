const std = @import("std");
const Aes128Gcm = std.crypto.aead.aes_gcm.Aes128Gcm;

pub fn main() !void {
    const key: [Aes128Gcm.key_length]u8 = [_]u8{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '1', '2', '3', '4', '5', '6'};
    const nonce: [Aes128Gcm.nonce_length]u8 = [_]u8{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '1', '2'};
    const m = "a secret message";
    const ad = "";
    var c: [m.len]u8 = undefined;
    var tag: [Aes128Gcm.tag_length]u8 = undefined;

    Aes128Gcm.encrypt(&c, &tag, m, ad, nonce, key);

    var m3: [c.len]u8 = undefined;
    const k: [*]u8 = @constCast(&key);
    const n: [*]u8 = @constCast(&nonce);
    //decrypt(k, n, &tag, &c, c.len, &m3, m3.len);
    decrypt(k, n, c ++ tag, c.len, &m3, m3.len);

    std.debug.print("{d} {d} {x}\n", .{m.len, c.len, c});

    std.debug.print("{s}\n", .{m3[0..c.len]});
}

export fn decrypt(
    key: [*]u8,
    nonce: [*]u8,
    ciphertext: [*]u8,
    data_len: usize,
    msg: [*]u8,
    msg_len: usize,
) void {
    const aad = "";
    const k = key[0..Aes128Gcm.key_length];
    const n = nonce[0..Aes128Gcm.nonce_length];
    const tag: [Aes128Gcm.tag_length]u8 = ciphertext[data_len..data_len+Aes128Gcm.tag_length];
    const text = ciphertext[0..data_len];
    const result_buf = msg[0..msg_len];

    Aes128Gcm.decrypt(result_buf, text, tag, aad, n.*, k.*) catch {
        std.debug.print("error :(", .{});
    };
}
