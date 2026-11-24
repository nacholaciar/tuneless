# Homebrew formula for the nacholaciar/homebrew-tap repository.
# After each release, update `url` and `sha256`:
#   curl -sL https://github.com/nacholaciar/tuneless/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
class Tuneless < Formula
  desc "Stop Apple Music from opening when headphones or AirPods connect"
  homepage "https://github.com/nacholaciar/tuneless"
  url "https://github.com/nacholaciar/tuneless/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "08ca0b8b3c3a129bcfbb887e3f6c3920e52e801b0b993d4f8f301004625b6171"
  license "MIT"
  head "https://github.com/nacholaciar/tuneless.git", branch: "main"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/tuneless"
  end

  service do
    run opt_bin/"tuneless"
    keep_alive true
    process_type :interactive
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/tuneless --version").strip
  end
end
