FROM alpine:3.18

# Build arguments
ARG RELEASE

# Install packages
RUN apk --no-cache upgrade && apk --no-cache add curl~=$RELEASE

# Run by default as nobody
USER nobody

# Define entrypoint
ENTRYPOINT [ "/bin/sh" ]
