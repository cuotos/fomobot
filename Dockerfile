# Pin the builder to the machine doing the building, so a linux/arm64 target
# cross-compiles natively instead of running the compiler under emulation.
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
# Set by buildx from the --platform being built.
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -tags lambda.norpc -mod=readonly -o /fomobot .


FROM public.ecr.aws/lambda/provided:al2

COPY --from=builder /fomobot ./main

ENTRYPOINT [ "./main" ]
