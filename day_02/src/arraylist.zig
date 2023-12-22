const std = @import("std");

const Allocator = std.mem.Allocator;

fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []T,
        size: usize,

        allocator: Allocator,
        allocated_size: usize,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .items = &[_]T{},
                .size = 0,
                .allocator = allocator,
                .allocated_size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            _ = self;
        }

        // Push item to the back of the list
        pub fn push(self: *Self, item: T) !void {
            _ = self;
            _ = item;
        }

        // Push many items to the back of the list
        pub fn pushMany(self: *Self, items: []T) !void {
            _ = items;
            _ = self;
        }

        // Remove & return the last element in the list
        pub fn pop(self: *Self, holder: ?*T) T {
            _ = self;
            _ = holder;
        }

        pub fn insert(self: *Self, index: usize, item: T) !void {
            _ = item;
            _ = index;
            _ = self;
        }

        pub fn insertMany(self: *Self, index: usize, items: []T) !void {
            _ = items;
            _ = index;
            _ = self;
        }
    };
}
