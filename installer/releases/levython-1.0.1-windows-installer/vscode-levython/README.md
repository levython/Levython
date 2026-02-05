# Levython Language Extension for VS Code

Provides syntax highlighting, code snippets, and language support for Levython programming language.

## Features

- **Syntax Highlighting** - Full support for `.levy` and `.ly` files
- **Code Snippets** - Quick templates for functions, loops, conditionals
- **Bracket Matching** - Auto-close brackets, parentheses, quotes
- **Comment Support** - Line comments with `#`
- **Indentation** - Smart indentation for code blocks

## Installation

### From VSIX (Recommended)

1. Download the `.vsix` file
2. Open VS Code
3. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
4. Type "Install from VSIX"
5. Select the downloaded file

### Manual Installation

1. Copy the `vscode-levython` folder to:
   - **Windows**: `%USERPROFILE%\.vscode\extensions\`
   - **macOS**: `~/.vscode/extensions/`
   - **Linux**: `~/.vscode/extensions/`
2. Restart VS Code

## Snippets

| Prefix | Description |
|--------|-------------|
| `act` | Create a function |
| `if` | If statement |
| `ife` | If-else statement |
| `for` | For loop |
| `forr` | For loop with range |
| `while` | While loop |
| `var` | Variable assignment |
| `say` | Print output |
| `list` | Create a list |
| `imp` | Import module |
| `main` | Main file template |

## Syntax

```levy
# This is a comment

# Variables use <- for assignment
name <- "Levython"
count <- 42

# Functions use 'act' keyword
act greet(name) {
    say("Hello, " + name + "!")
}

# Return with ->
act add(a, b) {
    -> a + b
}

# Control flow
if count > 10 {
    say("Big number!")
} else {
    say("Small number")
}

# Loops
for i in range(1, 5) {
    say(str(i))
}
```

## File Extensions

- `.levy` - Levython source file
- `.ly` - Levython source file (short)

## Links

- [Levython GitHub](https://github.com/levython/Levython)
- [Documentation](https://levython.org/docs)

## License

MIT License
