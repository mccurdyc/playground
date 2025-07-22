package read_file

import (
	"tool/file"
	"encoding/yaml"
	"encoding/json"
)

// cue cmd "read_file" ./read_file
// command.read_file.foo_json: error in call to encoding/json.Unmarshal: non-concrete value bytes:
//    ./read_file/foo_tool.cue:15:12
//    ./read_file/foo_tool.cue:12:13

command: "read_file": {
	input: file.Read & {
		filename: "read_file/in.json"
		contents: bytes
	}

	foo_json: json.Unmarshal(input.contents)

	_map: [Name=string]: [Version=string]: {
		name:    "\(Name)_\(Version)"
		version: Version
	}

	for v in foo_json {
		// _map: "\(v.name)": "\(v.version)": {}
		_map: "\(v.name)": "\(v.version)": {
			name:    v.name
			version: v.version
		}
	}

	multi_out: {
		for name, versions in _map {
			for _, v in versions {
				"\(v.name)": file.Create & {
					filename: "read_file/\(v.name).yaml"
					contents: yaml.Marshal(v)
				}
			}
		}
	}
}
