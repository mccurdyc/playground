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
	// Because you can't use file.Read in a NON-_tool.cue file
	// https://github.com/cue-lang/cue/issues/2043#issuecomment-1291601109
	// file.Read NEEDS to be in a "command" block - https://github.com/cue-lang/cue/discussions/1832#discussioncomment-3316408
	input: file.Read & {
		filename: var.in_file
		contents: bytes
	} // you can NOT add .contents on this line, it has to be separate

	foo_json: json.Unmarshal(input.contents)

	_list: [for v in foo_json {
		name:    v.name
		version: v.version
	}]

	single_out: file.Create & {
		filename: "read_file/out.yaml"
		contents: yaml.Marshal(_list)
	}

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
		for name, version in _map {
			for _, val in version {
				"\(val.name)": file.Create & {
					filename: "read_file/\(val.name).yaml"
					contents: yaml.Marshal({"\(val.name)": val})
				}
			}
		}
	}
}
