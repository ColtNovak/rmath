# Rust  Calculator
A  terminal calculator written in Rust with real time calculating.
### NEW UPDATE!
  - added advanced equations

## Features

- Real-time mathematical evaluation
- Support for basic operations (`+`, `-`, `*`, `/`)
- advanced equations (trig, etc)
- Error handling
- Clean interface

### Steps
1. Clone the repository:
```
git clone https://github.com/your-username/RustCalc.git
cd RustCalc
```
2. build the repo
```
cargo build --release
```
3. check
```
ls target/release/
```
4. move the files
```
mv target/release/rmath ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
```
5. restart terminal
6. run the project!
```
rmath
```
