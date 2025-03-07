# Rust  Calculator
A  terminal calculator written in Rust with real-time calculating.
### NEW UPDATE!
  - added advanced equations

## Features

- Real-time math equation solving
- Support for basic operations (`+`, `-`, `*`, `/`)
- advanced equations (trig, etc)
- functions
- Error handling
- Clean interface
## Automated installation (AUR) (recommended)
simply search Rmath in your preferred aur helper, for example, ``` yay -S rmath```
## Manual installation (for contributing)
### 1. Clone the Repository
```
git clone https://github.com/ColtNovak/rmath.git
cd RustCalc
```
### 2. Build the Project
```
cargo build --release
```
### 3. Move the binary
```
sudo mv target/release/rmath /usr/bin/
```

### 4. Check the `PATH`
```
echo $PATH
```
Then, restart your terminal, and that's it! Now you can run the 'rmath' command to launch the script.

## Usage
type anything into it, for example:
```sqrt(4.0) * pi + cos(4.0)```
and just watch as it solves your equation instantly and in real-time.

## Previews
### Todo
- Custom coloring for different symbols
- solving for X
- fractions
- auto parenthesis closing
- more functions
- I lowk have NO idea how to update my aur package lol help me
