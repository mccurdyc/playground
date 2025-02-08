package transform

#Transform: {
	input:  #Input
	output: #Output

	output: [{
		name: "outputted_here"
		some_list: [for k, v in input.top for kk, vv in v.some_list {{vv} & {
			added_in_transform_function: "added"
		}}]
	}]
}

#Input: {
	// TODO - the problem im fighting is with this top-level string key.
	// Because this template is only expecting strings
	//
	// https://cuelang.org/docs/tour/types/templates/
	// 
	// Currently, patterns must either be instances of string, or must be _.
	//
	//  job: [Name=_]: {
	//	name:     Name // Name is an alias.
	//	command:  string | *"exec \(Name)"
	//	replicas: uint | *1
	//}
	//
	//// Databases are important, so increase the
	//// replica minimum.
	//job: [#DB]: replicas: >=3
	//#DB: "postgres" | "mysql" | =~"db$"

	top: {
		[Outer=string]: {
			name: Outer
			some_list: [Inner=string]: {
				foo: Inner
				... // to allow 'added_in_transform_function' to be added
			}
		}
	}
}

#Output: [...{
	name!: string
	some_list: [...{
		foo: string
		... // to allow 'added_in_transform_function' to be added
	}]
}]
