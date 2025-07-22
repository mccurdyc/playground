package main

import (
	"tool/file"
	"encoding/json"
)

// cue cmd "read_file" ./cmd_failure
// command.read_file.foo_json: error in call to encoding/json.Unmarshal: non-concrete value bytes:
//    ./read_file/foo_tool.cue:15:12
//    ./read_file/foo_tool.cue:12:13

command: "read_file": {
	input: file.Read & {
		filename: "read_file/in.json"
	}

	foo_json: json.Unmarshal(input.contents)

	foo: string

	// The bug is here where you values collide, but it's hidden in the error message
	for v in foo_json {
		foo: v.name
	}
}
