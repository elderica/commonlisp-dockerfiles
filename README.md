# Dockerfiles to use Common Lisp implementations and Quicklisp

## Supported implementation

* [Steel Bank Common Lisp](http://www.sbcl.org/)

## Usage

From Docker Hub

```sh
$ docker run -it --rm elderica/sbcl:2.4.1-binary
* (ql:client-version)
"2021-02-13"
```

Build your own image

```sh
$ cd sbcl
$ make binary
```
