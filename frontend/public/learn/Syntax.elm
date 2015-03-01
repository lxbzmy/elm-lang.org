import Graphics.Element (..)
import Markdown
import Signal (Signal, (<~))
import Website.Skeleton (skeleton)
import Window


port title : String
port title = "Elm语法参考"


main : Signal Element
main =
  skeleton "开始学习" content <~ Window.dimensions


content : Int -> Element
content w =
  width (min 600 w) intro


intro : Element
intro = Markdown.toElement """

# Elm语法参考

Elm的基本语法参考:

- [注释（Comments）](#-comments-)
- [字面量（Literals）](#-literals-)
- [列表（Lists）](#-lists-)
- [条件表达式（Conditionals）](#-conditionals-)
- [共用体Union Types](#-union-types-)
- [记录（Records）](#-records-)
- [函数（Functions）](#-functions-)
- [Infix Operators](#-infix-operators-)
- [Let表达式（Let Expressions）](#-let-expressions-)
- [Applying Functions](#-applying-functions-)
- [Mapping with `(<~)` and `(~)`](#-mapping-)
- [模块（Modules）](#-modules-)
- [类型声明（Type Annotations）](#-type-annotations-)
- [类型别名（Type Aliases）](#-type-aliases-)
- [JavaScript FFI](#-javascript-ffi-)
- [还*不*支持的东西](#-things-not-in-elm-)

Check out the [learning resources](/Learn.elm) for
tutorials and examples on actually *using* this syntax.

### 注释（Comments）

```haskell
--单行注释

{- 多行注释
   {- 也能嵌套 -}
-}
```

Here's a handy trick that every Elm programmer should know:

```haskell
{--}
add x y = x + y
--}
```

Just add or remove the `}` on the first line and you'll toggle between commented and uncommented!

### 字面量（Literals）

```haskell
-- Boolean
True  : Bool
False : Bool

42    : number  -- Int or Float depending on usage
3.14  : Float

'a'   : Char
"abc" : String

-- 多行字符串
\"\"\"
This is useful for holding JSON or other
content that has "quotation marks".
\"\"\"
```

Typical manipulation of literals:

```haskell
True && not (True || False)
(2 + 4) * (4^2 - 9)
"abc" ++ "def"
```

### 列表（Lists）

下面这四种写法含义相等：

```haskell
[1..4]
[1,2,3,4]
1 :: [2,3,4]
1 :: 2 :: 3 :: 4 :: []
```

### 条件表达式（Conditionals）

```haskell
if powerLevel > 9000 then "OVER 9000!!!" else "meh"
```

Multi-way if-expressions make it easier
to have a bunch of different branches.
You can read the `|` as *where*.

```haskell
if | key == 40 -> n+1
   | key == 38 -> n-1
   | otherwise -> n
```

You can also have conditional behavior based on the structure of algebraic
data types and literals

```haskell
case maybe of
  Just xs -> xs
  Nothing -> []

case xs of
  hd::tl -> Just (hd,tl)
  []     -> Nothing

case n of
  0 -> 1
  1 -> 1
  _ -> fib (n-1) + fib (n-2)
```

在使用这种写法的时候，要注意对齐子条件的缩进。

### Union Types

```haskell
type List = Empty | Node Int List
```

Not sure what this means? [Read this](/learn/Pattern-Matching.elm).

### Records

For more explanation of Elm&rsquo;s record system, see [this overview][exp],
the [initial announcement][v7], or [this academic paper][records].

  [exp]: /learn/Records.elm "Records in Elm"
  [v7]:  /blog/announce/0.7.elm "Elm version 0.7"
  [records]: http://research.microsoft.com/pubs/65409/scopedlabels.pdf "Extensible records with scoped labels"

```haskell
point = { x = 3, y = 4 }       -- create a record

point.x                        -- access field
map .x [point,{x=0,y=0}]       -- field access function

{ point - x }                  -- remove field
{ point | z = 12 }             -- add field
{ point - x | z = point.x }    -- rename field
{ point - x | x = 6 }          -- update field

{ point | x <- 6 }             -- nicer way to update a field
{ point | x <- point.x + 1
        , y <- point.y + 1 }   -- batch update fields

dist {x,y} = sqrt (x^2 + y^2)  -- pattern matching on fields
\\{x,y} -> (x,y)

lib = { id x = x }             -- polymorphic fields
(lib.id 42 == 42)
(lib.id [] == [])

type alias Location = { line:Int, column:Int }
```

### Functions

```haskell
square n = n^2

hypotenuse a b = sqrt (square a + square b)

distance (a,b) (x,y) = hypotenuse (a-x) (b-y)
```

Anonymous functions:

```haskell
square = \\n -> n^2
squares = map (\\n -> n^2) [1..100]
```

### Infix Operators

You can create custom infix operators. The default
[precedence](http://en.wikipedia.org/wiki/Order_of_operations)
is 9 and the default
[associativity](http://en.wikipedia.org/wiki/Operator_associativity)
is left, but you can set your own.
You cannot override the built-in operators though.

```haskell
f <| x = f x

infixr 0 <|
```

Use [`(<|)`](http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#<|)
and [`(|>)`](http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#|>)
to reduce parentheses usage. They are aliases for function
application.

```haskell
f <| x = f x
x |> f = f x

dot =
  scale 2 (move (20,20) (filled blue (circle 10)))

dot' =
  circle 10
    |> filled blue
    |> move (20,20)
    |> scale 2
```

Historical note: this is borrowed from F#, inspired by Unix pipes,
improving upon Haskell&rsquo;s `($)`.

### Let Expressions

```haskell
let n = 42
    (a,b) = (3,4)
    {x,y} = { x=3, y=4 }
    square n = n * n
in
    square a + square b
```

Let-expressions are indentation sensitive.
Each definition should align with the one above it.

### Applying Functions

```haskell
-- alias for appending lists and two lists
append xs ys = xs ++ ys
xs = [1,2,3]
ys = [4,5,6]

-- All of the following expressions are equivalent:
a1 = append xs ys
a2 = (++) xs ys

b1 = xs `append` ys
b2 = xs ++ ys

c1 = (append xs) ys
c2 = ((++) xs) ys
```

The basic arithmetic infix operators all figure out what type they should have automatically.

```haskell
23 + 19    : number
2.0 + 1    : Float

6 * 7      : number
10 * 4.2   : Float

100 // 2  : Int
1 / 2     : Float
```

There is a special function for creating tuples:

```haskell
(,) 1 2              == (1,2)
(,,,) 1 True 'a' []  == (1,True,'a',[])
```

You can use as many commas as you want.

### Mapping

The `map` functions are used to apply a normal function like `sqrt` to a signal
of values such as `Mouse.x`. So the expression `(map sqrt Mouse.x)` evaluates
to a signal in which the current value is equal to the square root of the current
x-coordinate of the mouse.

You can also use the functions `(<~)` and `(~)` to map over signals. The squiggly
arrow is exactly the same as the `map` function, so the following expressions
are the same:

```haskell
map sqrt Mouse.x
sqrt <~ Mouse.x
```

You can think of it as saying &ldquo;send this signal through this
function.&rdquo;

The `(~)` operator allows you to apply a signal of functions to a signal of
values `(Signal (a -> b) -> Signal a -> Signal b)`. It can be used to put
together many signals, just like `map2`, `map3`, etc. So the following
expressions are equivalent:

```haskell
map2 (,) Mouse.x Mouse.y
(,) <~ Mouse.x ~ Mouse.y

map2 scene (fps 50) (sampleOn Mouse.clicks Mouse.position)
scene <~ fps 50 ~ sampleOn Mouse.clicks Mouse.position
```

More info can be found [here](/blog/announce/0.7.elm#do-you-even-lift)
and [here](http://package.elm-lang.org/packages/elm-lang/core/latest/Signal).

### Modules

```haskell
module MyModule where

-- qualified imports
import List                    -- List.map, List.foldl
import List as L               -- L.map, L.foldl

-- open imports
import List (..)               -- map, foldl, concat, ...
import List ( map, foldl )     -- map, foldl

import Maybe ( Maybe )         -- Maybe
import Maybe ( Maybe(..) )     -- Maybe, Just, Nothing
import Maybe ( Maybe(Just) )   -- Maybe, Just
```

Qualified imports are preferred. Module names must match their file name,
so module `Parser.Utils` needs to be in file `Parser/Utils.elm`.

### Type Annotations

```haskell
answer : Int
answer = 42

factorial : Int -> Int
factorial n = product [1..n]

addName : String -> a -> { a | name:String }
addName name record = { record | name = name }
```

### Type Aliases

```haskell
type alias Name = String
type alias Age = Int

info : (Name,Age)
info = ("Steve", 28)

type alias Point = { x:Float, y:Float }

origin : Point
origin = { x=0, y=0 }
```

### JavaScript FFI

```haskell
-- incoming values
port userID : String
port prices : Signal Float

-- outgoing values
port time : Signal Float
port time = every second

port increment : Int -> Int
port increment = \\n -> n + 1
```

From JS, you talk to these ports like this:

```javascript
var example = Elm.worker(Elm.Example, {
  userID:"abc123",
  prices:11
});

example.ports.prices.send(42);
example.ports.prices.send(13);

example.ports.time.subscribe(callback);
example.ports.time.unsubscribe(callback);

example.ports.increment(41) === 42;
```

More example uses can be found
[here](https://github.com/evancz/elm-html-and-js)
and [here](https://gist.github.com/evancz/8521339).

Elm has some built-in port handlers that automatically take some
imperative action:

 * [`title`](/edit/examples/Reactive/Title.elm) sets the page title, ignoring empty strings
 * [`log`](/edit/examples/Reactive/Log.elm) logs messages to the developer console
 * [`redirect`](/edit/examples/Reactive/Redirect.elm) redirects to a different page, ignoring empty strings

Experimental port handlers:

 * `favicon` sets the pages favicon
 * `stdout` logs to stdout in node.js and to console in browser
 * `stderr` logs to stderr in node.js and to console in browser

### Things *not* in Elm

Elm currently does not support:

- operator sections such as `(+1)`
- guarded definitions or guarded cases. Use the multi-way if for this.
- `where` clauses
- any sort of `do` or `proc` notation

"""
