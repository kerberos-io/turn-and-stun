FROM golang:1.13.0-stretch AS builder

ARG gitlab_id
ARG gitlab_token

WORKDIR /build

# Copy the code necessary to build the application
# You may want to change this to copy only what you actually need.
COPY . .

# Get local dependencies from private Kerberos.io repo.
RUN git config --global \
    url."https://${gitlab_id}:${gitlab_token}@gitlab.com/".insteadOf \
    "https://gitlab.com/"

# Let's cache modules retrieval - those don't change so often
RUN go mod download

# Build the application
RUN go build main.go

# Let's create a /dist folder containing just the files necessary for runtime.
# Later, it will be copied as the / (root) of the output image.
WORKDIR /dist
RUN cp /build/main ./main

# Optional: in case your application uses dynamic linking (often the case with CGO),
# this will collect dependent libraries so they're later copied to the final image
# NOTE: make sure you honor the license terms of the libraries you copy and distribute
RUN ldd main | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname ./%); cp % ./%;'
RUN mkdir -p lib64 && cp /lib64/ld-linux-x86-64.so.2 lib64/

# Copy or create other directories/files your app needs during runtime.
# E.g. this example uses /data as a working directory that would probably
#      be bound to a perstistent dir when running the container normally
RUN mkdir /data

FROM golang:1.13.0-stretch

COPY --chown=0:0 --from=builder /dist /

# Set up the app to run as a non-root user inside the /data folder
# User ID 65534 is usually user 'nobody'.
# The executor of this image should still specify a user during setup.
COPY --chown=65534:0 --from=builder /data /data
USER 65534
WORKDIR /data

ENTRYPOINT ["/main"]
