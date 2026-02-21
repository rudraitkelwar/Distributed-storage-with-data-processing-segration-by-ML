sudo modprobe nvme
sudo modprobe nvme-tcp
sudo nvme list
sudo nvme discover -t tcp -a 172.31.17.172 -s 4420
sudo nvme connect  -t tcp -n nvmet-test1 -a 172.31.17.172 -s 4420
