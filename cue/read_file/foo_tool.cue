package read_file

import (
	"tool/file"
	"encoding/yaml"
)

command: "read_file": {
	// Because you can't use file.Read in a NON-_tool.cue file
	// https://github.com/cue-lang/cue/issues/2043#issuecomment-1291601109
	// file.Read NEEDS to be in a "command" block - https://github.com/cue-lang/cue/discussions/1832#discussioncomment-3316408
	read_files: {
		// CRITICAL You can NOT add `.contents` on the following line. They have to be separate calls.
		// EX: (file.Read & {...}).contents fails silently
		foo: (file.Read & {filename: "read_file/in.txt", contents: string}) // you can NOT add .contents on this line, it has to be separate
	}

	write: file.Create & {
		// CRITICAL this MUST be the full path because we merge the two below.
		// There is no such thing as "injecting" a value and reading it in the k8s_data.cue
		// file. You have to merge them at this level.
		//
		// This is effectively setting one deeply-nested value.
		_merged: top_level & {read: "\(read_files.foo.contents)"}
		filename: "read_file/out.txt"
		contents: yaml.Marshal(_merged)
	}
}
