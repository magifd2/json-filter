# json-filter

`json-filter` is a powerful command-line tool designed to extract, validate, prettify, and even attempt to fix incomplete JSON data from various inputs, primarily standard input. It's ideal for processing logs, API responses, or any text stream that might contain JSON.

## Features

-   **Intelligent JSON Extraction**: Automatically identifies and extracts JSON objects embedded within larger text streams or logs using a robust regular expression.
-   **Automatic Prettification**: Valid JSON is automatically formatted with proper indentation for enhanced readability.
-   **Incomplete JSON Recovery**: Attempts to repair malformed or truncated JSON by intelligently adding missing closing braces (`}`). This is particularly useful when dealing with partial JSON outputs.
-   **Bypass Mode**: A `--bypass` flag allows the original input to be passed through to standard output if JSON extraction or parsing fails, preventing pipeline interruptions.
-   **Version Information**: Supports a `--version` flag to display the tool's version, commit hash, and build date.

## Installation

To install `json-filter`, ensure you have Go installed (version 1.16 or higher).

```bash
git clone https://github.com/magifd2/json-filter.git
cd json-filter
make
sudo mv bin/json-filter-cli /usr/local/bin/
```

## Usage

`json-filter` reads from standard input and writes the processed JSON to standard output.

```bash
<your_command_output_with_json> | json-filter [flags]
```

### Flags

-   `--bypass`: If JSON parsing fails, output the original input instead of an error.
    ```bash
    echo "Some text before {\"key\": \"value\"" | json-filter --bypass
    # Output: Some text before {"key": "value"
    ```
-   `--version`: Print version information and exit.
    ```bash
    json-filter --version
    # Output: json-filter-cli version: ..., commit: ..., built on: ...
    ```

### Examples

**Basic JSON Extraction and Prettification:**

```bash
echo 'INFO: User data: {"id": 123, "name": "Alice", "email": "alice@example.com"}' | json-filter
# Output:
# {
#   "id": 123,
#   "name": "Alice",
#   "email": "alice@example.com"
# }
```

**Handling Incomplete JSON:**

```bash
echo '{"data": {"item": "value"'
# Output:
# {
#   "data": {
#     "item": "value"
#   }
# }
```

**Using with `curl`:**

```bash
curl -s https://api.github.com/users/octocat | json-filter
# Output: (prettified JSON response from GitHub API)
```

## Development

### Building from Source

```bash
make
```

This will build the `json-filter-cli` executable in the `bin/` directory.

### Running Tests

(No tests are currently implemented, but this section is a placeholder for future development.)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
