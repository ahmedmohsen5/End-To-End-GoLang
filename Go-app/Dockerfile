FROM golang:1.21-alpine3.18

WORKDIR /app
COPY . .

RUN go mad download && \
    go mod verify && \ 
    go build -o survey .

CMD [ "./survey" ]
EXPOSE 8080
