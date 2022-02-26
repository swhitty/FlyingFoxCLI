# ================================
# Build image
# ================================
FROM swift:5.5.2-focal as build

# Set up a build area
WORKDIR /build

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp /build/.build/release/flyingfox ./

# ================================
# Run image
# ================================
FROM swift:5.5-focal-slim

# Create a fox user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app fox

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=fox:fox /staging /app

# Ensure all further commands run as the fox user
USER fox:fox

# Let Docker bind to port 8080
EXPOSE 8080

# Start the FlyingFox service when the image is run, default to listening on 8080
ENTRYPOINT ["/app/flyingfox", "--port", "8080"]
