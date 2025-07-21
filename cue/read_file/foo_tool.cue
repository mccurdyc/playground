package read_file

import (
	"tool/file"
	"encoding/yaml"
	"encoding/json"
)

var: {
	in_file: string @tag(in_file)
}

command: "read_file": {
	input: file.Read & {
		filename: var.in_file
		contents: bytes
	}

	foo_json: json.Unmarshal(input.contents)

	_map: [Name=string]: [Version=string]: {
		name:    "\(Name)_\(Version)"
		version: Version
	}

	for v in foo_json {
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
