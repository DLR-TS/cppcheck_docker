# cpplint_docker

This is a project offering a minimal docker environment for static checking C++ source with cppcheck.

## Description 
With this project you can static check arbitrary C++ code with cppcheck. It does not require
complex configurations. Clone the project and point it to your source directory. 

## Getting started

This project requires make and docker installed and configured for your user.

1. Clone the project:
```bash
git clone git@gitlab.dlr.de:csa/cpplint.git
```
2. static check  a project using the provided make target:
```bash
make cppcheck CPP_PROJECT_DIRECTORY=$(realpath ./hello_world) 

Checking hello_world/hello_world.cpp ...
1/2 files checked 32% done
Checking hello_world/src/hello.cpp ...
hello_world/src/hello.cpp:6:4: error: Array 'a[10]' accessed at index 10, which is out of bounds. [arrayIndexOutOfBounds]
  a[10] = 0;
   ^
hello_world/src/hello.cpp:6:9: style: Variable 'a[10]' is assigned a value that is never used. [unreadVariable]
  a[10] = 0;
        ^
2/2 files checked 100% done
nofile:0:0: information: Cppcheck cannot find all the include files (use --check-config for details) [missingInclude]
```
