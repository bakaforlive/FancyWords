```
  _____                                 __        __                     _       
 |  ___|   __ _   _ __     ___   _   _  \ \      / /   ___    _ __    __| |  ___ 
 | |_     / _` | | '_ \   / __| | | | |  \ \ /\ / /   / _ \  | '__|  / _` | / __|
 |  _|   | (_| | | | | | | (__  | |_| |   \ V  V /   | (_) | | |    | (_| | \__ \
 |_|      \__,_| |_| |_|  \___|  \__, |    \_/\_/     \___/  |_|     \__,_| |___/
                                 |___/                                               
```

<p align="center">
  <b>A figlet clone written from scratch in Pascal.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/language-Pascal-E30460?style=flat-square" alt="Pascal">
  <img src="https://img.shields.io/badge/status-WIP-yellow?style=flat-square" alt="WIP">
  <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT License">
</p>

---

## About

**FancyWords** turns plain text into big ASCII-art banners, right in your terminal - a lightweight, dependency-free alternative to [figlet](http://www.figlet.org/), built entirely from scratch in **Pascal**.

No external font libraries, no system dependencies - just a compiler and a terminal.

## Features

- Render any text as ASCII-art banners
- Single static binary, no runtime dependencies
- Cross-platform (Linux / Windows, anywhere Free Pascal runs)

## Demo

```
$ fancywords Hello
  _              _   _         
 | |__     ___  | | | |   ___  
 | '_ \   / _ \ | | | |  / _ \ 
 | | | | |  __/ | | | | | (_) |
 |_| |_|  \___| |_| |_|  \___/ 
```

## Build

Requires [Free Pascal Compiler (FPC)](https://www.freepascal.org/).

```bash
# Arch Linux
sudo pacman -S fpc

git clone https://github.com/bakaforlive/FancyWords.git
cd FancyWords
fpc fancywords.pas
```

## Usage

```bash
./fancywords
(your text after executing command)
```

## Roadmap

- [ + ] Single 'fancywords (text)' command
- [ not added ] Multiple fonts
- [ not added ] Color output
- [ not added ] Width/alignment options
- [ not added ] Pipe support (`echo "text" | ./fancywords`)

## Contributing

PRs and issues are welcome. Fork the repo, create a branch, and submit a pull request.

## Authors

- [bakaforlive](https://github.com/bakaforlive)
- [ironcarrier](https://github.com/Ironcarrier228)

## License

[MIT](LICENSE)
