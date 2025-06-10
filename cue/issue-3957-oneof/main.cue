package playground

#oneof: {a: string} | {b?: [...string]}
c: #oneof & {a: string | *"foo"}
c: a: "bar"

#oneofwithdefault: *{a: "foo"} | {a: string} | {b?: [...string]}
e: #oneofwithdefault & {b: ["b"]}

#A: {a!: string}
#B: {b?: [...string]}
#matchone: matchN(1, [#A, #B])
#C: {
	// embedded
	#matchone
}
d: #C & {a: "d"}

#matchonewithdefault: *{a: "a"} | matchN(1, [#A, #B])
#D: {
	// embedded
	#matchonewithdefault
}
f: #D
g: #D & {b: ["b"]}
