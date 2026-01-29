sudo modprobe nvme
sudo modprobe nvme-tcp
sudo nvme list
sudo nvme discover -t tcp -a 192.168.10.18-s 4420
sudo nvme connect  -t tcp -n nvmet-test1 -a 192.168.10.16 -s 4420
sudo nvme discover -t tcp -a 192.168.10.18 -s 4420
sudo nvme connect  -t tcp -n nvmet-test2 -a 192.168.10.16 -s 4420