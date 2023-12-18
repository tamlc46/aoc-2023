const std = @import("std");
const fs = std.fs;

const Allocator = std.mem.Allocator;
const LinkedList = @import("linkedlist.zig").LinkedList;

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

const ALPHABET_SIZE: u8 = 26;
const NumericTree = struct {
    const Self = @This();

    value: ?u8 = null,
    indices: [ALPHABET_SIZE]?*Self = std.mem.zeroes([ALPHABET_SIZE]?*Self),

    pub fn init(allocator: Allocator) !Self {
        const words = "one|two|three|four|five|six|seven|eight|nine|";
        var tree: Self = .{ .value = undefined, .indices = std.mem.zeroes([ALPHABET_SIZE]?*Self) };

        var iter: *NumericTree = &tree;
        var current_num: u8 = 1;
        for (words) |char| switch (char) {
            '|' => {
                iter.*.value = current_num;
                current_num += 1;

                iter = &tree; // Reset iter
            },
            else => {
                const hs = hash(char);
                // std.debug.print("{d} | {c}\n", .{ @intFromPtr(iter), char });
                if (iter.indices[hs] == null) {
                    var ptr = try allocator.create(NumericTree);
                    ptr.* = NumericTree{};
                    iter.*.indices[hs] = ptr;
                }
                iter = iter.indices[hs].?;
            },
        };

        return tree;
    }

    fn deinit(self: *Self, allocator: Allocator) void {
        for (self.indices, 0..) |sub_tree, index| {
            if (sub_tree) |*tree| {
                std.debug.print("{c}", .{@as(u8, @intCast(index)) + 'a'});
                tree.*.*.deinit(allocator); // *.*
                allocator.destroy(tree.*);
            }
            self.indices[index] = null;
        }
    }
};

pub fn hash(char: u8) u8 {
    return switch (char) {
        'A'...'Z' => char - 'A',
        'a'...'z' => char - 'a',
        '1'...'9' => char - '0' + 'a',
        else => unreachable,
    };
}

// Create a union type to hold pointer instead of duplicated value
const TreeOrValue = union(enum) { tree: *NumericTree, value: u8 };

pub fn solve(filepath: []const u8, comptime allocator: Allocator) !u32 {
    const file = try fs.cwd().openFile(filepath, .{ .mode = .read_only });
    var buffer = try allocator.alloc(u8, 512);
    defer {
        file.close();
        allocator.free(buffer);
    }

    var tree = try NumericTree.init(allocator);
    var list = LinkedList(TreeOrValue).init(allocator);
    defer {
        tree.deinit(allocator);
        list.deinit();
    }

    var total: u32 = 0;
    var lead: u8 = 0;
    var tail: u8 = 0;
    while (file.read(buffer)) |max_length| {
        if (max_length == 0) {
            total += lead * 10 + tail;
            break;
        }

        for (buffer[0..max_length]) |char| switch (char) {
            'a'...'z', 'A'...'Z' => {
                const hashed = hash(char);
                std.debug.print("{c} - ", .{char});

                var index: u8 = 0;
                var iter = list.head;
                while (iter) |treeOrVal| {
                    iter = treeOrVal.next;
                    switch (treeOrVal.value) {
                        .tree => |node| {
                            if (node.indices[hashed]) |subTree| {
                                if (subTree.value) |value| {
                                    try list.update(index, .{ .value = value });
                                } else {
                                    try list.update(index, .{ .tree = subTree });
                                }
                                index += 1;
                            } else {
                                try list.remove(index);
                                if (index == list.size) index -= 1;
                            }
                        },
                        .value => |value| {
                            _ = value;
                            index += 1;
                        },
                    }
                }

                if (tree.indices[hashed]) |indexedTree| {
                    try list.insert(list.size, .{ .tree = indexedTree });
                }
            },
            '0'...'9' => {
                try list.insert(list.size, .{ .value = char - '0' });
            },
            '\n' => {
                var count: u8 = 0;
                var iter = list.head;
                while (iter) |node| {
                    iter = node.next;
                    switch (node.value) {
                        .value => |value| {
                            lead = if (lead == 0) value else lead;
                            tail = value;
                        },
                        .tree => {},
                    }
                    count += 1;
                }
                std.debug.print("LEAD({d})|TAIL({d})|NUM({d})|COUNT({d})\n", .{ lead, tail, lead * 10 + tail, count });
                total += (lead * 10) + tail;
                lead = 0;
                tail = 0;
                list.clear();
            },
            else => unreachable,
        };
    } else |err| return err;

    return total;
}
