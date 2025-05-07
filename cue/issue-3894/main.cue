// https://github.com/cue-lang/cue/issues/3894
package playground

out: {a?: string} | {b?: {value: string}}
out: {
	if true == true {
		b: {value: "true"}
	}
}
