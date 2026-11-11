# Lab 12 · Partition a GPU with MIG
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Create and inspect MIG instances (profile names shown are for an 80 GB A100/H100)
sudo nvidia-smi -i 0 -mig 1          # enable MIG mode (may need a GPU reset or reboot)
nvidia-smi -i 0 --query-gpu=mig.mode.current --format=csv
sudo nvidia-smi mig -lgip            # list GPU instance profiles and how many fit
# create three 1g slices and one 3g slice (profile IDs come from the -lgip output)
sudo nvidia-smi mig -cgi 1g.10gb,1g.10gb,1g.10gb,3g.40gb -C
nvidia-smi -L                        # each MIG device has its own UUID
sudo nvidia-smi mig -dci && sudo nvidia-smi mig -dgi   # destroy the slices
sudo nvidia-smi -i 0 -mig 0          # MIG off (may need a GPU reset or reboot)

# --- Let the GPU Operator's MIG manager configure the GPU
# single is the default strategy; for mixed:
helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator --reuse-values --set mig.strategy=mixed
kubectl label node <node> nvidia.com/mig.config=all-1g.10gb --overwrite
kubectl get node <node> -L nvidia.com/mig.config.state -w   # pending -> rebooting -> success
kubectl get node <node> -o json | jq '.status.allocatable'   # several nvidia.com/gpu (single strategy)
# a pod then requests one slice:  resources: {limits: {nvidia.com/gpu: 1}}
# with mig.strategy=mixed the resource is named nvidia.com/mig-1g.10gb instead
kubectl label node <node> nvidia.com/mig.config=all-disabled --overwrite   # MIG off; allocatable may read 0 briefly
