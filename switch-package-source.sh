#!/usr/bin/env bash
#
# switch-package-source.sh
#
# Switch the AlternativeOnboarding example app between the LOCAL working-copy
# WhitelabelPaySDK package (this repo) and the published REMOTE package on
# GitHub. Use LOCAL to test un-published changes (e.g. a new binary/ XCFramework)
# and REMOTE to validate the package exactly as a customer consumes it.
#
# Usage:
#   ./switch-package-source.sh [local|remote|status] [--no-resolve]
#
#   local    Point the example at this repo's working copy (default).
#   remote   Point the example at github.com/paymenttools/wlp-ios-distribution.
#   status   Print the current source and exit (no changes).
#
#   --no-resolve   Skip the `xcodebuild -resolvePackageDependencies` step.
#
# Safety: the project.pbxproj is linted with `plutil` after every edit and the
# pre-edit copy is auto-restored if the lint fails. A timestamped backup is also
# written next to the file. Close Xcode (or let it reload) before running.
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Known-good values (mirrors the UIKit BasicSample's remote reference)
# ---------------------------------------------------------------------------
LOCAL_PATH="../../../wlp-ios-distribution"                       # relative to the .xcodeproj's container dir
REMOTE_URL="https://github.com/paymenttools/wlp-ios-distribution"
REMOTE_BRANCH="main"
REMOTE_LABEL="wlp-ios-distribution"                             # comment label Xcode shows for the remote ref

# ---------------------------------------------------------------------------
# Locate the project relative to this script (works from any CWD)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="$SCRIPT_DIR/Examples/AlternativeOnboarding/AlternativeOnboarding.xcodeproj"
PBX="$PROJ/project.pbxproj"
SCHEME="AlternativeOnboarding"

TAB=$'\t'
RESOLVE=1
MODE="local"

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
for arg in "$@"; do
	case "$arg" in
		local|remote|status) MODE="$arg" ;;
		--no-resolve)        RESOLVE=0 ;;
		-h|--help)
			sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
			exit 0 ;;
		*)
			echo "error: unknown argument '$arg' (expected local|remote|status|--no-resolve)" >&2
			exit 2 ;;
	esac
done

die() { echo "error: $*" >&2; exit 1; }

[ -f "$PBX" ] || die "project.pbxproj not found at $PBX"

# ---------------------------------------------------------------------------
# Detect current source from the pbxproj
# ---------------------------------------------------------------------------
current_source() {
	if grep -q "isa = XCLocalSwiftPackageReference;"  "$PBX"; then echo "local"
	elif grep -q "isa = XCRemoteSwiftPackageReference;" "$PBX"; then echo "remote"
	else echo "none"; fi
}

CURRENT="$(current_source)"

if [ "$MODE" = "status" ]; then
	echo "Current WhitelabelPaySDK source for '$SCHEME': $CURRENT"
	[ "$CURRENT" = "local" ]  && echo "  -> $LOCAL_PATH"
	[ "$CURRENT" = "remote" ] && echo "  -> $REMOTE_URL ($REMOTE_BRANCH)"
	exit 0
fi

if [ "$CURRENT" = "$MODE" ]; then
	echo "Already using the $MODE package — nothing to change."
	exit 0
fi

# Guards: the splice anchors must exist in this project.
grep -q "packageReferences = (" "$PBX" \
	|| die "no 'packageReferences = (' array in the project — open it in Xcode and add the package once, then re-run."
grep -q "End XCSwiftPackageProductDependency section" "$PBX" \
	|| die "no XCSwiftPackageProductDependency section — the example has no package product wired in."

# ---------------------------------------------------------------------------
# Build the new reference (a fresh 24-hex object id + section block + array entry)
# ---------------------------------------------------------------------------
UUID="$(uuidgen | tr -d '-' | tr 'a-f' 'A-F' | cut -c1-24)"

SECTION_FILE="$(mktemp)"
ENTRY_FILE="$(mktemp)"
TMP="$(mktemp)"
trap 'rm -f "$SECTION_FILE" "$ENTRY_FILE" "$TMP"' EXIT

if [ "$MODE" = "local" ]; then
	{
		printf '\n'
		printf '/* Begin XCLocalSwiftPackageReference section */\n'
		printf '%s%s%s /* XCLocalSwiftPackageReference "%s" */ = {\n' "$TAB" "$TAB" "$UUID" "$LOCAL_PATH"
		printf '%s%s%sisa = XCLocalSwiftPackageReference;\n' "$TAB" "$TAB" "$TAB"
		printf '%s%s%srelativePath = "%s";\n' "$TAB" "$TAB" "$TAB" "$LOCAL_PATH"
		printf '%s%s};\n' "$TAB" "$TAB"
		printf '/* End XCLocalSwiftPackageReference section */\n'
	} > "$SECTION_FILE"
	printf '%s%s%s%s%s /* XCLocalSwiftPackageReference "%s" */,\n' \
		"$TAB" "$TAB" "$TAB" "$TAB" "$UUID" "$LOCAL_PATH" > "$ENTRY_FILE"
