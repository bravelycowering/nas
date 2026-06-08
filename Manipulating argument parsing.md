# Manipulating argument parsing

Often when writing a script that relies on parsing or handling strings, I've run into a rather annoying problem: during parsing NAS trims all extra and unnecessary whitespace in each action. Indentation gets removed, but so does any trailing spaces, which seemingly makes setting a package to any whitespace (or appending it to the end of one) impossible. However, this only happens during initial parsing. Packages that haven't been set yet unwrap to literally nothing, so unwrapping an unset package at the end of whatever action we want to have trailing whitespace preserves it perfectly.

While it's hard to guarantee any given name will never be used, conveniently you can unwrap a package with no name by just not putting anything between the curly braces, and it's very unlikely that this package will ever have a value.

This allows us to add trailing whitespace to whatever package we want by simply adding `{}` to the end of the statement (for example `set l_str &f> {}` would preserve the space after the greater than sign). So if we wanted to set a package that contains a single space as it's value, we are left with something like this:
```sh
set space  {}
```
Notice the two spaces between the package name and the curly braces. I've done that because action parameters are split by a single space, and unlike the `setsplit` action, empty parameters are preserved. The first space is simply to split the argument, and everything after (including the second space and curly braces) is what the package winds up being set to.

Now wait hold on: if parameters can be left empty by simply putting nothing between the spaces, does that mean we can set to that nameless package? Yes, we can simply put 2 spaces after the word `set` to indicate no name, allowing us to set it to whatever we want.
```sh
set  whatever we want
```
This can happen accidentally if you're unwrapping a package as the name of another package (ie `set {runArg1} something`, as if it unwraps to nothing, you're left with just the two spaces. If we wanted to set this package to a single space intentionally (assuming it's currently set to nothing), that would look something like this:
```sh
set   {}
```
However this is a problem. Now that we've assigned it a value we can no longer unwrap it in order to preserve trailing whitespace correctly, as after that every reference to `{}` would insert a space. So what can we do about that?

If action parameters are split by a single space, this means that you can never set to a package that contains a space in the name, as action parameters are split at runtime. However, you can absolutely still unwrap packages that have a space in their name. This means that a package who's name is a single space can never be set to, and can be safely unwrapped with `{ }` instead of the nameless package for whatever shenanigans we want. So to consistently set the nameless package to a single space, we would actually need something like this:
```sh
set   { }
```
Disgusting.