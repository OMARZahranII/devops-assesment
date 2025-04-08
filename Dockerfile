# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o bank-api .

# Runtime stage
FROM alpine:3.18

WORKDIR /app

# Install necessary runtime dependencies
RUN apk --no-cache add ca-certificates

# Copy the binary from the builder stage
COPY --from=builder /app/bank-api .
COPY --from=builder /app/config ./config

# Create a non-root user to run the application
RUN adduser -D -H -h /app appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["./bank-api"] 