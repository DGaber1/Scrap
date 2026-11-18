# App versioning

Every build of Scrap shows **Version (Build)** and the **commit** it was built from,
under Profile → About Scrap and at the bottom of Profile (for example `Scrap v1.1 (87)`).

Nobody edits version numbers by hand. A build step in Xcode, **"Stamp version from git"**
on the Scrap2 target, reads them from git each time the app is built:

| Shown as | Comes from | Changes when |
|---|---|---|
| Version (`1.1`) | The latest `app-vX.Y` git tag (`1.0` if there is none) | Someone adds a new `app-v` tag |
| Build (`87`) | The number of commits in the branch | Someone commits |
| Commit (`a1b2c3d`) | The short hash of the latest commit | Someone commits |

Rebuilding without a new commit always gives the same numbers. A build made with
uncommitted changes shows the commit as `a1b2c3d-dirty`, so it is never mistaken for a release.

## Starting a new version

Only when the team decides it is a new release (before a demo or a TestFlight upload), not on every push:

```
git tag app-v1.1
git push --tags
```

Or on GitHub: Releases → Draft a new release → tag `app-v1.1`.

Use the `app-v` prefix. Plain `v…` tags belong to the report's build workflow and are ignored by the app.

## Rules

- Build TestFlight and App Store uploads from **committed** code, so the version points to a real commit.
- Build from a git clone, not a downloaded zip; without git history the app falls back to `1.0 (1)` and commit `unknown`.
- CI must clone the full history (`actions/checkout` with `fetch-depth: 0`) or the build number will be wrong.
