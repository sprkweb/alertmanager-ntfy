FROM golang:1.19-alpine AS build

WORKDIR /src

RUN apk add --no-cache ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/alertmanager-ntfy ./main.go

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /out/alertmanager-ntfy /alertmanager-ntfy

USER 65532:65532

ENV HTTP_ADDRESS=0.0.0.0
ENV HTTP_PORT=8080

EXPOSE 8080

ENTRYPOINT ["/alertmanager-ntfy"]
