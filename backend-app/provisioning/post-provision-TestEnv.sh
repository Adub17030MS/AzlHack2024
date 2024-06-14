set -ex

# Install packages.
sudo apt update
sudo apt install -y qemu qemu-kvm qemu-utils libvirt-daemon-system libvirt-dev ovmf \
    libgirepository1.0-dev python3-venv python3-dev openssh-client ncat unzip libcairo2-dev
sudo systemctl enable --now libvirtd

# Install poetry.
curl -sSL https://install.python-poetry.org | python3 -

# Install helm.
# Note: HelmInstaller task is not used as it doesn't place the executable in a common location
# which can cause problems for the LISA tests.
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
DESIRED_VERSION=v3.11.0 ./get_helm.sh

curl -sSL https://github.com/kubevirt/kubevirt/releases/download/v0.59.0/virtctl-v0.59.0-linux-amd64 -o ./virtctl
chmod +x virtctl
sudo mv virtctl /usr/local/bin/


# Add poetry to PATH.
export PATH="$HOME/.local/bin:$PATH"

# Install and configure Docker.
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
