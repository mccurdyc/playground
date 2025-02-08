package oneOf

// https://cuetorials.com/patterns/fields/#oneof
#OneOf: *{} | #A | #B // defaults to "ignore"

#A: {
	a: "a"
}

#B: {
	b: "b"
}

#OneOf// ignored

#OneOf & #A

#AOrB: *{aa: "aa"} | {bb: "bb"}

#AOrB
