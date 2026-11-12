#!/bin/sh
set -eux

ARCH="$(uname -m)"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
VERSION="${VERSION:-$(sed -n 's/^version = "\([^"]*\)"/\1/p' Cargo.toml | head -1)}"

export VERSION
printf '%s\n' "$VERSION" > "$HOME/version"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTPATH="$PWD/dist"
export OUTNAME=tokenfold-"$VERSION"-anylinux-"$ARCH".AppImage
export ICON="$PWD/dist/tokenfold-icon.png"
export DESKTOP="$PWD/appimage/tokenfold.desktop"

pacman -Syu --noconfirm --needed rustup git wget imagemagick
rustup toolchain install 1.98 --profile minimal

cargo build --release --locked -p tokenfold-cli
install -Dm755 target/release/tokenfold /usr/bin/tokenfold

magick docs/assets/tokenfold-logo.png -background none -gravity center -resize 256x256 -extent 256x256 "$ICON"

wget "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun

./quick-sharun /usr/bin/tokenfold
./quick-sharun --make-appimage
./quick-sharun --simple-test ./dist/*.AppImage

rm -f "$ICON"
