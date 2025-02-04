# Calling zig code from python.

This example demonstrates how to create a shared library in Zig and then use it in python.

The project is just a simple demo.

### Check zig installation

```
$ zig build run
a secret message
```

You should see an output message: `a secret message`.

### Build a library

```
zig build-lib -dynamic -O ReleaseFast src/main.zig
```

This will create a `libmain.so`.

### Prepare python environment

```
bash bootstrap.sh
```

This step will create a virtualenv and install deps.

### Run python code

```
$ python main.py
a secret message
```
