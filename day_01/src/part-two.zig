const std = @import("std");
const fs = std.fs;

const Allocator = std.mem.Allocator;

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

pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();

        num: ?T,
        next: *[]Self,

        fn dealloc(self: *Self, allocator: Allocator) void {
            // Deallocate following start_node
            if (self.next != null) {
                self.next.len
                self.next.dealloc(allocator);
            }

            // Deallocate current start_node
            allocator.free(self.next);
            self.* = null;
        }
    };
}

const NumericTree = struct {
    const Self = @This();

    start_node: *Node(u8),
    allocator: Allocator,

    pub fn init(allocator: Allocator) Allocator.Error!Self {
        var start_node: *Node(u8) = try allocator.create(Node(u8));
        // start_node.* = .{ .num = null, .next = try allocator.alloc(Node(u8), 26) };

        const words = "one|two|three|four|five|six|seven|eight|nine|";
        var current_num = 1;
        var iter = start_node;
        for (words) |char| {
            std.debug.print("{c}", .{char});
            switch (char) {
                '|' => {
                    iter.*.num = current_num;
                    iter = start_node;
                    current_num += 1;
                },
                else => |x| {
                    iter.*.next = try allocator.alloc(Node(u8), 26);
                    iter.*.next[x] = try allocator.create(Node(u8));
                    iter = &(iter.*.next[x]);
                },
            }
        }

        return .{ .start_node = start_node, .allocator = allocator };
    }

    fn deinit(self: *Self) void {
        if (self.start_node == null) return;

        self.start_node.*.dealloc(self.allocator);
        self.allocator.destroy(self.start_node);
        self.start_node = null;
    }

    // build_tree: {
    // const words = "one|two|three|four|five|six|seven|eight|nine";

    // var result = NumericTree{ .next = [26]NumericTree };
    // var current_num = 1;
    // var iter: *NumericTree = &result;
    // for (words) |char| {
    //     std.debug.print("{c}", .{char});
    //     switch (char) {
    //         '|' => {
    //             iter.* = NumericTree{ .num = current_num };
    //             iter = &result;
    //             current_num += 1;
    //         },
    //         else => |x| {
    //             iter.*.next[x] = NumericTree{ .next = [26]NumericTree };
    //             iter = iter.*.next[x];
    //         },
    //     }
    // }

    // break :build_tree result;
};

pub fn solve(filepath: []const u8, comptime allocator: *const Allocator) !u32 {
    const file = try fs.cwd().openFile(filepath, .{ .mode = .read_only });
    var buffer = try allocator.alloc(u8, 1024);
    defer {
        file.close();
        allocator.free(buffer);
    }

    std.debug.print("{d}", .{tree['o']['n']['e']});

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

test "build tree" {}
