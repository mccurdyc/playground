package main

import (
	"encoding/yaml"
	"encoding/json"
)

in: """
	[1,2]
	"""

in_json: json.Unmarshal(in)
in_yaml: yaml.Unmarshal(in)

out: int

// The bug is here where values collide, but it's hidden in the 'cue cmd' error message
for v in in_json {out: v}
for v in in_yaml {out: v}
