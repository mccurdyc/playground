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
	name:    "\(Name)_\(Version)"
	version: Version
}

// how can I properly populate this map object? AI?
for v in foo_json {
	_map: "\(v.name)": "\(v.version)": {}
}

multi_out: {
	for name, versions in _map {
		for _, v in versions {
			"\(v.name)": yaml.Marshal(v)
		}
	}
}
