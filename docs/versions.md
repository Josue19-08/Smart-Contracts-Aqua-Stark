# Version Information

This document tracks the tool versions used in this project, aligned with the proven configuration from death-mountain project.

## Tool Versions

Based on the analysis of death-mountain (a production Dojo game), we use:

- **Dojo**: 1.8.0 (package dependency)
- **Sozo**: 1.8.4
- **Cairo**: 2.14.0 (specified in Scarb.toml as cairo-version)
- **Scarb**: 2.14.0
- **Scarb**: Managed by Cairo installation

## Configuration Files

### `.tool-versions`
Contains versions for dojoup/asdf:
```
sozo 1.8.4
scarb 2.14.0
```

Note: The `dojo` package version is specified in `Scarb.toml`, not here.

### `Scarb.toml`
Specifies Cairo version and dependencies:
- `cairo-version = "=2.14.0"`
- `dojo = { git = "https://github.com/dojoengine/dojo", tag = "v1.8.0" }`
- Edition: `2024_07`

## Why These Versions?

These versions are proven in production by the death-mountain game, ensuring:
- Stability and reliability
- Compatibility with latest Dojo features
- Production-ready configurations
- Active community support

## Installation

Install tools using dojoup:
```bash
curl -L https://install.dojoengine.org | bash
dojoup install
```

This will install the versions specified in `.tool-versions`.

