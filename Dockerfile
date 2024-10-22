# ================================
# Build image
# ================================
FROM swift:6.0.1-jammy AS build

# Set up a build area
WORKDIR /build

# Install Static SDK
RUN swift sdk install https://download.swift.org/swift-6.0.1-release/static-sdk/swift-6.0.1-RELEASE/swift-6.0.1-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz --checksum d4f46ba40e11e697387468e18987ee622908bc350310d8af54eb5e17c2ff5481

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release --swift-sdk x86_64-swift-linux-musl

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp /build/.build/release/flyingfox ./

# Copy resource bundle to staging area
RUN cp -r /build/.build/release/FlyingFoxCLI_FlyingFoxCLI.resources ./

# ================================
# Run image
# ================================
FROM scratch

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build /staging /app

# Let Docker bind to port 8080
EXPOSE 8080

# Start the flyingfox service when the image is run, default to listening on 8080
ENTRYPOINT ["/app/flyingfox", "--port", "8080"]
