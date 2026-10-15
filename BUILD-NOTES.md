# Verification and delivery status

The uploaded 54,276,357-byte archive and its nested source ZIP passed CRC checks. This source derives from that attachment, preserving the existing Kariz styling, font assets, core management code, licenses and vendored BackPack engine. BackPack wire protocols and its Go traffic engine are unchanged.

Executed in this environment:

- Strict TypeScript checking with cached TypeScript 6.0.3 and React types: passed.
- Complete self-contained production UI bundle with cached esbuild 0.28.2 and React 19.2.8: passed. GitHub release builds use the project's locked npm/Vite dependencies instead.
- Actual native BackPack engine processes from the verified uploaded runtime: Stealth, TCPMux, KCP, QUIC, WSMux, WSSMux and raw UDP. Authenticated test helper measured TCP throughput and 1420-byte UDP packets through these transports. Incorrect token rejection passed. Native helper tests took about 45 seconds on this local host; this is not a WAN benchmark.
- Eight setup/credential tests: permissions and atomic writes; host validation; password via stdin; stale root password-copy rejection; real local-CA certificate chain, DNS/IP SAN and private-key checks; no service start after certificate failure; preserving live-renewal symlink paths.
- Four bootstrap tests: verified ready package with no compilation; bad checksum rejection; stale-source release rejection; unsafe archive path rejection.
- Immediate raw-UDP listener cleanup check and Python/shell syntax checks.

Not executed here:

- Rust compiler/toolchain and external dependency downloads are unavailable in this environment. The changed Rust management panel has NOT been compiled or tested here. The GitHub workflow gates release publication on cargo tests (including actual management-agent and native BackPack integration tests), frontend build, setup/helper tests and fresh static builds on AMD64 and ARM64 native runners.
- No new panel executable is bundled or claimed ready in this source delivery. Old panel binaries must not be used as the updated version. The bootstrap refuses a release whose SOURCE.sha256 does not match the source uploaded to the repository.
- No full systemd VPS deployment, public CA issuance, live provider firewall test, browser-rendering inspection or 1 GiB installation benchmark was performed. Public certificate issuance requires the user's reachable server. Local tests cannot guarantee connectivity through an unknown provider firewall.
- Privileged L3/raw-IP/PCK/ICMP/Spoof modes preserve the native code/configuration surface, but were not run against a public network here.

A successful GitHub Actions run is required before installation. If compilation or integration fails, no new release is published. The source ZIP includes all code, tests, build/package scripts and original upstream notices. No claim of zero bugs or completed CI execution is made.

IP certificate implementation follows the Certbot/Let's Encrypt documentation:
https://letsencrypt.org/2026/03/11/shorter-certs-certbot/
