package read_file

import (
  "tool/cli"
	"tool/file"
)

command: "read_file": {
	input: file.Read & {
		filename: "read_file/in.txt"
    contents: string
	}

  out: cli.Print & {
    text: input.contents
  }
}
