class BaidupcsRust < Formula
  desc "百度网盘第三方客户端（Rust + Vue3）"
  homepage "https://github.com/komorebiCarry/BaiduPCS-Rust"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  if Hardware::CPU.arm?
    url "https://github.com/komorebiCarry/BaiduPCS-Rust/releases/download/v2.2.3/BaiduPCS-Rust-v2.2.3-macos-arm64.zip"
    sha256 "478e1916147f8609cc5341f4e8e0de24324cee2150404f21deeef9a961225b7f"
  else
    url "https://github.com/komorebiCarry/BaiduPCS-Rust/releases/download/v2.2.3/BaiduPCS-Rust-v2.2.3-macos-x86_64.zip "
    sha256 "f74f8e4f7bbf4552073e172a05e5ce4c8cc4c3509f69fa95ce8bee40b3c3292a"
  end

  def install
    libexec.install Dir["*"]

    %w[data wal logs downloads].each do |d|
      target = var/"baidupcs-rust"/d
      target.mkpath
      rm_r libexec/d if (libexec/d).exist?
      ln_sf target, libexec/d
    end

    (bin/"baidupcs-rust").write <<~EOS
      #!/bin/bash
      cd "#{libexec}" || exit 1
      exec "#{libexec}/baidu-netdisk-rust" "$@"
    EOS
    chmod 0755, bin/"baidupcs-rust"
  end

  service do
    run [opt_bin/"baidupcs-rust"]
    working_dir opt_libexec
    keep_alive true
    log_path var/"log/baidupcs-rust.log"
    error_log_path var/"log/baidupcs-rust.log"
  end

  test do
    assert_predicate bin/"baidupcs-rust", :executable?
  end
end
