package oneOf

// https://cuetorials.com/patterns/fields/#oneof
#OneOf: *{} | #A | #B // defaults to "ignore"

#A: {
	a?: string & =~"^a"
}

#B: {
	b?: string & =~"^b"
}

#OneOf// ignored

#OneOf & {a: "aa"}
