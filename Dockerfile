# First stage of Dockerfile
# Point to fixed 3.20.3 as 3.21.0 has issues compiling GCC
FROM alpine:3.20.3

ENV PS2DEV /usr/local/ps2dev
ENV PATH   $PATH:${PS2DEV}/ee/bin

COPY . /src

RUN apk add build-base bash gcc git make flex bison texinfo gmp-dev mpfr-dev mpc1-dev
RUN cd /src && ./toolchain.sh

# Second stage of Dockerfile
FROM alpine:latest

ENV PS2DEV /usr/local/ps2dev
ENV PATH   $PATH:${PS2DEV}/ee/bin

COPY --from=0 ${PS2DEV} ${PS2DEV}
