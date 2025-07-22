package main

import (
	"tool/file"
	"encoding/yaml"
	"encoding/json"
)

command: "run": {
	input: file.Read & {filename: "loop_write_files/in.json"}
	//debug: cli.Print & { text: input.contents }

	in_json: json.Unmarshal(input.contents)

	_map: [Name=string]: [Version=string]: {
		name:    Name
		version: Version
	}

	// CRITICAL: _map: {...} MUST be OUTSIDE the for loop. This applies everwhere in the file
	// in other words, loops MUST be INSIDE some field.
	_map: {
		for v in in_json {
			"\(v.name)": "\(v.version)": {}
		}
	}

	out: {
		for name, versions in _map {
			"\(name)": v: [for version, val in versions {
				"\(version)"
			}]
		}
	}

	write: {
		for name, v in _map {
			"\(name)": file.Create & {
				filename: "\(name).yaml"
				contents: yaml.Marshal(v)
			}
		}
	}
}
