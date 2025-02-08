package transform

#Transform: {
	input:  #Input
	output: #Output

	if input.value != _|_ {
		output: value: input.value
	}

	if input.null_check == null {
  output: null_check: "YIKES!! null check helped"
	}

	if input.value == _|_ {
		output: value: "YIKES! what you got"
	}
}

#Input: {
	// forgotten_field
	// value: string
	null_check: string | *null
}

#Output: {
	value!: string
	null_check!: string
}
