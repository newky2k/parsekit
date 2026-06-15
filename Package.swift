// swift-tools-version:5.7
//
// ParseKit packaged for Swift Package Manager.
//
// Tuned for the current (2017) ParseKit layout: this manifest sits at the ROOT
// of the repo (your fork of itod/parsekit) whose tree contains at least:
//
//   <repo-root>/
//   ├── Package.swift          (this file)
//   ├── src/                   ParseKit sources (.m/.h)
//   │   └── nodes/             AST node classes (used by the dynamic factory)
//   └── include/ParseKit/      public headers, incl. ParseKit.h umbrella
//
// Consumers import it unchanged:   #import <ParseKit/ParseKit.h>
//
// WHY THE EXCLUDES
// ----------------
// Because `include` sits beside `src`, the target path must be the repo root.
// SwiftPM therefore scans the WHOLE tree and would otherwise treat the demo
// apps, generator app, tests, docs and the various `.lproj` folders as
// resources (which collide: multiple `InfoPlist.strings`). So we exclude
// everything that isn't `src`/`include`.
//
// We also exclude:
//   * `src/PKSParserGenVisitor.{h,m}` — the static parser GENERATOR, the only
//     thing depending on MGTemplateEngine (in `lib/`). The app uses ParseKit's
//     RUNTIME parsing (PKParserFactory parserFromGrammar:), not design-time code
//     generation, so excluding it avoids the MGTemplateEngine dependency. Nothing
//     else in `src` references it.
//   * the two `*_Prefix.pch` files in `src` (not compilable sources).
//
// Every listed path exists in this tree. If an upstream merge renames/moves any
// of them, update this list (SwiftPM errors on an exclude path that does not exist).
//
// USAGE FROM THE APP
// ------------------
// Add via Xcode ▸ Add Packages, Dependency Rule = Commit, paste the SHA to pin.
// In a manifest:
//   .package(url: "https://github.com/<you>/ParseKit.git", revision: "<40-char-sha>")

import PackageDescription

let package = Package(
    name: "ParseKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "ParseKit", targets: ["ParseKit"])
    ],
    targets: [
        .target(
            name: "ParseKit",
            path: ".",
            exclude: [
                // Non-library top-level folders/files (avoid resource scanning).
                "License.txt",
                "README.md",
                "README-SPM.md",
                "ParseKit.xcodeproj",
                "ParserGenApp",
                "debugapp",
                "demoapp",
                "docs",
                "en.lproj",
                "lib",
                "res",
                "test",
                // Prefix headers — not compilable sources.
                "src/ParseKit_Prefix.pch",
                "src/ParseKitMobile_Prefix.pch",
                // Static code generator — needs MGTemplateEngine, not used at runtime.
                "src/PKSParserGenVisitor.h",
                "src/PKSParserGenVisitor.m"
            ],
            sources: ["src"],                        // compiles src/ recursively (incl. src/nodes)
            publicHeadersPath: "include",            // exposes <ParseKit/ParseKit.h>
            cSettings: [
                .headerSearchPath("src"),            // top-level private headers
                .headerSearchPath("src/nodes"),      // AST node headers imported unqualified
                .headerSearchPath("include/ParseKit"),
                // ParseKit is written in manual reference counting (MRC). SwiftPM
                // compiles ObjC with ARC on by default, so turn ARC off for this
                // target (uses retain/release/autorelease throughout).
                //
                // ParseKit's Xcode project force-includes a prefix header that
                // defines PKAssertMainThread() and the PK_PLATFORM_* flags used
                // across the sources. SwiftPM has no prefix-header concept, so we
                // replicate it with -include.
                //
                // Pass the prefix by BARE FILENAME, not a path. `-include` resolves
                // through the header search chain (the `src` -I above), which
                // SwiftPM emits as an absolute path, so it's found regardless of
                // the compiler's working directory. A package-relative path
                // ("src/...") only works for `swift build` from the package root
                // and fails when Xcode builds the SPM package from elsewhere.
                .unsafeFlags([
                    "-fno-objc-arc",
                    "-include", "ParseKitMobile_Prefix.pch"
                ])
            ]
        )
    ]
)
