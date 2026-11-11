# Lab 1 · GPU fundamentals
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Install the NVIDIA driver (R580 long-term branch)
# on Ubuntu 22.04, change ubuntu2404 to ubuntu2204 in this URL
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install -y nvidia-open-580
sudo reboot
# after reconnecting:
nvidia-smi

# alternative using Ubuntu's own packages:
#   sudo ubuntu-drivers list --gpgpu ; sudo ubuntu-drivers install --gpgpu nvidia:580-server

# --- Explore the GPU
nvidia-smi
nvidia-smi -q -d MEMORY,POWER,CLOCK,ECC | less
nvidia-smi --query-gpu=name,memory.total,memory.used,utilization.gpu,power.draw,temperature.gpu \
           --format=csv -l 2              # live, every 2 s; Ctrl+C to stop
nvidia-smi --query-gpu=pcie.link.gen.max,pcie.link.width.max --format=csv   # PCIe (idles at Gen 1)
nvidia-smi topo -m                        # interconnect topology (PCIe or NVLink)
nvidia-smi -q | grep -i -A2 mig            # MIG mode (Lab 12)

# --- Install and test the container toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit   # 1.20.x in Oct 2026
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
docker run --rm --gpus all nvidia/cuda:13.0.3-base-ubuntu24.04 nvidia-smi

# --- DCGM: what fleet monitoring uses
# DCGM 4 from NVIDIA's CUDA repository (added above); package matches the CUDA major version
CUDA_VERSION=$(nvidia-smi -q | sed -E -n 's/CUDA Version[ :]+([0-9]+)[.].*/\1/p')
sudo apt-get install -y --install-recommends datacenter-gpu-manager-4-cuda${CUDA_VERSION}
sudo systemctl enable --now nvidia-dcgm
dcgmi discovery -l          # list GPUs
dcgmi diag -r 1             # quick health check (seconds)
dcgmi diag -r 2             # longer check (minutes)
dcgmi dmon -e 203,252,155,150 -d 1000   # utilisation, memory used, power, temperature
