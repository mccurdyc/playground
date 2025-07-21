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

	single_out: file.Create & {
		filename: "read_file/out.yaml"
		contents: yaml.Marshal(foo_json)
	}

	multi_out: {
		for _, v in foo_json {
			for k, v2 in v {
				"\(k)": file.Create & {
					filename: "read_file/\(k).yaml"
					contents: yaml.Marshal({"\(k)": v2})
				}
			}
		}
	}
}
