
set -e

echo "Running postinstall.sh"

sudo apt-get update -y

# Install required dependencies.
# Recommended but not required: `pigz` for faster compression operations.
sudo apt -y install \
    acl \
    curl \
    gawk \
    genisoimage \
    git \
    golang-1.20-go \
    make \
    parted \
    pigz \
    openssl \
    qemu-utils \
    rpm \
    tar \
    wget \
    xfsprogs

# Fix go 1.20 link
sudo ln -vsf /usr/lib/go-1.20/bin/go /usr/bin/go
sudo ln -vsf /usr/lib/go-1.20/bin/gofmt /usr/bin/gofmt

# Install and configure Docker.
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
