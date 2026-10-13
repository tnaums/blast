const std = @import("std");
const Io = std.Io;

const blast = @import("blast");

const KpFolder = struct {
    name: []const u8,
    seqFile: ?[]const u8 = null,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
//    const allocator = init.gpa;

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 2) {
        std.debug.print("Usage: {s} <directory>\n", .{args[0]});
        return;
    }

    const directory = args[1];
    const cwd = std.Io.Dir.cwd();
    const dir = cwd.openDir(io, directory, .{ .iterate = true }) catch |err| {
        return err;
    };
    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        switch (entry.kind) {
            .file => {
                const start = std.mem.startsWith(u8, entry.name, "pTAN");
                const end = std.mem.endsWith(u8, entry.name, ".fa");
                const length = (entry.name.len == 10);
                if (start and end and length) {
                    std.debug.print("{s}\n{s}\n", .{entry.name, @tagName(entry.kind)});
                    }
            },
            .directory => {
                const start = std.mem.startsWith(u8, entry.name, "pTAN");
                if (start) {
                    const answer = try hasExpectedFile(io, directory, entry.name);
                    if (!answer){
                        std.debug.print("Directory: {s}\n", .{entry.name});
                        std.debug.print("Does not have expected file.\n", .{});
                    }
                }
            },
            else => { continue; },
        }
    }
}

fn hasExpectedFile(io: Io, directory: []const u8, folder: []const u8) !bool {
    var buff: [1024]u8 = undefined;
    const path = try std.fmt.bufPrint(&buff, "{s}/{s}", .{directory,folder});
    const subdir = std.Io.Dir.cwd().openDir(io, path, .{ .iterate = true }) catch |err| {
        return err;
    };
    var it = subdir.iterate();
    while (try it.next(io)) |entry| {
        switch (entry.kind) {
            .file => {
                const start = std.mem.startsWith(u8, entry.name, "pTAN");
                const end = std.mem.endsWith(u8, entry.name, ".fa");
                const length = (entry.name.len == 10);
                if (start and end and length) {
                    return true;
                    }
            },
            else => { continue; },
        }
    }    
    return false;
}
