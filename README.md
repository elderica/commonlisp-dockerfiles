# Dockerfiles to use Common Lisp implementations and Quicklisp



## Supported implementation

* [Steel Bank Common Lisp](http://www.sbcl.org/) [![Docker Pulls](https://img.shields.io/docker/pulls/elderica/sbcl.svg)](https://hub.docker.com/r/elderica/sbcl/)

## Usage

From Docker Hub

```sh
$ docker run -it --rm elderica/sbcl:2.4.2
* (ql:client-version)
"2021-02-13"
```

Build your own image

You can specify implementation version!

```sh
$ cd sbcl
$ make SBCL_VERSION=2.4.0
```
