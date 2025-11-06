# TODO

## Next

- `print` field

## Incomplete Features, Bugs & Redesigns

- `object`
  - factory methods
  - `ObjectLiteral` `{super.new()}`
- Functions
  - Function call as `Expression`
  - Varargs
  - Optional arguments
- toString calls
  - Check for `HasStringRepresetation` vtable
- Remove the `_data` struct?
  - Prefix field names with `_` instead of `.`
  - Prefix unnecessary for `data`

## Possible Next Features

- Operators
- Lambdas
- List comprehension
- `string`
- `regex`
- `ternary` (translates to `Optional<boolean>`)
- Read Eval Print Loop

## Other Thoughts and Ideas

- Read input from `stdin`. Swift has `readLine() -> String?`
  - I suppose `⌃D` is what causes the `nil` case.
  - Requires `Optional<T>`?
