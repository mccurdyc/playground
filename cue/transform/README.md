# "Function" pattern

https://cuetorials.com/patterns/functions/

What I'm actually trying to do.

```cue
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
```

```bash
cue eval ./transform/...
...
top.0.some_list: conflicting value {[string]:(#Obj & {added:"added_here",foo:"override"})} (mismatched types list and struct):
```

With the `#Transform` "function".
```cue
cue eval ./transform/... -e 'output'
name: "outputted_here"
some_list: [{
    foo:   "override"
    added: "added_in_transform_function"
}]
```
