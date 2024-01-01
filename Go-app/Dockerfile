FROM golang:1.7-alpine3.14

WORKDIR /app
COPY . .

RUN go mad download && \
    go mod verify && \ 
    go build -o survey .

CMD [ "./survey" ]
EXPOSE 8080
