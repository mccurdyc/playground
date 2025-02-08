package main

import (
	"encoding/yaml"
	"tool/cli"
)

command: dump: {
	task: print: cli.Print & {
		text: yaml.Marshal(_rendered)
	}
}
