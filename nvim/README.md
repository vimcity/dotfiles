# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## SonarQube Integration

To enable real-time SonarQube diagnostics, set environment variables in `~/.zshrc`:

```bash
export SONAR_TOKEN="squ_your_token_here"
export SONAR_URL="https://sonarqube.yourcompany.com"
export SONAR_PROJECT_KEY="com.sony:cmt-reboot"
```

Get token: SonarQube UI → My Account → Security → Generate Token

Config: `lua/plugins/sonarqube.lua`
