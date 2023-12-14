const std = @import("std");
const fs = std.fs;

const MAX_BUFFER_SIZE = 1024 * 4; // 4KBs

pub fn solve(filepath: []const u8, allocator: *const std.mem.Allocator) !u32 {
    const file = try fs.cwd().openFile(filepath, .{ .mode = .read_only });
    var buffer = try allocator.alloc(u8, 1024);
    defer {
        file.close();
        allocator.free(buffer);
    }

    var total: u32 = 0;
    var lead: u8 = 0;
    var tail: u8 = 0;
    while (file.read(buffer)) |max_length| {
        if (max_length == 0) {
            total += lead * 10 + tail;
            break;
        }

        for (buffer[0..max_length]) |byte| {
            switch (byte) {
                '0'...'9' => {
                    lead = if (lead == 0) byte - '0' else lead;
                    tail = byte - '0';
                },
                '\n' => {
                    total += (lead * 10) + tail;
                    lead = 0;
                    tail = 0;
                },
                else => {}, // Do nothing here
            }
        }
    } else |err| return err;

    return total;
}
