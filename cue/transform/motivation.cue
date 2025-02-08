package transform

// // This "adds" some_list field to the Obj schema
// top: [Name=string]: {
// 	name: Name
// 	some_list: [NameName=string]: #Obj & {
// 		added: "added_here"
// 		foo:   "override"
// 	}
// }
// 
// // Converts top and some_list map to lists.
// top: [for k, v in top {v & {some_list: [for kk, vv in v.some_list {vv}]}},
// ]
// 
// #Obj: {
// 	foo: string | *"foo"
// }
// 
// top: "top": {
// 	some_list: "middle": {}
// }
