package main

import (
	"tool/file"
	"tool/cli"
	"encoding/yaml"
	"encoding/json"
)

command: "run": {
	input: file.Read & {
		_in_json: json.Unmarshal(input.contents)
		filename: "loop_write_files/in.json"
	}

	_map: [Name=string]: [Version=string]: {
		name:    Name
		version: Version
	}

	// CRITICAL: _map: {...} MUST be OUTSIDE the for loop. This applies everwhere in the file
	// in other words, loops MUST be INSIDE some field.
	_map: {
		for v in input._in_json {
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
			"\(name)": cli.Print & {
				$dep: input.$done
				text: yaml.Marshal(v)
			}
		}
	}
}
