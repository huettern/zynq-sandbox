# Build instructions

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

# Toolchain setup

## Mac OSX
### Install ghdl

```bash
wget https://github.com/ghdl/ghdl/releases/download/v0.35/ghdl-0.35-llvm-macosx.tgz
mkdir ghdl && cd ghdl
tar xvzf ../ghdl-0.35-llvm-macosx.tgz
cp -r include/* /usr/local/include/
cp -r bin/* /usr/local/bin/
cp -r lib/* /usr/local/lib/
ghdl --version
```

### Install gtkwave
Download from [here](https://sourceforge.net/projects/gtkwave/files/gtkwave-3.3.95-osx-app/gtkwave.zip/download)

### Install vivado docker
Follow instructions [here](https://github.com/noah95/vivado-docker)
