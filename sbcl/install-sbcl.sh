#!/bin/sh

set -u -e

VERSION="${1}" # SBCL version to install
MODE="${2}"    # binary or source

SBCL_SIGNING_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD

import_key() {
    if type gpg >/dev/null 2>&1
    then
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${SBCL_SIGNING_KEY}
    else
        echo 'Install gpg first'
        exit 1
    fi
}

download() {
    file="${1}"
    url="${2}"

    if type wget >/dev/null 2>&1
    then
        wget -O "${file}" "${url}"
    elif type curl >/dev/null 2>&1
    then
        curl -Lo "${file}" "${url}"
    else
        echo 'Install wget or curl'
        exit 1
    fi
}

ASC_URL="https://downloads.sourceforge.net/project/sbcl/sbcl/${VERSION}/sbcl-${VERSION}-crhodes.asc"
ASC_FILE="sbcl-${VERSION}-crhodes.asc"
CHECKSUM="sbcl-${VERSION}-crhodes.txt"

LINUX_BINARY_URL="https://downloads.sourceforge.net/project/sbcl/sbcl/${VERSION}/sbcl-${VERSION}-x86-64-linux-binary.tar.bz2"
LINUX_BINARY_TARBZ2="sbcl-${VERSION}-x86-64-linux-binary.tar.bz2"
LINUX_BINARY_TAR="${LINUX_BINARY_TARBZ2%.bz2}"

SOURCE_URL="https://downloads.sourceforge.net/project/sbcl/sbcl/${VERSION}/sbcl-${VERSION}-source.tar.bz2"
SOURCE_TARBZ2="sbcl-${VERSION}-source.tar.bz2"
SOURCE_TAR="${SOURCE_TARBZ2%.bz2}"

download_and_decrypt_checksum() {
    download "${ASC_FILE}" "${ASC_URL}"
    gpg --batch --verify "${ASC_FILE}"
    gpg --decrypt "${ASC_FILE}" | grep -E '\.tar$' > "${CHECKSUM}"
    rm "${ASC_FILE}"
}

download_and_decompress_linux_binary(){
    download "${LINUX_BINARY_TARBZ2}" "${LINUX_BINARY_URL}"
    bunzip2 -f "${LINUX_BINARY_TARBZ2}"
    grep "${LINUX_BINARY_TAR}" "${CHECKSUM}" | sha256sum -c -
}

download_and_decompress_source(){
    download "${SOURCE_TARBZ2}" "${SOURCE_URL}"
    bunzip2 -f "${SOURCE_TARBZ2}"
    grep "${SOURCE_TAR}" "${CHECKSUM}" | sha256sum -c -
}

install_linux_binary(){
    tar xf "${LINUX_BINARY_TAR}"
    rm "${LINUX_BINARY_TAR}"

    cd "${LINUX_BINARY_TAR%-binary.tar}"

    sh install.sh

    cd ..
    rm -r "${LINUX_BINARY_TAR%-binary.tar}"
}

build_and_install_source() {
    tar xf "${LINUX_BINARY_TAR}"
    rm "${LINUX_BINARY_TAR}"

    tar xf "${SOURCE_TAR}"
    rm "${SOURCE_TAR}"

    cd "sbcl-${VERSION}"

    xchost="/${LINUX_BINARY_TAR%-binary.tar}/run-sbcl.sh"
    sh make.sh --fancy --xc-host="${xchost}"
    sh install.sh

    cd ..
    rm -r "${LINUX_BINARY_TAR%-binary.tar}"
    rm -r "sbcl-${VERSION}"
}

cleanup() {
    cd /
    rm "sbcl-${VERSION}-crhodes.txt" \
       "install-sbcl.sh"
}

import_key
download_and_decrypt_checksum
download_and_decompress_linux_binary

case "${MODE}" in
     binary)
            install_linux_binary
            ;;
     source)
            download_and_decompress_source
            build_and_install_source
            ;;
esac
cleanup
