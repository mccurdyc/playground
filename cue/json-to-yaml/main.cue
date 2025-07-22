package main

import (
	"encoding/yaml"
	"encoding/json"
)

in: """
	[
	{
	  "name": "one",
	  "version": 1
	},
	{
	  "name": "one",
	  "version": 2
	},
	{
	  "name": "two",
	  "version": 2
	},
	{
	  "name": "three",
	  "version": 3
	}
	]
	"""

foo_json: json.Unmarshal(in)

_map: [Name=string]: [Version=string]: {
	name:    Name
	version: Version
}

for v in foo_json {
	_map: "\(v.name)": "\(v.version)": {}
}

out: [_=string]: {
	v: [...string]
}

for name, versions in _map {
	for version, val in versions {
		out: "\(name)": v: ["\(version)"]
	}
}

multi_out: {
	for name, _ in _map {
		"\(name)": yaml.Marshal(out[name])
	}
}
