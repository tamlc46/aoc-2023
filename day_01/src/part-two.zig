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

const ALPHABET_SIZE: u5 = 26;
const NumericTree = struct {
    const Self = @This();

    value: ?u4 = null, // Value range (0..16). We only need (1..9)
    indices: [ALPHABET_SIZE]?*Self = std.mem.zeroes([ALPHABET_SIZE]?*Self),

    pub fn init(allocator: Allocator) !Self {
        const words = "one|two|three|four|five|six|seven|eight|nine|";
        var tree: Self = .{ .value = undefined, .indices = std.mem.zeroes([ALPHABET_SIZE]?*Self) };

        var iter: *NumericTree = &tree;
        var current_num: u4 = 1;
        for (words) |char| switch (char) {
            '|' => {
                iter.*.value = current_num;
                current_num += 1;

                iter = &tree; // Reset iter
            },
            else => {
                const hs = hash(char);
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
        else => unreachable,
    };
}

// Create a union type to hold pointer instead of duplicated value
const TreeOrValue = union(enum) { tree: *NumericTree, value: u4 };

pub fn calcLine(list: *const LinkedList(TreeOrValue)) u7 {
    var lead: u7 = 0; // Value range (0..128). We only need (10..90)
    var tail: u4 = 0; // Value range (0..16). We only need (1..9)

    var count: usize = 0;
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
    std.debug.print("==================== LEAD({d})|TAIL({d})|NUM({d})|COUNT({d}) ====================\n", .{ lead, tail, lead * 10 + tail, count });

    return lead * 10 + tail;
}

pub fn solve(filepath: []const u8, comptime allocator: Allocator) !usize {
    const file = try fs.cwd().openFile(filepath, .{ .mode = .read_only });
    var buffer = try allocator.alloc(u8, 512);
    defer {
        file.close();
        allocator.free(buffer);
    }

    var total: usize = 0;
    var tree = try NumericTree.init(allocator);
    var list = LinkedList(TreeOrValue).init(allocator);
    defer {
        tree.deinit(allocator);
        list.deinit();
    }

    while (file.read(buffer)) |max_length| {
        if (max_length == 0) {
            total += calcLine(&list);
            break;
        }

        for (buffer[0..max_length]) |char| switch (char) {
            'a'...'z', 'A'...'Z' => {
                const hashed = hash(char);
                std.debug.print("Character {c}:\n", .{char});

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
                                // No possible number can be create with this path
                                // so we remove it
                                try list.remove(index);
                            }
                        },
                        .value => index += 1, // This node already infered to numeric value. skip
                    }
                }

                if (tree.indices[hashed]) |indexedTree| {
                    try list.insert(list.size, .{ .tree = indexedTree });
                }
            },
            '0'...'9' => {
                std.debug.print("Character {c}:\n", .{char});
                var index: u8 = 0;
                var iter = list.head;
                while (iter) |treeOrVal| {
                    iter = treeOrVal.next;
                    switch (treeOrVal.value) {
                        .tree => try list.remove(index), // Remove in-complete number
                        .value => index += 1,
                    }
                }
                try list.insert(list.size, .{ .value = @as(u4, @intCast(char - '0')) });
            },
            '\n' => {
                total += calcLine(&list);
                list.clear(); // Clear the list, prepare for next line
            },
            else => unreachable,
        };
    } else |err| return err;

    return total;
}
