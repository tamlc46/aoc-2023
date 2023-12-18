const std = @import("std");
const Allocator = std.mem.Allocator;

fn ListNode(comptime T: type) type {
    return struct {
        const Self = @This();

        value: T,
        next: ?*Self,
        prev: ?*Self,

        fn swap(self: *Self, other: *Self) void {
            const tmp = self.value;
            self.*.value = other.*.value;
            other.*.value = tmp;
        }
    };
}

// Self implemented Hash Table
pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const Node = ListNode(T);

        allocator: Allocator,

        head: ?*Node,
        tail: ?*Node,

        cursor: ?*Node,
        curpos: ?usize,

        size: usize,

        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .head = null,
                .tail = null,
                .cursor = null,
                .curpos = null,
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            // std.debug.print("Size: {d}\n", .{self.size});
            if (self.size == 0) return;

            var iter: ?*Node = self.head;
            while (iter) |node| {
                iter = node.*.next;
                self.allocator.destroy(node);
                self.size -= 1;
            }
            self.head = null;
            self.tail = null;
            self.cursor = null;
            self.curpos = null;
        }

        pub fn moveCursor(self: *Self, index: usize) error{IndexOutOfRange}!void {
            if (index > 0 and index >= self.size) return error.IndexOutOfRange;
            if (self.curpos) |*curpos| {
                while (curpos.* < index) {
                    curpos.* += 1;
                    self.cursor = self.cursor.?.next;
                }
                while (curpos.* > index) {
                    curpos.* -= 1;
                    self.cursor = self.cursor.?.prev;
                }
            } else {
                self.curpos = 0;
                self.cursor = self.head;

                while (self.curpos.? < index) {
                    self.curpos = self.curpos.? + 1;
                    self.cursor = self.cursor.?.next;
                }
            }
        }

        pub fn moveCursorToHead(self: *Self) void {
            self.cursor = self.head;
            self.curpos = 0;
        }

        pub fn moveCursorToTail(self: *Self) void {
            self.cursor = self.tail;
            self.curpos = self.size - 1;
        }

        pub fn get(self: *Self, index: usize) error{IndexOutOfRange}!T {
            try self.moveCursor(index);
            return self.cursor.?.value;
        }

        pub fn getCursor(self: *Self) ?*Node {
            return self.cursor orelse self.head;
        }

        pub fn insert(self: *Self, index: usize, value: T) !void {
            // std.debug.print("Insert(index={d}, value={d})\n", .{ index, @as(u8, value) });
            if (index == 0) { // Push head
                var new_node = try self.allocator.create(Node);
                new_node.* = Node{ .value = value, .prev = null, .next = self.head };
                if (self.head) |cursor| cursor.prev = new_node;
                if (self.tail == null) self.tail = new_node; // First element in the list
                self.head = new_node;
            } else if (index == self.*.size) { // Push tail
                var new_node = try self.allocator.create(Node);
                new_node.* = Node{ .value = value, .prev = self.tail, .next = null };
                if (self.tail) |cursor| cursor.next = new_node;
                self.tail = new_node;
            } else { // Insert middle
                try self.moveCursor(index);
                if (self.cursor) |cursor| {
                    var new_node = try self.allocator.create(Node);
                    new_node.* = Node{
                        .value = value,
                        .prev = cursor.*.prev,
                        .next = cursor,
                    };

                    if (cursor.*.prev) |prevCursor| {
                        prevCursor.*.next = new_node;
                    }
                    cursor.*.prev = new_node;

                    self.cursor = new_node;
                }
            }
            self.size += 1;
        }

        pub fn update(self: *Self, index: usize, value: T) !void {
            try self.moveCursor(index);
            std.debug.print("update at {any} - {any}\n", .{ self.curpos, @intFromPtr(self.cursor) });
            if (self.getCursor()) |cursor| {
                cursor.*.value = value;
            } else if (index == 0) {
                try self.insert(index, value);
            }
        }

        pub fn remove(self: *Self, index: usize) !void {
            try self.moveCursor(index);
            if (self.getCursor()) |cursor| {
                if (cursor.*.prev) |prevCursor| {
                    prevCursor.*.next = cursor.*.next;
                    self.cursor = prevCursor;
                    self.curpos = self.curpos.? - 1;
                } else {
                    self.head = cursor.*.next;
                }
                if (cursor.*.next) |nextCursor| {
                    nextCursor.*.prev = cursor.*.prev;
                    self.cursor = nextCursor;
                } else {
                    self.tail = cursor.*.prev;
                }
                self.allocator.destroy(cursor);
                self.size -= 1;
            }
        }

        pub fn clear(self: *Self) void {
            self.deinit();
        }
    };
}

test "LinkedList" {
    std.debug.print("LinkedList", .{});
}
