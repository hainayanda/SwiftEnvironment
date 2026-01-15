# Repository Guidelines

## Project Structure & Module Organization
- `Sources/SwiftEnvironment/` contains the main library implementation and public API.
- `Sources/SwiftEnvironmentMacro/` contains the macro target and compiler plugin.
- `Tests/SwiftEnvironmentTests/` holds XCTest-based unit and integration tests.
- Root files: `Package.swift` defines targets and dependencies; `README.md` documents usage.

## Build, Test, and Development Commands
- `swift build` builds the package locally.
- `swift test` runs all XCTest suites in `Tests/SwiftEnvironmentTests/`.
- `swift package resolve` refreshes SwiftPM dependencies if you update `Package.swift`.

## Coding Style & Naming Conventions
- Follow existing Swift style in the codebase; match indentation and spacing in nearby files.
- Public types use UpperCamelCase; functions and properties use lowerCamelCase.
- File names align with primary types (e.g., `GlobalEnvironment.swift`, `InstanceResolver.swift`).
- SwiftLint can be enabled by toggling `development` to `true` in `Package.swift`; keep code warning-free when enabled.

## Testing Guidelines
- Tests are written with XCTest and live in `Tests/SwiftEnvironmentTests/`.
- Test files mirror functionality (e.g., `SingletonInstanceResolverTests.swift`).
- Add or update tests for behavior changes and run `swift test` before opening a PR.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and topic-focused (e.g., "Update README", "Make macro more thread safe").
- Open PRs against `main` with a clear title and description.
- Include: problem statement, solution summary, test results, and any docs updates.
- Link related issues and add screenshots only when UI or documentation visuals change.

## Configuration & Compatibility
- Package targets Swift 5.9+ and Apple platforms listed in `Package.swift`.
- Keep macro and library changes aligned so public API and macro expansions stay in sync.
