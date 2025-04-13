# Use the official Rust image to build the backend
FROM rust:1.64 as builder

# Set the working directory
WORKDIR /app

# Copy the Cargo.toml and Cargo.lock files to the container
COPY Cargo.toml Cargo.lock ./

# Download dependencies (to cache dependencies layer)
RUN cargo fetch

# Copy the rest of the code
COPY . .

# Build the project (release mode)
RUN cargo build --release

# The final image will be based on the official Debian image
FROM debian:bullseye-slim

# Install required libraries
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled Rust binary from the builder stage
COPY --from=builder /app/target/release/backend_backup /usr/local/bin/

# Set the working directory
WORKDIR /usr/local/bin

# Set environment variables (replace with your actual .env variables)
ENV DATABASE_URL=postgresql://postgres:psql@localhost:5432/file_share_tutorial
ENV JWT_SECRET_KEY=b06401cc634e3695e1aca5f08002377d948e937d3a4dd4772e4e8c5d5f58b8a2
ENV JWT_MAXAGE=60

# Run the server
CMD ["./backend_backup"]
