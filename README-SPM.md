# ParseKit (Swift Package)

A Swift Package Manager distribution of [ParseKit](https://github.com/itod/parsekit),
Todd Ditchendorf's Objective-C tokenisation and grammar-parsing toolkit. This is
intended to live as a **fork of `itod/parsekit`** with only `Package.swift` (and
this file) added on top, so it can be consumed via SPM instead of an embedded
Xcode subproject while still tracking upstream. No ParseKit source has been changed.

> ParseKit is deprecated upstream in favour of [PEGKit](https://github.com/itod/pegkit).
> This package keeps the existing runtime-parsing dependency building under SPM;
> it is not an attempt to advance ParseKit. (Moving to PEGKit is a larger change
> because PEGKit drops ParseKit's runtime grammar parsing.)

Keep it as a fork so you can pull upstream fixes:

```bash
git remote add upstream https://github.com/itod/parsekit.git
git fetch upstream && git merge upstream/master
```

Merges stay clean because the only file you add is `Package.swift` (rename this
`README-SPM.md` if you don't want to clobber ParseKit's own `README.md`).

## Installation

### Xcode
1. **File ▸ Add Package Dependencies…**
2. Enter this repo's URL.
3. **Dependency Rule → Commit**, paste the commit SHA to pin to, add the
   **ParseKit** library to your target.

### Package.swift
```swift
.package(url: "https://github.com/<you>/ParseKit.git", revision: "<40-char-sha>")
```

> **Must be referenced by commit or branch, not by a version tag.** ParseKit is
> manual-reference-counted, so the target disables ARC via `-fno-objc-arc`
> (an `unsafeFlags` setting). SwiftPM only allows packages that use `unsafeFlags`
> to be consumed via a branch/revision requirement — which is the commit pin
> above — and will reject a version-range/tag requirement.

## Usage

```objc
#import <ParseKit/ParseKit.h>

PKParser *parser = [[PKParserFactory factory] parserFromGrammar:grammar
                                                       assembler:assembler
                                                           error:nil];
PKAssembly *result = [parser parse:input error:nil];
```

## What is and isn't compiled

Only `src` is compiled and only `include` is exposed as public headers. The
static parser **generator** `PKSParserGenVisitor.{h,m}` is excluded, because it is
the sole dependant on MGTemplateEngine and the app only needs ParseKit's runtime
grammar parsing — not design-time Objective-C source generation. The Xcode
project, demo/debug apps, tests, docs and resources are simply ignored (they
produce harmless "unhandled files" warnings, not errors).

The package therefore has **no external dependencies** and requires no code
generation.

## Building / verifying

```bash
swift build
```

Run at the repo root after pushing. If a private header fails to resolve, adjust
the `.headerSearchPath` entries in `Package.swift` (the AST node headers live in
`src/nodes`).

## Platforms

iOS 13+, macOS 10.15+.

## Licence

ParseKit is released under the Apache 2.0 Licence — see `License.txt`.
