![Logo](https://raw.githubusercontent.com/TheRake66/loop/main/logo.png)



## Usage
```
Description:
    Run a bash script and automatically restarts it in case of a scheduled
    shutdown or crash.

Usage:
    loop [mode] [time] [script] <arguments>

Options:
    [mode]
        -start     Start the script and watch it.
        -stop      Stop watching the script but don't stop it.
    [time]         The timeout before restarting the script (in seconds).
    [script]       The script path.
    <arguments>    The argument(s) to pass to the script when starting.

Example:
    loop -start 5 ./script.sh
    loop -start 0 ./script.sh arg1 arg2
    loop -stop ./script.sh
```



## Installation
- Download `loop.sh`.
- Rename the script to remove the `.sh` extension.
```bash
mv loop.sh loop
```
- Move the script to the programs directory.
```bash
mv loop /usr/local/bin/
```
- Make the script executable.
```bash
chmod +x /usr/local/bin/loop
```



## License
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

MIT License

Copyright (c) 2024 TheRake66

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.