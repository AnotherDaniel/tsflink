<!--
 * Copyright (C) 2026 Eclipse Foundation and others. 
 * 
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v. 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 * 
 * SPDX-FileType: DOCUMENTATION
 * SPDX-FileCopyrightText: 2025 Eclipse Foundation
 * SPDX-License-Identifier: EPL-2.0
-->

# tsflink Action

The `tsflink` action links [tsffer](https://github.com/AnotherDaniel/tsffer)-generated evidence-reference metadata (a set of `.tsffer` files ) into a TSF graph - automated as part of the project release workflow. The resulting TSF graph is then scored using the TSF `trudag` tool, and a TSF report is published. This report is ready for being served as part of a [Material-for-mkdocs](https://squidfunk.github.io/mkdocs-material/) website.
`tsflink` is part of a toolchain that is designed to support adoption of the Trustable Software Framework [TSF](https://codethinklabs.gitlab.io/trustable/trustable/). A hello-world style example of the overall idea and workflow can be found in the [`tsftemplate` project](https://github.com/AnotherDaniel/tsftemplate).

## Trustable Software Framework context

The [Eclipse Trustable Software Framework (TSF)](https://pages.eclipse.dev/eclipse/tsf/tsf/) approach is designed for consideration of software where factors such as safety, security, performance, availability and reliability are considered critical. TSF method asserts that any consideration of trust must be based on evidence.

TSF considers that delivery of software for critical systems must involve identification and management of the risks associated with the development, integration, release and maintenance of the software. In such contexts, software delivery is not complete without appropriate documentation and systems in place to review and mitigate these risks. The Eclipse Trustable Software Framework provides a method and tool consider supply chain and tooling risks as well as the risks inherent in pre-existing or newly developed software, and to apply statistical methods to measure confidence of the whole solution.

The TSF method places an emphasis on integrating well into a typical Open Source development process, by being built around versionable and bite-sized textual statements that get organized in a [DOT graph](https://en.wikipedia.org/wiki/DOT_(graph_description_language)) - thus immediately benefitting from the associated tooling ecosystem. It comes with cli tool for manipulating the TSF dot-graph (`trudag`), immediately suggesting application in CI/automation workflows.

## Using tsffer

The `tsflink` action requires little configuration or inputs; in the minimum case it will pull any `.tsffer` artifacts from workflow

### Inputs

- `tsffer_url`: (Optional) URL pointing to tsffer metadata artifact archive. If not provided, will retrieve `*.tsffer` artifacts from the GitHub workflow artifact store.

### Outputs

- `trudag_score`: TSF score computed after linking evidence refs.
- `trudag_report`: Name of archive file containing trudag-generated report.
- `trudag_report_dir`: Directory containing trudag-generated report files.

### Target release and other expectations

This action works best when run in the context of a release (tag-initiated) GitHub worflow:

- `GITHUB_WORKSPACE`, `GITHUB_REPOSITORY`, and `GITHUB_RUN_ID` are set to valid/real values, as these are used to determine asset upload target

## Example Usage

Using `tsflink` in your workflow looks like this:

```yaml
jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Link, score and publish TSF tree
        uses: AnotherDaniel/tsflink@v0.1.10
        id: link_tsffer
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

For a more complete example, please refer to the [`tsftemplate` project](https://github.com/AnotherDaniel/tsftemplate).
