package read_file

import (
	"tool/file"
	"encoding/yaml"
	"encoding/json"
)

command: "read_file": {
	// Because you can't use file.Read in a NON-_tool.cue file
	// https://github.com/cue-lang/cue/issues/2043#issuecomment-1291601109
	// file.Read NEEDS to be in a "command" block - https://github.com/cue-lang/cue/discussions/1832#discussioncomment-3316408
	read_files: {
		// CRITICAL You can NOT add `.contents` on the following line. They have to be separate calls.
		// EX: (file.Read & {...}).contents fails silently
		foo: (file.Read & {filename: "read_file/in.json", contents: bytes}) // you can NOT add .contents on this line, it has to be separate
	}

	foo_json: json.Unmarshal(read_files.foo.contents)

	works: file.Create & {
		filename: "read_file/out.yaml"
		contents: yaml.Marshal(foo_json)
	}

	also_works_now: {
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
