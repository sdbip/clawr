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
- Replace the `print` command with a `print(_:)` function
  - Requires `trait HasStringRepresentation`
  - Requires bridging to C implementation
  - Requires the C function to be known to the `Scope`

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
