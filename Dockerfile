FROM golang:1.15 as builder
WORKDIR /go/src/github.td.teradata.com/jupyter/jupyterhub-istio-proxy
COPY . /go/src/github.td.teradata.com/jupyter/jupyterhub-istio-proxy
RUN rm -rf vendor
RUN GOOS=linux CGO_ENABLED=0 go build --installsuffix cgo --ldflags=-s -o jupyterhub-istio-proxy .
	
	
FROM gcr.io/distroless/static-debian10:nonroot
COPY --from=builder /go/src/github.td.teradata.com/jupyter/jupyterhub-istio-proxy/jupyterhub-istio-proxy /proxy/jupyterhub-istio-proxy
ENTRYPOINT ["/proxy/jupyterhub-istio-proxy"]
CMD [ "/proxy/jupyterhub-istio-proxy" ]
