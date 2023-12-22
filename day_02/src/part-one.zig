const std = @import("std");
const fs = std.fs;

const Allocator = std.mem.Allocator;

const BUFFER_SIZE = 1024;

const RED_CUBES: u8 = 12;
const GREEN_CUBES: u8 = 13;
const BLUE_CUBES: u8 = 14;

fn tokenize(str: []const u8, allocator: Allocator) ![*]u8 {
    _ = allocator;
    _ = str;
}

pub fn solve(filepath: []const u8, allocator: Allocator) !usize {
    var buffer: []u8 = try allocator.alloc(u8, BUFFER_SIZE);
    var fbs = std.io.fixedBufferStream(buffer);
    defer allocator.free(buffer);

    const file = try fs.cwd().openFile(filepath, .{ .mode = .read_only });
    const reader = file.reader();
    defer file.close();

    var eof: bool = false;
    while (!eof) {
        // Read line
        reader.streamUntilDelimiter(fbs.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => eof = true,
            error.StreamTooLong => {
                std.debug.print("Line too long! Please increase the buffer size.\n", .{});
                return err;
            },
            else => unreachable,
        };

        // Process line
        // const tokens: [*]u8 = tokenize(fbs.getWritten());

        std.debug.print("{s}\n", .{fbs.getWritten()});
        defer fbs.reset(); // Reset fbs buffer
    }

    return 0;
}
