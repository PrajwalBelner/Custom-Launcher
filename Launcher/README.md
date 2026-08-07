# AI OpenCode Launcher

Connects OpenCode to the dual-boot AI server through secure SSH tunnels.

## Environments

- **Development:** `pgs@192.168.191.61`
- **Pre-Production:** `prd@192.168.191.62`

Only one environment is online at a time because both operating systems share the same physical server and AMD W7900 GPU.

## Windows Launchers

Open the **Windows Launchers** folder and run:

```text
start_ai_opencode_dev.bat
start_ai_opencode_prd.bat
```

- `start_ai_opencode_dev.bat` connects OpenCode to Development.
- `start_ai_opencode_prd.bat` connects OpenCode to Pre-Production.
- The Windows launchers use Git Bash to run the shared shell launcher.

## Linux Launchers

Open the **Linux Launchers** folder and run:

```bash
./start_ai_opencode_dev.sh
./start_ai_opencode_prd.sh
```

- `start_ai_opencode_dev.sh` connects OpenCode to Development.
- `start_ai_opencode_prd.sh` connects OpenCode to Pre-Production.
- The shell launchers can be used from Git Bash, WSL, or Linux.

## Custom Launchers

Windows and Linux launchers use:

```text
linux_start_opencode.sh
windows_start_opencode.bat
```