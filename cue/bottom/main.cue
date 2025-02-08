package bottom

input: {
	set:    "a"
	notSet: string
}

output: #Output & {
	set: input.set
	if input.notSet == _|_ {
		notSet: "im explicitly setting here"
	}
}

#Output: {
	set:                  string
	notSet:               string
	notSetButWithDefault: string | *"default"
}
