sudo modprobe nvme
sudo modprobe nvme-tcp
sudo nvme list
sudo nvme discover -t tcp -a 172.31.26.20 -s 4420
sudo nvme connect  -t tcp -n nvmet-test2 -a 172.31.26.20 -s 4420