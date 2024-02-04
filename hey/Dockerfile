FROM golang:1.21.6-bookworm

RUN mkdir -p /src
WORKDIR /src
RUN git clone --depth 1 -b random_request_id https://github.com/hnakamur/hey
WORKDIR /src/hey
RUN go install -tags netgo ./...

WORKDIR /src
RUN bash -c 'for i in {1..64}; do for j in {0..15}; do printf %x $j >> hex-1KiB.dat; done; done'
