class BaidupcsRust < Formula
  desc "百度网盘第三方客户端（Rust + Vue3）"
  homepage "https://github.com/komorebiCarry/BaiduPCS-Rust"
  url "https://github.com/komorebiCarry/BaiduPCS-Rust/releases/download/v2.3.2/BaiduPCS-Rust-v2.3.2-macos-arm64.zip"
  sha256 "9673e11525ccb06bd189c0db6cf98a703917edeaa300a19151763cba560bc619"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    libexec.install Dir["*"]

    %w[config data wal logs downloads].each do |d|
      target = var/"baidupcs-rust"/d
      target.mkpath

      # 只在 var 那边还是空的时候,把发行包自带的默认内容(比如默认 app.toml)
      # 种一份过去打底;var 里已经有真实数据时,不会用新版本的默认内容覆盖它
      if (libexec/d).exist? && !(libexec/d).symlink?
        (libexec/d).children.each do |f|
          dest = target/f.basename
          cp_r(f, dest) unless dest.exist?
        end
        rm_r libexec/d
      end

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
    environment_variables HTTP_PROXY: "", HTTPS_PROXY: "", ALL_PROXY: "",
                           http_proxy: "", https_proxy: "", all_proxy: "",
                           NO_PROXY: "*"
  end

  test do
    assert_predicate bin/"baidupcs-rust", :executable?
  end
end
