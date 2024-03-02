FROM buildpack-deps:bookworm AS buildenv
SHELL ["/bin/bash", "-c", "-e", "-u", "-o", "pipefail"]

ARG SBCL_VERSION

ARG SBCL_SIGNING_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD
ADD https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-crhodes.asc crhodes.asc

RUN <<EOT
gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$SBCL_SIGNING_KEY"
gpg --batch --verify crhodes.asc
gpg --batch --decrypt crhodes.asc | grep -E '\.tar$' | tee SHA256SUM
EOT

ARG QUICKLISP_SHA256=4a7a5c2aebe0716417047854267397e24a44d0cce096127411e9ce9ccfeb2c17
#ADD --checksum=sha256:$QUICKLISP_SHA256 https://beta.quicklisp.org/quicklisp.lisp quicklisp.lisp
ADD https://beta.quicklisp.org/quicklisp.lisp quicklisp.lisp

ARG LINUX_BINARY=sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2
ADD https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2 $LINUX_BINARY

RUN <<EOT
bunzip2 "$LINUX_BINARY"
grep "${LINUX_BINARY%.bz2}" SHA256SUM | sha256sum -
tar xf "${LINUX_BINARY%.bz2}"
EOT

FROM buildenv AS install-from-binary
SHELL ["/bin/bash", "-c", "-e", "-u", "-o", "pipefail"]
WORKDIR /sbcl-${SBCL_VERSION}-x86-64-linux
RUN sh install.sh


FROM buildenv AS install-from-source
SHELL ["/bin/bash", "-c", "-e", "-u", "-o", "pipefail"]

ARG SOURCE=sbcl-${SBCL_VERSION}-source.tar.bz2
ADD https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2 $SOURCE

RUN <<EOT
bunzip2 "$SOURCE"
grep "${SOURCE%.bz2}" SHA256SUM | sha256sum -c -
tar xf "${SOURCE%.bz2}"
EOT

WORKDIR /sbcl-${SBCL_VERSION}
RUN <<EOT
apt-get update && apt-get install -y --no-install-recommends libzstd-dev
sh make.sh --fancy --xc-host="/sbcl-${SBCL_VERSION}-x86-64-linux/run-sbcl.sh"
sh install.sh
EOT

FROM debian:bookworm AS runtime-binary
SHELL ["/bin/bash", "-c", "-e", "-u", "-o", "pipefail"]

COPY --from=install-from-binary /usr/local /usr/local
COPY --from=install-from-binary /quicklisp.lisp /quicklisp.lisp
RUN <<EOT
/usr/local/bin/sbcl \
    --non-interactive \
    --load quicklisp.lisp \
    --eval '(quicklisp-quickstart:install)' \
    --eval '(ql-util:without-prompting (ql:add-to-init-file))' \
    --eval '(uiop:quit)'
rm quicklisp.lisp
EOT

ENTRYPOINT ["/usr/local/bin/sbcl"]


FROM debian:bookworm AS runtime-source
SHELL ["/bin/bash", "-c", "-e", "-u", "-o", "pipefail"]

COPY --from=install-from-source /usr/local /usr/local
COPY --from=install-from-source /quicklisp.lisp /quicklisp.lisp
RUN <<EOT
/usr/local/bin/sbcl \
    --non-interactive \
    --load quicklisp.lisp \
    --eval '(quicklisp-quickstart:install)' \
    --eval '(ql-util:without-prompting (ql:add-to-init-file))' \
    --eval '(uiop:quit)'
rm quicklisp.lisp
EOT

ENTRYPOINT ["/usr/local/bin/sbcl"]