else
	{
		printf '\n'
		printf '/* Begin XCRemoteSwiftPackageReference section */\n'
		printf '%s%s%s /* XCRemoteSwiftPackageReference "%s" */ = {\n' "$TAB" "$TAB" "$UUID" "$REMOTE_LABEL"
		printf '%s%s%sisa = XCRemoteSwiftPackageReference;\n' "$TAB" "$TAB" "$TAB"
		printf '%s%s%srepositoryURL = "%s";\n' "$TAB" "$TAB" "$TAB" "$REMOTE_URL"
		printf '%s%s%srequirement = {\n' "$TAB" "$TAB" "$TAB"
		printf '%s%s%s%sbranch = %s;\n' "$TAB" "$TAB" "$TAB" "$TAB" "$REMOTE_BRANCH"
		printf '%s%s%s%skind = branch;\n' "$TAB" "$TAB" "$TAB" "$TAB"
		printf '%s%s%s};\n' "$TAB" "$TAB" "$TAB"
		printf '%s%s};\n' "$TAB" "$TAB"
		printf '/* End XCRemoteSwiftPackageReference section */\n'
	} > "$SECTION_FILE"
	printf '%s%s%s%s%s /* XCRemoteSwiftPackageReference "%s" */,\n' \
		"$TAB" "$TAB" "$TAB" "$TAB" "$UUID" "$REMOTE_LABEL" > "$ENTRY_FILE"
fi

# ---------------------------------------------------------------------------
# Transform: strip any existing package-reference wiring, then splice in the new
#   - awk drops the Begin..End ref sections and the array entry lines
#   - sed `r` inserts the fresh array entry after the array opener
#   - sed `r` inserts the fresh section after the product-dependency section
# (The XCSwiftPackageProductDependency entries reference the package by NAME,
#  so they need no changes when the source kind flips.)
# ---------------------------------------------------------------------------
awk '
	/\/\* Begin XC(Local|Remote)SwiftPackageReference section \*\// { inref=1 }
	/\/\* End XC(Local|Remote)SwiftPackageReference section \*\//   { inref=0; next }
	inref==1 { next }
	/XC(Local|Remote)SwiftPackageReference/ && /,[[:space:]]*$/ { next }
	{ print }
' "$PBX" \
	| sed "/packageReferences = (/r $ENTRY_FILE" \
	| sed "/End XCSwiftPackageProductDependency section/r $SECTION_FILE" \
	> "$TMP"

# ---------------------------------------------------------------------------
# Validate, back up, commit the change
# ---------------------------------------------------------------------------
if ! plutil -lint "$TMP" >/dev/null; then
	die "generated project.pbxproj failed plutil lint — original left untouched."
fi

BACKUP="$PBX.bak.$(date +%Y%m%d-%H%M%S)"
cp "$PBX" "$BACKUP"
cp "$TMP" "$PBX"

NEW="$(current_source)"
if [ "$NEW" != "$MODE" ]; then
	cp "$BACKUP" "$PBX"
	die "switch did not take effect (still '$NEW') — restored from backup $BACKUP"
fi

echo "Switched WhitelabelPaySDK source: $CURRENT -> $NEW"
[ "$MODE" = "local" ]  && echo "  -> $LOCAL_PATH"
[ "$MODE" = "remote" ] && echo "  -> $REMOTE_URL ($REMOTE_BRANCH)"
echo "  backup: $BACKUP"

# ---------------------------------------------------------------------------
# Refresh SwiftPM resolution so the switch takes effect for the next build
# ---------------------------------------------------------------------------
if [ "$RESOLVE" -eq 1 ]; then
	echo "Resolving package dependencies..."
	if xcodebuild -resolvePackageDependencies -project "$PROJ" -scheme "$SCHEME" >/dev/null 2>&1; then
		echo "  resolved OK"
	else
		echo "  warning: package resolution reported an issue — open the project in Xcode to inspect." >&2
	fi
fi

echo "Done. Build it with:"
echo "  xcodebuild -project \"$PROJ\" \\"
echo "    -scheme $SCHEME -destination 'platform=iOS Simulator,name=iPhone 15' build"
