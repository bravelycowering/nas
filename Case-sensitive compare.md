# Case-sensitive compare

Most things in Not Awesome Script are case-insensitive. Package names are case-insensitive, and the `=` and `has` conditions don't care about case either, which makes it tricky to check for specific casing in strings. If you want to make sure the case is correct you only have a couple roundabout options.

The first option is very similar to what I talked about in [Using labels as boolean flags](/nas/Using labels as boolean flags.md), since labels happen to be case-sensitive. If you only need to compare a package to a constant value, you could define a label that only exists if the case-sensitive value is inserted somewhere in it, and then use `if label` to check for it's existence. A simple example might look like this:
```q
#CaseSensitive(Hello=Hello)
#CaseSensitive(HELLO=HELLO)

// ... some other code ...

set pkg HELLO
if label #CaseSensitive({pkg}=Hello) msg This shouldn't happen...
if label #CaseSensitive({pkg}=HELLO) msg But this should!

set pkg Hello
if label #CaseSensitive({pkg}=Hello) msg Now this is true!
if label #CaseSensitive({pkg}=HELLO) msg This shouldn't be though...
```
To take the last two lines as an example, once the package unwraps inside the labels it's checking for the existence of `#CaseSensitive(Hello=Hello)` and `#CaseSensitive(Hello=HELLO)`. Since we only defined the former, that's the only check that succeeds, which is why we have two copies of what we are checking for in the label name. (The syntax for the labels doesn't need to look exactly like this, this is just what made the most sense to me)

This works for constants (and, since the separation of the condition from the action happens during the initial parsing, spaces don't break this!), but you can't do this if you want to compare two packages together to check if they match.

The other option is quite silly: for whatever reason, `setsplit` is case-sensitive when looking for the splitter in the string. Using this with the fact that `setsplit` discards empty entries means that when splitting a package up, if it *only* contains copies of the splitter (ie splitting `HelloHelloHello` by `Hello`), it will always return a length of 0. We can actually use this combined with a normal case-insensitive check to determine of two packages match exactly! Here's some sample code for that:
```q
set pkgA Some case-sensitive TEXT
set pkgB Some case-sensitive TEXT
// check if the two are equal regardless of case. if they aren't we can quit early
// we do this to also filter out any instances of "HelloHello" equaling "Hello" since that doesn't even match case-insensitively
ifnot pkgA|=|pkgB quit
// now we know they're at least matching in size, check using setsplit
setsplit pkgA {pkgB}
ifnot pkgA.Length|=|0 quit
// now run whatever we needed to run
msg They match!
```
It's certainly a bit more involved than just checking if a label already exists. We need three actions minimum to check this, and if the second check fails, you'll be left with an extra package `pkgA[0]` containing the same contents as `pkgA`. This can definitely be cleaned up and self-contained into a macro, but that comes at the cost of having to discard your current runArgs whenever you need to make this check.

As far as I'm aware, these are the only ways to do a case-sensitive comparison.