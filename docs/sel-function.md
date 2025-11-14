# the Quaternary `SEL` function

There is a function that can generate every possible binary operator: the `SEL` function. Let’s define `SEL(a, p, q, r)`, such that it returns `p` if `a` is `-`, `q` if `a` is `0` and `r` if `a` is `+`.

If we can form three distinct unary operators `g-(b)`, `g0(b)` and `g+(b)`, each of which returns the output we want from `b` when `a` is `-`, `0` and `+` respectively, we can define any arbitrary binary operator `f(a, b) = SEL(a, g-(b), g0(b), g+(b))`.

> [!example] the `CONS` ($\boxtimes$) operator
$$a \boxtimes b = \begin{cases}
    + & \text{if } a = b = + \\
    - & \text{if } a = b = - \\
    0 & \text{otherwise.}
\end{cases}$$

We could write it as a matrix:

> [!example] `CONS` / $\boxtimes$
> $$\mathrm{CONS} = \begin{bmatrix} - & 0 & 0 \\\ 0 & 0 & 0 \\\ 0 & 0 & +\end{bmatrix}$$

In this matrix, the rows represent the different values of one input, say $a$, and the columns represent the other, $b$. In order from top-to-bottom/left-to-right, the rows/columns represent the input values `-`, `0` and `+`, and the value displayed in each position is the output given that input.

If $a$ is `-`, then we want the output to be `[- 0 0]` (the top row of the matrix). I.e. we want the output to be `-` for $b$ = `-`, and `0` otherwise. If $a$ is `+`, then we want the output to be `[0 0 +]` (the bottom row). Meaning that we want `+` for $b$ = `+`, and `0` otherwise. If $a$ is `0` (the middle row), we want the output to be `0` regardless of $b$, a.k.a. `[0 0 0]`.

> [!note] Note that this is not linear algebra.
> The matrices in this document are not intended for matrix multiplication. Linear algebra formulas won’t help simplify complex ternary expressions. At least not using any of the matrices in this document. These matrices are for illustration and discombobulation.

From [earlier](./ternary-algebra.md), we have `is_plus0(b) = max(b, 0) = [0 0 +]`, `is_minus0(b) = max(¬b, 0) = [+ 0 0]`. The former perfectly matches the $a$ = `+` row, and if we negate the latter, it matches the $a$ = `-` row.

De Morgan teaches us that negating everything maintains truth, so `neg(max(¬b, 0))` can be simplified to `min(b, 0)`.

So: `g-(b)` = `¬is_minus0(b)` = `¬max(¬b, 0)` = `min(b, 0)`, `g+(b)` = `is_plus0(b)` = `max(b, 0)` and `g0(b)` = `0`.

> [!done] Therefore
> $\therefore$ $a \boxtimes b = \text{SEL} (a, \min(b, 0), 0, \max(b, 0))$.

Or in programmer-speak (using ternary AND/OR operators):

```kotlin
fun CONS(a, b) = SEL(a, b && 0, 0, b || 0)
```

> [!example] The `ANY` ($\boxplus$) operator.
 $$a \boxplus b = \begin{cases}
    + & \text{if } \max(a, b) = + \\
    - & \text{if } \min(a, b) = - \\
    0 & \text{otherwise.}
 \end{cases}$$

We could write this too as a matrix:

> [!example] `ANY` / $\boxplus$
> $$ANY = \begin{bmatrix} - & - & 0 \\\ - & 0 & + \\\ 0 & + & +\end{bmatrix}$$

If $a$ is `-`, we want the output to be `[- - 0]`. If $a$ is `+`, we want the output to be `[0 + +]`. If $a$ is `0`, we want the output to replicate $b$.

From [earlier](./ternary-algebra.md), we have `is_plus0(b) = max(b, 0)`, `is_minus0(b) = max(¬b, 0)`. We also have `roll_up(b)` which adds one to `b` and rolls around to `-` rather than `+2` if `b` = `+`, and its inverse: `roll_down`.

`b = [- 0 +]`

> [!example] Constructing `g-(b)`
> `g-(b) = [- - 0]`
> `is_plus0(b) = [0 0 +]`
> `roll_down(is_plus0(b)) = [- - 0] = g-(b)`

> [!example] Constructing `g+(b)`
> `g+(b) = [0 + +]`
> `is_minus0(b) = [+ 0 0]`
> `neg(is_minus0(b)) = [- 0 0]`
> `roll_up(neg(is_minus0(b))) = [0 + +] = g+(b)`

> [!note] Alternatively:
> `roll_down(is_minus0(b)) = [0 - -]`
> `neg(roll_down(is_minus0(b))) = [0 + +] = g+(b)`

> [!tip] So we can define:
> - `g-(b)` = `roll_down(is_plus0(b))` = `roll_down(max(b, 0))`,
> - `g0(b)` = `b`, and
> - `g+(b)` = `roll_up(neg(is_minus0(b)))` = `roll_up(neg(max(¬b, 0)))` = `roll_up(min(b, 0))`.

> [!done] Therefore
> $\therefore$ $a \boxplus b = \text{SEL} (a, \text{roll\_down}(\max(b, 0)), 0, \text{roll\_up}(\min(b, 0)))$.

Or in programmer-speak (using ternary AND/OR operators):

```kotlin
fun ANY(a, b) = SEL(a, roll_down(b || 0), 0, roll_up(b && 0))
```

Using `SEL` with arbitrary unary operators, we can generate any arbitrary binary operator. And I can confidently say that we can generate any arbitrary unary operator from the basic set of `roll_up`, `is_plus` and the ternary versions of basic Boolean operators AND/MIN, OR/MAX and NOT/NEG (and injecting constants into the binary operators to convert them into unaries).

The question then becomes: can we define `SEL` using basic operators?

## Defining `SEL`

```
SEL(x, a, b, c) = max(
  min(is_minus(x), a),
  min(is_zero(x), b),
  min(is_plus(x), c)
)
```

## Proof

For `x` = `-`:
- `is_minus(x)` = `+` → `min(+, a)` = `a`
- `is_zero(x)` = `-` → `min(-, b)` = `-`
- `is_plus(x)` = `-` → `min(-, c)` = `-`
- `max(a, -, -)` = `a` $\square$

For `x` = `0`:
- `is_minus(x)` = `-` → `min(-, a)` = `-`
- `is_zero(x)` = `+` → `min(+, b)` = `b`
- `is_plus(x)` = `-` → `min(-, c)` = `-`
- `max(-, b, -)` = `b` $\square$

For `x` = `+`:
- `is_minus(x)` = `-` → `min(-, a)` = `-`
- `is_zero(x)` = `-` → `min(-, b)` = `-`
- `is_plus(x)` = `+` → `min(+, c)` = `c`
- `max(-, -, c)` = `c` $\square$

## Summary

The `SEL` function can generate any binary operator. The function itself can be constructed using only the standard AND/OR/NOT operators and one new operator: `is_plus`.

It relies on formulating arbitrary unary operators to select from. These need one more operator: `roll_up`.

So in conclusion, ternary completeness is achieved by adding two new primitive operations to the three that are already fundamental to Boolean algebra.
