# JDTLS Troubleshooting Guide

## Error: "Client jdtls quit with exit code 13 and signal 0"

Exit code 13 typically indicates jdtls crashed during initialization. This is usually caused by corrupted cache or workspace files.

### Quick Fix (Recommended First Step)

Clear the entire jdtls cache and workspace:

```bash
rm -rf ~/.cache/nvim/jdtls
```

Then restart Neovim and open a Java file. The server will reinitialize with a fresh cache.

## Common Symptoms

Look for these errors in `$HOME/.local/state/nvim/lsp.log`:

- `java.io.UTFDataFormatException` - Corrupted index files
- `java.lang.OutOfMemoryError: Java heap space` - Running out of memory
- `Failed to load extension bundles` - jdtls initialization failure
- `Failed to resolve classpath` - Missing Maven dependencies

## Why This Happens

1. **Corrupted workspace cache** - jdtls index files become corrupted, especially with large projects
2. **Out of memory** - Working with large monorepos exceeds default heap size
3. **Stale workspace state** - Previous crashed sessions leave invalid metadata

## Solution Steps

1. **Clear the cache** (solves most issues):
   ```bash
   rm -rf ~/.cache/nvim/jdtls
   ```

2. **Restart Neovim** and open a Java file

3. **If still failing**, increase jdtls heap memory in your Neovim config:
   
   Edit `nvim/lua/plugins/java.lua` (or wherever jdtls is configured) and add:
   ```lua
   vim_opts = {
     jdtls = {
       cmd = {
         -- ... jdtls command ...
       },
       init_options = {
         bundles = { /* ... */ },
         extendedClientCapabilities = { /* ... */ },
       },
       -- Add this to increase heap memory
       -- (adjust -Xmx based on your system RAM)
       settings = {
         java = {
           jdt = {
             ls = {
               vmargs = "-XX:+UseG1GC -XX:+UseStringDeduplication -Xmx4g",
             },
           },
         },
       },
     },
   }
   ```

## Prevention

- Don't interrupt Neovim forcefully while jdtls is indexing
- Keep your local Maven cache in sync: `mvn clean install` periodically
- Ensure missing dependencies are available in your Maven repository

## Checking the Log

To see detailed error messages:

```bash
tail -100 ~/.local/state/nvim/lsp.log
```

Look for patterns like:
- `java.io.UTFDataFormatException` → Corrupted cache (use cache clear)
- `OutOfMemoryError` → Need more heap memory (increase -Xmx)
- `does not exist` → Missing Maven dependency (run `mvn install`)

## Related Configuration Files

- jdtls config: Usually in `~/.config/jdtls/` (not normally needed)
- Runtime cache: `~/.cache/nvim/jdtls/`
- Log file: `/Users/rgaur/.local/state/nvim/lsp.log`

## Additional Resources

- [jdtls README](https://github.com/eclipse-jdt/eclipse.jdt.ls)
- [eclipse.jdt.ls Configuration Options](https://github.com/eclipse-jdt/eclipse.jdt.ls/wiki/Configuring-the-IMS)
