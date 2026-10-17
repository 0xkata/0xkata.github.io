# 0xkata.github.io

Personal site on Jekyll with the Chirpy theme. Posts in `_posts/`, drafts in `_drafts/`, styles in `_sass/`, scripts in `_javascript/`.

PRs follow the shared standard: https://github.com/j0team/pr-standard/blob/main/STANDARD.md (definition of done, root-cause fixes, review handling). This file adds what is specific to this repo.

## Checks

Run before every PR and before pushing review fixes:

- `npm test` (JS and SCSS lint)
- `bundle exec jekyll build`, or `bash tools/test.sh` to build and run html-proofer.

## PR rules

- PRs target `master`.
- Size limit excludes: `_posts/`, `_drafts/`, `assets/`, `package-lock.json`, `Gemfile.lock`.
