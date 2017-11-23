FROM golang:1.9 as bench
RUN mkdir -p /go/src/github.com/estesp && cd /go/src/github.com/estesp && git clone https://github.com/estesp/bucketbench.git
WORKDIR /go/src/github.com/estesp/bucketbench
RUN go build
COPY bench.yaml /bench.yaml
ENTRYPOINT ["./bucketbench", "run", "--benchmark=/bench.yaml"]

FROM golang:1.9 as c8d
ARG CONTAINERD_REPO=https://github.com/containerd/containerd.git
ARG CONTAINERD_BRANCH=master
ARG CONTAINERD_COMMIT=v1.0.0-beta.3
#RUN eval $(go env); curl -SLf https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}.${GOOS}-${GOARCH}.tar.gz | tar -zx -C /usr/local
RUN mkdir -p /go/src/github.com/containerd/ \
	&& cd /go/src/github.com/containerd \
	&& git clone -b $CONTAINERD_BRANCH $CONTAINERD_REPO containerd \
	&& cd containerd \
	&& git checkout $CONTAINERD_COMMIT \
	&& make BUILDTAGS=no_btrfs && make install

FROM golang:1.9 as cri
ARG CNI_VERSION=0.6.0
RUN go get github.com/opencontainers/runc
RUN mkdir -p /opt/cni/bin && curl -sSLf https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-amd64-v${CNI_VERSION}.tgz | tar -zx -C /opt/cni/bin
RUN apt-get update && apt-get install -y socat iptables
RUN mkdir -p /go/src/github.com/kubernetes-incubator
ARG CRI_CONTAINERD_REPO=https://github.com/kubernetes-incubator/cri-containerd.git
ARG CRI_CONTAINERD_COMMIT=HEAD
ARG CRI_CONTAINERD_BRANCH=master
RUN cd /go/src/github.com/kubernetes-incubator && git clone -b $CRI_CONTAINERD_BRANCH $CRI_CONTAINERD_REPO && cd cri-containerd && git checkout $CRI_CONTAINERD_COMMIT
WORKDIR  /go/src/github.com/kubernetes-incubator/cri-containerd
RUN make BUILD_TAGS="" && make install
RUN mkdir -p /etc/cni/net.d
COPY 10-containerd-net.conflist /etc/cni/net.d/
COPY cri-c8d-run.sh /
COPY --from=c8d /go/src/github.com/containerd/containerd/bin/* /usr/local/bin/
ENTRYPOINT ["/cri-c8d-run.sh", "--profiling", "--profiling-addr=127.0.0.1", "--profiling-port=8080"]
