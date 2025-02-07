const std = @import("std");
const Aes128Gcm = std.crypto.aead.aes_gcm.Aes128Gcm;

pub fn main() !void {
    const key: [Aes128Gcm.key_length]u8 = [_]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '1', '2', '3', '4', '5', '6' };
    const nonce: [Aes128Gcm.nonce_length]u8 = [_]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '1', '2' };
    const message = "a secret message";
    const aad = "";
    var ciphertext: [message.len + Aes128Gcm.tag_length]u8 = undefined; // ciphertext + tag

    Aes128Gcm.encrypt(
        ciphertext[0..message.len],
        ciphertext[message.len .. message.len + Aes128Gcm.tag_length],
        message,
        aad,
        nonce,
        key,
    );

    var decrypted_message_buf: [message.len]u8 = undefined;
    const k: [*]u8 = @constCast(&key);
    const n: [*]u8 = @constCast(&nonce);
    decrypt(k, n, &ciphertext, message.len + Aes128Gcm.tag_length, &decrypted_message_buf, decrypted_message_buf.len);
    std.debug.print("{s}\n", .{decrypted_message_buf[0..message.len]});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const arr = [_][]const u8{ "hello", "world" };
    var darr: [arr.len][]u8 = undefined;
    for (arr, 0..) |item, i| {
        var ciphertext2 = try allocator.alloc(u8, item.len + Aes128Gcm.tag_length);

        Aes128Gcm.encrypt(
            ciphertext2[0..item.len],
            @ptrCast(ciphertext2[item.len .. item.len + Aes128Gcm.tag_length]),
            item,
            aad,
            nonce,
            key,
        );
        darr[i] = ciphertext2;
    }
    decrypt_array(&darr, arr.len);
}

export fn decrypt_array(array: [*][]const u8, array_len: usize) callconv(.C) void {
    for (0..array_len) |i| {
        std.debug.print("{s}\n", .{array[i]});
    }
}

export fn decrypt(
    key: [*]u8,
    nonce: [*]u8,
    ciphertext: [*]u8,
    ciphertext_len: usize,
    message_buf: [*]u8,
    message_len: usize,
) void {
    const aad = "";
    const k = key[0..Aes128Gcm.key_length];
    const n = nonce[0..Aes128Gcm.nonce_length];
    const tag: *[Aes128Gcm.tag_length]u8 = @ptrCast(ciphertext[ciphertext_len - Aes128Gcm.tag_length .. ciphertext_len]);
    const text = ciphertext[0 .. ciphertext_len - Aes128Gcm.tag_length];
    const result_buf = message_buf[0..message_len];

    Aes128Gcm.decrypt(result_buf, text, tag.*, aad, n.*, k.*) catch {
        std.debug.print("error", .{});
    };
}
