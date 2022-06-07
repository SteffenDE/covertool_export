# CovertoolExport

**TODO: Add description**

## Installation

```elixir
def deps do
  [
    {:covertool_export, github: "SteffenDE/covertool_export", branch: "main"}
  ]
end
```

Usage:

```
mix test --cover --export-coverage default
mix covertool --file cover/default.coverdata
```
