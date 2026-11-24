/// Pure logic shared by the `tuneless` executable and its tests.
public enum Tuneless {
    public static let version = "0.1.0" // x-release-please-version

    /// launchd label and unified-logging subsystem.
    public static let identifier = "io.github.nacholaciar.tuneless"

    /// Apple Music on current macOS, and iTunes on older systems.
    public static let blockedBundleIDs: Set<String> = ["com.apple.Music", "com.apple.iTunes"]

    public static func shouldBlock(bundleID: String?) -> Bool {
        guard let bundleID else { return false }
        return blockedBundleIDs.contains(bundleID)
    }

    public enum Command: Equatable, Sendable {
        case run
        case help
        case version
        case invalid(String)
    }

    /// Parses the arguments after the executable name.
    public static func parse(_ arguments: [String]) -> Command {
        guard let first = arguments.first else { return .run }
        guard arguments.count == 1 else { return .invalid(arguments.joined(separator: " ")) }
        switch first {
        case "-h", "--help", "help": return .help
        case "-v", "--version", "version": return .version
        default: return .invalid(first)
        }
    }

    public static let usage = """
        tuneless \(version)
        Stops Apple Music from opening on its own (Bluetooth headphones, AirPods, the Play key).

        USAGE
          tuneless              Watch for Apple Music launches and quit them (run by launchd)
          tuneless --version    Print the version
          tuneless --help       Print this help

        Install as a login service with `make install` or `brew services start tuneless`.
        Logs: /usr/bin/log stream --predicate 'subsystem == "\(identifier)"'
        """
}
