const std = @import("std");
const fs = std.fs;

const MAX_BUFFER_SIZE = 1024 * 4; // 4 Kilobytes

const p1 = @import("part-one.zig");

pub fn main() !void {
    // Create memory allocator
    var buffer: [MAX_BUFFER_SIZE]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const inputPath: []const u8 = "input/data.txt";

    try stdout.print("Result for part 01: {d}\n", .{try p1.solve(inputPath, &allocator)});
    try bw.flush(); // don't forget to flush!
}

test "test part 01 with sample data" {
    const expected: u32 = 142;
    const actual = try p1.solve("input/sample_1.txt", &std.testing.allocator);

    try std.testing.expectEqual(expected, actual);
}
