#!/bin/sh
set -eu

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)
AIRULES_STATE=$(mktemp -d)
export AIRULES_STATE
# shellcheck source=../lib/common.sh
. "$REPO/lib/common.sh"
state_init

chosen_dir=$(mktemp -d)
chosen_file=$chosen_dir/issue-label
printf 'Example Person\n' | configure_issue_label "$chosen_file" 0 2> "$chosen_dir/prompt"
test "$(cat "$chosen_file")" = 'Example Person'
grep -q 'Name to use as a GitHub issue label' "$chosen_dir/prompt"
grep -q 'issue-label' "$(state_file)"
printf 'Different Person\n' | configure_issue_label "$chosen_file" 0 2> "$chosen_dir/second-prompt"
test "$(cat "$chosen_file")" = 'Example Person'
test ! -s "$chosen_dir/second-prompt"

skipped_dir=$(mktemp -d)
skipped_file=$skipped_dir/issue-label
configure_issue_label "$skipped_file" 1 < /dev/null 2> "$skipped_dir/warning"
test ! -e "$skipped_file"
printf 'Later Person\n' | configure_issue_label "$skipped_file" 0 2> "$skipped_dir/prompt"
test "$(cat "$skipped_file")" = 'Later Person'

blank_dir=$(mktemp -d)
blank_file=$blank_dir/issue-label
printf '\n' | configure_issue_label "$blank_file" 0 2> "$blank_dir/prompt"
test -f "$blank_file"
test "$(cat "$blank_file")" = ''
printf 'Ignored Person\n' | configure_issue_label "$blank_file" 0 2> "$blank_dir/second-prompt"
test "$(cat "$blank_file")" = ''
test ! -s "$blank_dir/second-prompt"

printf 'issue-label tests passed\n'
