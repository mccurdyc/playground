package playground

#oneof: {a: string} | {b?: [...string]}
c: #oneof & {a: string | *"foo"}
c: a: "bar"

#A: {a!: string}
#B: {b?: [...string]}
#matchone: matchN(1, [#A, #B])
#C: {
	// embedded
	#matchone
}
d: #C & {a: "d"}
