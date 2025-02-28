package ref

#Foos: [Name=string]: {
	bar:  string
	name: Name
	nested: {
		name: Name
	}
}

_foos: #Foos & {
	"a": {bar: "aa"}
	"b": {bar: "bb"}
}

output: [for _, v in _foos {v}]
