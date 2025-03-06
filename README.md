# Rust  Calculator
A  terminal calculator written in Rust with real time calculating.
### NEW UPDATE!
  - added advanced equations

## Features

- Real-time math equation solving
- Support for basic operations (`+`, `-`, `*`, `/`)
- advanced equations (trig, etc)
- functions
- Error handling
- Clean interface
## Automated installation (AUR) (Reccomended)
simply search Rmath in your preferred aur helper,for example, ``` yay -S rmath```
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
Then, restart your terminal
thats it! now you can run the 'rmath' command to launch the script

### Todo
- Custom coloring for different symbols
- solving for X
- fractions
- auto parenthesis closing
- more functions
