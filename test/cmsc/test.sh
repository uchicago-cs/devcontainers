#!/usr/bin/env bash

# Checks for the cmsc dev container. Run inside the container, from the
# workspace folder (test/run.sh takes care of this).

# shellcheck source=test/lib.sh
source "$(dirname "$0")/lib.sh"

### User and setup script

check "runs as ubuntu" test "$(id -un)" = ubuntu
check "\$HOME/.local/share exists" test -d "$HOME/.local/share"
# shellcheck disable=SC2016  # $PWD should expand in the inner shell
check "workspace is in git safe.directory" \
    bash -c 'git config --global --get-all safe.directory | grep -qxF "$PWD"'

### Installed tools

for cmd in gcc g++ clang make cmake cppcheck valgrind gdb lldb \
           python python3 pip pip3 git vim emacs tmux figlet convert dot tldr; do
    check "$cmd is installed" command -v "$cmd"
done

### C/C++

cat > "$TMP/hello.c" <<'EOF'
#include <stdio.h>
int main(void) { printf("hello\n"); return 0; }
EOF

cat > "$TMP/hello.cpp" <<'EOF'
#include <iostream>
int main() { std::cout << "hello" << std::endl; return 0; }
EOF

cat > "$TMP/criterion.c" <<'EOF'
#include <criterion/criterion.h>
Test(sample, passes) { cr_assert(1 + 1 == 2); }
EOF

check "gcc compiles and runs a C program" \
    bash -c "gcc -g -o '$TMP/hello' '$TMP/hello.c' && '$TMP/hello'"
check "clang compiles and runs a C program" \
    bash -c "clang -o '$TMP/hello-clang' '$TMP/hello.c' && '$TMP/hello-clang'"
check "g++ compiles and runs a C++ program" \
    bash -c "g++ -o '$TMP/hello-cpp' '$TMP/hello.cpp' && '$TMP/hello-cpp'"
check "Criterion tests compile, link, and run" \
    bash -c "gcc -o '$TMP/criterion' '$TMP/criterion.c' -lcriterion && '$TMP/criterion'"
# Ubuntu's Criterion 2.4.1 breaks chiTCP's tests, so we build 2.4.3 ourselves
# shellcheck disable=SC2016  # $(...) should expand in the inner shell
check "Criterion is version 2.4.3" \
    bash -c 'test "$(pkg-config --modversion criterion)" = 2.4.3'
check "Ubuntu's Criterion package is not installed" \
    bash -c '! dpkg -s libcriterion-dev >/dev/null 2>&1'
check "protobuf-c compiler and library are installed" \
    bash -c 'command -v protoc-c && test -f /usr/include/protobuf-c/protobuf-c.h'
check "valgrind runs a program" \
    valgrind --error-exitcode=1 -q "$TMP/hello"

# gdb needs ptrace (SYS_PTRACE) and the personality syscall to disable ASLR
# (seccomp=unconfined). Without the latter, gdb still runs the program but
# prints a warning, so check for that as well.
gdb_runs_program() {
    local output
    output=$(gdb -batch -ex run "$TMP/hello" 2>&1)
    echo "$output"
    grep -q "exited normally" <<< "$output" \
        && ! grep -q "Error disabling address space randomization" <<< "$output"
}
check "gdb can run a program" gdb_runs_program

### Python

check "python is Python 3" bash -c 'python --version 2>&1 | grep -q "^Python 3"'
check "python -m venv creates a working virtual environment" \
    bash -c "python -m venv '$TMP/venv' && '$TMP/venv/bin/pip' --version"

# devcontainer.json allows comments, so drop comment lines before parsing
interpreter_path_exists() {
    local path
    path=$(grep -v '^[[:space:]]*//' .devcontainer/devcontainer.json \
        | python3 -c 'import json, sys
print(json.load(sys.stdin)["customizations"]["vscode"]["settings"]["python.defaultInterpreterPath"])') \
        || return 1
    echo "python.defaultInterpreterPath is $path"
    test -x "$path"
}
check "VS Code's python.defaultInterpreterPath exists" interpreter_path_exists
check "Python packages for chirc tests are installed" \
    python -c 'import pytest, pytest_jsonreport, click'

### Git

# On some hosts (e.g., Windows), the workspace appears as owned by root, and
# git refuses to work in it unless it is in safe.directory (see issue #3).
# Simulate that with a root-owned repository.
root_owned_repo_works_after_setup() {
    local repo="$TMP/root-owned-repo"
    sudo mkdir "$repo" && sudo git -C "$repo" init -q || return 1
    if git -C "$repo" status >/dev/null 2>&1; then
        echo "expected git to reject a root-owned repository before setup"
        return 1
    fi
    /usr/local/bin/setup-extra.sh "$repo" && git -C "$repo" status
}
check "git works in a root-owned repository after setup-extra.sh" \
    root_owned_repo_works_after_setup

finish
