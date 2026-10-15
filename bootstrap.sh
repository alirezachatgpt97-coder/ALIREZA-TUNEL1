#!/usr/bin/env bash
set -euo pipefail
mode=${1:-panel}
case "$mode" in panel|agent) ;; *) echo 'Usage: bash bootstrap.sh panel|agent' >&2;exit 2;;esac
[[ $EUID == 0 ]] || { echo 'Run as root.' >&2;exit 1; }
[[ $(uname -s) == Linux ]] || { echo 'Linux/systemd required.' >&2;exit 1; }
command -v systemctl >/dev/null || { echo 'systemd required.' >&2;exit 1; }
case $(uname -m) in x86_64) arch=amd64;;aarch64|arm64) arch=arm64;;*) echo 'Unsupported CPU.' >&2;exit 1;;esac
repo=alirezachatgpt97-coder/ALIREZA-TUNEL1
base=https://github.com/$repo/releases/latest/download
raw=https://raw.githubusercontent.com/$repo/main
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
missing=()
for c in curl python3 openssl;do command -v "$c" >/dev/null || missing+=("$c");done
command -v ip >/dev/null || missing+=(iproute2)
command -v iptables >/dev/null || missing+=(iptables)
command -v ping >/dev/null || missing+=(iputils-ping)
command -v modprobe >/dev/null || missing+=(kmod)
command -v sysctl >/dev/null || missing+=(procps)
if (( ${#missing[@]} ));then
 command -v apt-get >/dev/null || { echo 'Debian 12/13 or Ubuntu 22.04/24.04 with apt is required.' >&2;exit 1; }
 apt-get update
 DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates "${missing[@]}"
fi
fetch(){ curl -fL --retry 3 --connect-timeout 20 --max-time 300 "$1" -o "$2"; }
fetch "$raw/SOURCE.sha256" "$work/expected-source"
if ! fetch "$base/SOURCE.sha256" "$work/release-source";then
 echo 'New release is not ready. Wait for GitHub Actions: Build ALIREZATUNEL to succeed, then retry.' >&2;exit 1
fi
cmp -s "$work/expected-source" "$work/release-source" || { echo 'Latest release does not match this source. Wait for Build ALIREZATUNEL in Actions; refusing an older panel.' >&2;exit 1; }
asset=ALIREZATUNEL-linux-$arch.tar.gz
echo "Downloading fresh prebuilt ALIREZATUNEL ($arch); no compilation on this server."
fetch "$base/SHA256SUMS" "$work/SHA256SUMS"
fetch "$base/$asset" "$work/$asset"
python3 - "$work" "$asset" <<'PY'
import hashlib,pathlib,sys,tarfile,shutil,os
root=pathlib.Path(sys.argv[1]);name=sys.argv[2]
entries=[x.split() for x in (root/'SHA256SUMS').read_text().splitlines()]
wanted=[x[0] for x in entries if len(x)==2 and x[1].lstrip('*')==name]
if len(wanted)!=1 or hashlib.sha256((root/name).read_bytes()).hexdigest()!=wanted[0]:raise SystemExit('Checksum failed.')
out=root/'runtime';out.mkdir()
with tarfile.open(root/name) as t:
 for m in t.getmembers():
  p=pathlib.PurePosixPath(m.name)
  if p.is_absolute() or '..' in p.parts or not(m.isfile() or m.isdir()):raise SystemExit('Unsafe archive entry.')
  dest=out.joinpath(*p.parts)
  if m.isdir():dest.mkdir(parents=True,exist_ok=True);continue
  dest.parent.mkdir(parents=True,exist_ok=True)
  with t.extractfile(m) as a,dest.open('wb') as b:shutil.copyfileobj(a,b,1024*1024)
  dest.chmod(m.mode&0o777)
PY
bash "$work/runtime/install.sh" "$mode" --no-build
