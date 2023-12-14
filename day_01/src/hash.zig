const std = @import("std");

// Self implemented Hash Table
pub fn Hash(comptime K: type, comptime V: type) type {
    return struct {
        _hashtable: *V,
        _keys: *K,
        pub fn init(allocator: std.mem.Allocator) !void {
            _ = allocator;
        }
    };
}
