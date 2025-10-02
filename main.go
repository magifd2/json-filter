package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"regexp"
	"strings"
)

// The following variables are set during build time by the linker.
var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

// fixIncompleteJSON attempts to fix a JSON string by adding missing closing braces or brackets.
func fixIncompleteJSON(s string) string {
	trimmedS := strings.TrimSpace(s)
	if strings.HasPrefix(trimmedS, "{") {
		openCount := strings.Count(s, "{")
		closeCount := strings.Count(s, "}")
		if openCount > closeCount {
			return s + strings.Repeat("}", openCount-closeCount)
		}
	} else if strings.HasPrefix(trimmedS, "[") {
		openCount := strings.Count(s, "[")
		closeCount := strings.Count(s, "]")
		if openCount > closeCount {
			return s + strings.Repeat("]", openCount-closeCount)
		}
	}
	return ""
}

// processInput reads all data from standard input and returns it as a single string.
func processInput() (string, error) {
	scanner := bufio.NewScanner(os.Stdin)
	var input strings.Builder
	for scanner.Scan() {
		input.WriteString(scanner.Text())
		input.WriteString("\n")
	}
	if err := scanner.Err(); err != nil {
		return "", fmt.Errorf("Error reading from stdin: %w", err)
	}
	return input.String(), nil
}

// extractAndValidateJSON extracts a JSON string from the input and validates it.
// It also attempts to fix common parsing errors like missing closing braces.
func extractAndValidateJSON(input string) (string, error) {
	// Define a regular expression to find a JSON object or array.
	re := regexp.MustCompile(`(?s)({.*}|\[.*\])`)

	// Find the first match of the JSON pattern.
	match := re.FindStringSubmatch(input)

	if len(match) > 1 {
		jsonString := strings.TrimSpace(match[1])
		jsonBytes := []byte(jsonString)
		var j interface{}

		err := json.Unmarshal(jsonBytes, &j)
		if err == nil {
			// If successful, return the valid JSON string.
			var prettyJSON bytes.Buffer
			if err := json.Indent(&prettyJSON, jsonBytes, "", "  "); err == nil {
				return prettyJSON.String(), nil
			}
			return jsonString, nil
		}

		// If there's a parsing error, check if it's due to an unexpected end of input.
		if strings.Contains(err.Error(), "unexpected end of JSON input") {
			fixedJSON := fixIncompleteJSON(jsonString)
			if fixedJSON != "" {
				var fixedJ interface{}
				if json.Unmarshal([]byte(fixedJSON), &fixedJ) == nil {
					// If the fix works, return the corrected JSON.
					var prettyFixedJSON bytes.Buffer
					if err := json.Indent(&prettyFixedJSON, []byte(fixedJSON), "", "  "); err == nil {
						return prettyFixedJSON.String(), nil
					}
					return fixedJSON, nil
				}
			}
		}

		// If all attempts fail, return an error.
		return "", fmt.Errorf("Could not parse or fix the extracted JSON. Original output: %s", jsonString)

	}
	// If no JSON was found, return an error.
	return "", fmt.Errorf("No valid JSON found in the input.")
}

// handleOutput prints the result or handles the error based on the bypass flag.
func handleOutput(result string, err error, bypass bool, originalInput string) {
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		if bypass {
			fmt.Print(originalInput)
		}
		os.Exit(1)
	} else {
		fmt.Println(result)
	}
}

// main is the entry point of the application.
func main() {
	// Define a boolean flag for the bypass mode.
	bypassMode := flag.Bool("bypass", false, "Bypass mode: if JSON parsing fails, output the original input instead of skipping.")
	
	// Add a version flag.
	showVersion := flag.Bool("version", false, "Print version information")
	
	flag.Parse()

	// Handle version flag.
	if *showVersion {
		fmt.Printf("json-filter-cli version: %s, commit: %s, built on: %s\n", version, commit, date)
		return
	}

	// Process the input from stdin.
	rawOutput, err := processInput()
	if err != nil {
		handleOutput("", err, *bypassMode, rawOutput)
	}

	// Extract and validate the JSON from the input.
	extractedJSON, err := extractAndValidateJSON(rawOutput)
	
	// Handle the final output based on the result and bypass mode.
	handleOutput(extractedJSON, err, *bypassMode, rawOutput)
}
