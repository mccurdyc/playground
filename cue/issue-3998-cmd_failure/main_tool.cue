package main

import (
	"tool/file"
	"encoding/json"
	"encoding/yaml"
)

// https://github.com/cue-lang/cue/issues/3998
//
// in.json and in.yaml both just have the following:
// [1, 2]

// cue cmd "read_file" ./cmd_failure
// command.read_file.in_json: error in call to encoding/json.Unmarshal: non-concrete value bytes:
//     ./cmd_failure/main_tool.cue:24:11
//     tool/file:6:14
// command.read_file.in_yaml: error in call to encoding/yaml.Unmarshal: non-concrete value bytes:
//     ./cmd_failure/main_tool.cue:25:11
//     tool/file:6:14

command: "read_file": {
	j: file.Read & {filename: "read_file/in.json"}
	y: file.Read & {filename: "read_file/in.yaml"}

	in_json: json.Unmarshal(j.contents)
	in_yaml: yaml.Unmarshal(y.contents)

	out: int

	// The bug is here where values collide, but it's hidden in the 'cue cmd' error message
	for v in in_json {out: v}
	for v in in_yaml {out: v}
}
