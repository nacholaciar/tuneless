import Testing
@testable import TunelessCore

@Suite struct ShouldBlock {
    @Test(arguments: ["com.apple.Music", "com.apple.iTunes"])
    func blocksAppleMusic(bundleID: String) {
        #expect(Tuneless.shouldBlock(bundleID: bundleID))
    }

    @Test(arguments: ["com.apple.Safari", "com.brave.Browser", "com.apple.TV", "com.apple.music", "", "com.apple.Music.helper"])
    func allowsEverythingElse(bundleID: String) {
        #expect(!Tuneless.shouldBlock(bundleID: bundleID))
    }

    @Test func allowsAppsWithoutBundleID() {
        #expect(!Tuneless.shouldBlock(bundleID: nil))
    }
}

@Suite struct Parse {
    @Test func noArgumentsRunsTheWatcher() {
        #expect(Tuneless.parse([]) == .run)
    }

    @Test(arguments: ["-h", "--help", "help"])
    func help(flag: String) {
        #expect(Tuneless.parse([flag]) == .help)
    }

    @Test(arguments: ["-v", "--version", "version"])
    func version(flag: String) {
        #expect(Tuneless.parse([flag]) == .version)
    }

    @Test func rejectsUnknownArguments() {
        #expect(Tuneless.parse(["--nope"]) == .invalid("--nope"))
        #expect(Tuneless.parse(["--help", "extra"]) == .invalid("--help extra"))
    }
}
