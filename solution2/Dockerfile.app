FROM golang:1.16

WORKDIR /app

COPY main.go go.mod ./

RUN go build -o app

ENV BIND_ADDRESS=:8080

EXPOSE 8080

ENTRYPOINT ["./app"]

CMD ["$BIND_ADDRESS"]