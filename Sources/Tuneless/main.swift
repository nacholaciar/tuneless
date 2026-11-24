// tuneless: quits Apple Music the moment it tries to launch
// (for example when Bluetooth headphones connect or Play is pressed with nothing else playing).
// Started at login by a LaunchAgent; see Scripts/install.sh or the Homebrew service.

import AppKit
import TunelessCore
import os

switch Tuneless.parse(Array(CommandLine.arguments.dropFirst())) {
case .run:
    break
case .help:
    print(Tuneless.usage)
    exit(0)
case .version:
    print(Tuneless.version)
    exit(0)
case .invalid(let argument):
    FileHandle.standardError.write(Data("tuneless: unknown argument '\(argument)'\n\n\(Tuneless.usage)\n".utf8))
    exit(64) // EX_USAGE
}

let logger = Logger(subsystem: Tuneless.identifier, category: "watcher")

@MainActor
func blockIfNeeded(_ app: NSRunningApplication) {
    guard Tuneless.shouldBlock(bundleID: app.bundleIdentifier), let id = app.bundleIdentifier else { return }
    let pid = app.processIdentifier
    if app.forceTerminate() {
        logger.notice("Quit \(id, privacy: .public) (pid \(pid))")
    } else if pid > 0, Darwin.kill(pid, SIGKILL) == 0 {
        logger.notice("Killed \(id, privacy: .public) with SIGKILL (pid \(pid))")
    } else {
        logger.error("Could not quit \(id, privacy: .public) (pid \(pid))")
    }
}

let center = NSWorkspace.shared.notificationCenter
// willLaunch reacts before Apple Music finishes opening.
// didLaunch is a fallback in case willLaunch is not delivered.
let observers = [
    NSWorkspace.willLaunchApplicationNotification,
    NSWorkspace.didLaunchApplicationNotification,
].map { name in
    center.addObserver(forName: name, object: nil, queue: .main) { note in
        guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
        // queue: .main guarantees the main thread.
        MainActor.assumeIsolated { blockIfNeeded(app) }
    }
}

// Quit Apple Music if it was already open when tuneless started.
for app in NSWorkspace.shared.runningApplications { blockIfNeeded(app) }

logger.notice("tuneless \(Tuneless.version, privacy: .public) watching")
withExtendedLifetime(observers) { RunLoop.main.run() }
