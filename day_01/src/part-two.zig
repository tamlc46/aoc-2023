const std = @import("std");
const fs = std.fs;

// String to num map
// O
// └─── N
//      └─── E
// T
// └─── W
// │    └─── O
// └─── H
//      └─── R
//           └─── E
//                └─── E
// F
// ├─── O
// │    └─── U
// │         └─── R
// └─── I
//      └─── V
//           └─── E
// S
// ├─── I
// │    └─── X
// └─── E
//      └─── V
//           └─── E
//                └─── N
// E
// └─── I
//      └─── G
//           └─── H
//                └─── T
// N
// └─── I
//      └─── N
//           └─── E

pub fn solve(filepath: []const u8, comptime allocator: *const std.mem.Allocator) !u32 {
    const file = try fs.cwd().openFile(filepath, .{ .mode = .read_only });
    var buffer = try allocator.alloc(u8, 1024);
    defer {
        file.close();
        allocator.free(buffer);
    }

    var total: u32 = 0;
    var lead: u8 = 0;
    _ = lead;
    var tail: u8 = 0;
    _ = tail;
    while (file.read(buffer)) |max_length| {
        if (max_length == 0) break;
    } else |err| return err;

    return total;
}
