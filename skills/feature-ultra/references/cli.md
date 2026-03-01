# CLI Tool Domain Checks

Additional analysis for features in command-line tools, developer tools, and terminal applications.

## Table of Contents
- [Input and Environment](#input-and-environment)
- [File System Hazards](#file-system-hazards)
- [Process and Signal Handling](#process-and-signal-handling)
- [Output and Feedback](#output-and-feedback)
- [CLI Anti-Patterns](#cli-anti-patterns)

---

## Input and Environment

### Argument Parsing
- Are conflicting flags detected and reported? (e.g., `--verbose` and `--quiet` together)
- What happens with unexpected arguments? Silent ignore (dangerous) or error?
- Are there default values that could surprise the user in production? (e.g., dry-run defaults to false)
- Quoted strings, glob expansion, spaces in paths — are they handled correctly?

### Environment Dependencies
- What environment variables does the feature read? What happens if they're unset?
- If the tool reads config files, what's the precedence? (CLI flags > env vars > config file > defaults)
- Does it work in non-interactive environments (CI/CD, cron, Docker)? No TTY, no stdin, no color support.
- Path assumptions: does it assume a specific working directory, HOME directory, or temp directory?

### Permissions and Context
- Does the feature require elevated permissions (root, sudo)? What's the error message if they're missing?
- Does it work inside containers, sandboxes, or restricted environments?
- Cross-platform: if supporting multiple OS, are path separators, line endings, and file permissions handled?

---

## File System Hazards

### Destructive Operations
- If the feature writes or deletes files, is there a dry-run mode?
- If overwriting existing files, is there a prompt or `--force` flag requirement?
- Are file operations atomic? If the process dies mid-write, is the file left in a corrupt state? (Write to temp file, then rename)
- Symlink handling: does it follow symlinks? Could following symlinks escape the intended directory?

### Concurrency
- If multiple instances of the tool run simultaneously, do they conflict? (Lock files, temp files, output files)
- If the tool reads and then writes a file, can another process modify the file in between (TOCTOU)?
- If using a lock file, what happens if the process crashes without cleaning it up? Is there stale lock detection?

### Resource Limits
- How does the feature handle very large files? Is it streamed or loaded entirely into memory?
- Does it create temporary files? Are they cleaned up on all exit paths (success, error, interrupt)?
- Maximum path length: do generated paths risk exceeding OS limits?

---

## Process and Signal Handling

### Interruption (Ctrl+C / SIGINT)
- If the user interrupts mid-operation, what state is left behind?
- Are temporary files cleaned up? Are lock files released? Are partial outputs removed?
- If the operation is multi-step, is there a checkpoint/resume mechanism for long-running operations?

### Child Processes
- If spawning child processes, are they cleaned up on parent exit? (Zombie processes)
- Is stdout/stderr from child processes captured or inherited? Can errors be diagnosed?
- Timeout: if a child process hangs, is there a timeout? What happens to the parent?

### Exit Codes
- Does the tool use meaningful exit codes? (0 = success, 1 = general error, 2 = usage error)
- If used in shell pipelines (`tool1 | tool2`), does it behave correctly with broken pipes?
- In `set -e` scripts, will unexpected non-zero exits cause premature termination?

---

## Output and Feedback

### Progress and Verbosity
- For long-running operations, is there a progress indicator?
- Does the progress indicator work in non-TTY environments? (Don't emit progress bars to log files)
- Is there a `--quiet` mode for scripting? Does it suppress all non-essential output?
- Is stderr used for diagnostics and stdout for data? (Important for piping)

### Machine-Readable Output
- If the output is meant to be parsed by other tools, is there a structured format option (`--json`, `--csv`)?
- Is the human-readable output stable enough to grep, or does formatting change between versions?
- Are error messages written to stderr so they don't corrupt piped stdout?

### Color and Formatting
- Is color output disabled when stdout is not a TTY? (Check `NO_COLOR` env var and `isatty()`)
- Are wide outputs handled when terminal is narrow? Truncation, wrapping, or horizontal scroll?

---

## CLI Anti-Patterns

| Anti-Pattern | Description |
|-------------|-------------|
| **Silent Destructive Default** | Default behavior deletes or overwrites without confirmation. User expected dry-run. |
| **Orphaned Lock** | Process crashes, lock file remains, subsequent runs refuse to start. No stale detection. |
| **Partial Write** | Process interrupted mid-write. File is corrupt. No atomic write pattern used. |
| **Environment Surprise** | Reads an environment variable with no documentation. Different behavior in CI vs local. |
| **Noisy Pipe** | Progress bars and color codes written to stdout, corrupting piped output. |
| **Zombie Spawner** | Child processes not cleaned up on parent exit. Orphaned processes consume resources. |
| **Glob Explosion** | User passes `*` which expands to thousands of arguments. Tool can't handle it. |
| **Hidden Network Call** | Tool makes network request with no indication. Fails mysteriously in air-gapped environments. |
