package main

input: [
	{name: "a", version: 1},
	{name: "a", version: 2},
	{name: "b", version: 1},
]

output: [Name=string]: [Version=string]: {
	name:    "\(Name)_\(Version)"
	version: Version
}

// https://cuelang.org/docs/tour/types/templates/
{for v in input {output: "\(v.name)": "\(v.version)": {}}}

// manually
// output: "a": "1": {}
// output: "a": "2": {}

// goal
// a: {
//  "1": { name: "a-1"}
//  "2": { name: "a-2"}
// ...
// }
