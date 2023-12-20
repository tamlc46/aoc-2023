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
            if (self.size == 0) return;

            var iter: ?*Node = self.*.tail;
            std.debug.print("Cleaning up address ", .{});
            while (iter) |node| {
                std.debug.print("|{d}|", .{@intFromPtr(node)});
                iter = node.*.prev;
                node.prev = null;
                node.next = null;
                self.allocator.destroy(node);
                self.size -= 1;
            }
            std.debug.print("\n", .{});
            self.head = null;
            self.tail = null;
            self.cursor = null;
            self.curpos = null;
        }

        pub fn moveCursor(self: *Self, index: usize) error{IndexOutOfRange}!void {
            if (index == self.size) return error.IndexOutOfRange;
            if (self.curpos) |*curpos| {
                while (curpos.* < index) : (curpos.* += 1) self.cursor = self.cursor.?.next;
                while (curpos.* > index) : (curpos.* -= 1) self.cursor = self.cursor.?.prev;
            } else {
                self.moveCursorToHead();
                try self.moveCursor(index);
            }
        }

        pub fn moveCursorToHead(self: *Self) void {
            self.curpos = if (self.size == 0) null else 0;
            self.cursor = self.head;
        }

        pub fn moveCursorToTail(self: *Self) void {
            self.cursor = self.tail;
            self.curpos = self.size - 1;
        }

        pub fn getValue(self: *Self, index: usize) !T {
            return (try self.getCursor(index)).?.*.value;
        }

        pub fn getCursor(self: *Self, index: ?usize) !?*Node {
            if (index) |i| try self.moveCursor(i);
            return self.cursor;
        }

        pub fn insert(self: *Self, index: usize, value: T) !void {
            if (index == 0) { // Push head
                var new_node = try self.allocator.create(Node);
                new_node.* = Node{ .value = value, .prev = null, .next = self.head };

                if (self.head) |cursor| cursor.prev = new_node;
                self.head = new_node;

                self.size += 1;

                // First element in the list
                if (self.size == 1) {
                    self.tail = new_node;
                    self.moveCursorToHead();
                }
            } else if (index == self.*.size) { // Push tail
                var new_node = try self.allocator.create(Node);
                new_node.* = Node{ .value = value, .prev = self.tail, .next = null };

                if (self.tail) |cursor| cursor.next = new_node;

                self.size += 1;

                self.tail = new_node;
                self.moveCursorToTail();
            } else { // Insert middle
                if (try self.getCursor(index)) |cursor| {
                    var new_node = try self.allocator.create(Node);
                    new_node.* = Node{ .value = value, .prev = cursor.*.prev, .next = cursor };

                    if (cursor.*.prev) |prev_cursor| prev_cursor.*.next = new_node;
                    cursor.*.prev = new_node;

                    self.size += 1;

                    self.cursor = new_node;
                }
            }
            std.debug.print("\t - insert at {any} - cursor: {any}({any})\n", .{ index, self.curpos, @intFromPtr(self.cursor) });
        }

        pub fn update(self: *Self, index: usize, value: T) !void {
            if (try self.getCursor(index)) |cursor| {
                std.debug.print("\t - update at {any} - cursor: {any}({any})\n", .{ index, self.curpos, @intFromPtr(self.cursor) });
                cursor.*.value = value;
            } else if (index == 0) {
                try self.insert(index, value);
            } else {
                std.debug.print("Something is wrong!!!\n", .{});
            }
        }

        pub fn remove(self: *Self, index: usize) !void {
            if (try self.getCursor(index)) |cursor| {
                std.debug.print("\t - remove at {any} - cursor: {any}({any})\n", .{ index, self.curpos, @intFromPtr(self.cursor) });
                if (index == 0) { // Remove head node
                    self.head = cursor.*.next;
                    if (cursor.*.next) |next_cursor| next_cursor.*.prev = null;

                    self.size -= 1;

                    self.moveCursorToHead();
                } else if (index == self.size - 1) { // Remove tail node
                    self.tail = cursor.*.prev;
                    if (cursor.*.prev) |prev_cursor| prev_cursor.*.next = null;

                    self.size -= 1;

                    self.moveCursorToTail();
                } else {
                    // Remove node in the middle
                    if (cursor.*.prev) |prev_cursor| prev_cursor.*.next = cursor.*.next;
                    if (cursor.*.next) |next_cursor| next_cursor.*.prev = cursor.*.prev;
                    self.size -= 1;

                    self.cursor = cursor.*.next;
                }
                self.allocator.destroy(cursor);

                // Special case when delete the last element in the list
                if (self.size == 0) self.deinit();
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
