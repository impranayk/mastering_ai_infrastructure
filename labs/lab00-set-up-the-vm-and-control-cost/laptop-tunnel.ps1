ssh -i $HOME\.ssh\gpu-lab -N `
  -L 8000:localhost:8000 -L 3000:localhost:3000 `
  -L 9090:localhost:9090 -L 4000:localhost:4000 `
  ubuntu@<vm-ip>

# copy files from the VM to the current folder (used at the end of each session)
scp -i $HOME\.ssh\gpu-lab "ubuntu@<vm-ip>:~/lab-logs/*" .
