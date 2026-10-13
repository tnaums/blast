const std = @import("std");
const Io = std.Io;

const blast = @import("blast");

const KpFolder = struct {
    name: []const u8,
    seqFile: ?[]const u8 = null,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 3) {
        std.debug.print("Usage: {s} <database> <sequence.fa>\n", .{args[0]});
        return;
    }

    const argv1 = [_][]const u8{ "blastp", "-query", args[2], "-db", args[1], "-outfmt", "5", "-out", "-"};

    const proc1 = try std.process.run(
        allocator,
        io,
        .{ .argv = &argv1 },
    );
    defer allocator.free(proc1.stdout);
    defer allocator.free(proc1.stderr);
    switch (proc1.term) {
        .exited => |eCode| {
            if (eCode != 0) {
                std.debug.print(
                    "P1 did not exit cleanly with code {}\n",
                    .{eCode},
                );
            } else {
//                std.debug.print("{s}\n", .{proc1.stdout});
                var hits = std.mem.tokenizeSequence(u8, proc1.stdout, "<Hit>");
                _ = hits.next(); // discard header info
                const hit = hits.next(); // look at the top hit
                if (hit) |value| {
                    std.debug.print("{s}", .{value});
                    std.debug.print("----------------------------------------\n", .{});
                } else {
                    std.debug.print("No hits found.\n", .{});
                }

                }

        },
        .signal => {
            std.debug.print("P1 was killed by a signal.\n", .{});
        },
        .stopped => {
            std.debug.print("P1 was stopped.\n", .{});
        },
        .unknown => {
            std.debug.print("P1 terminated: unknown status.\n", .{});
        },
        
    }
}
