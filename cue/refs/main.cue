package ref

#Foo: [Name=string]: {
	bar:  string
	name: Name
	nested: {
		name: Name
	}
}

_foo: #Foo
_foo: "foo": {
	bar: "bar"
}

output: _foo["foo"]
