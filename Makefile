.PHONY: build test install uninstall status logs smoke clean

LABEL := io.github.nacholaciar.tuneless

# Release build (.build/release/tuneless)
build:
	swift build -c release

# Unit tests
test:
	swift test

# Build, install to ~/.local/bin and (re)start the LaunchAgent
install:
	./Scripts/install.sh

# Stop the service and remove the binary and the LaunchAgent
uninstall:
	./Scripts/uninstall.sh

# Show whether the service is loaded and its PID
status:
	@launchctl list | grep $(LABEL) || echo "$(LABEL) is not loaded"

# Logs from the last hour
logs:
	/usr/bin/log show --last 1h --predicate 'subsystem == "$(LABEL)"' --style compact

# Open Apple Music and check that the running service quits it
smoke:
	@open -a Music; sleep 2; \
	if pgrep -x Music >/dev/null; then echo "FAIL: Apple Music is still open"; exit 1; \
	else echo "OK: Apple Music was quit"; fi

clean:
	rm -rf .build
