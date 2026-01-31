Discover () {
    read -p "Enter ip of storage server : " ip
    sudo modprobe nvme-tcp
    sudo nvme list
    sudo nvme discover -t tcp -a $ip -s 4420
}
Connect ()
{
    read -p "Enter ip of storage server : " ip
    sudo modprobe nvme-tcp
    sudo nvme list
    sudo nvme discover -t tcp -a $ip -s 4420 > dis.txt

    nqnLis=($(grep 'subnqn' dis.txt | awk -F" " '{print $2}'))
    #len=${#nqnLis[*]}
    #len_nqnLis=$((len-1))
    #for i in {0..$len_nqnLis}
    #for i in 0 1
    for (( i=0; i<${#nqnLis[@]}; i++ ));
    do
            echo "Do you want to connect "${nqnLis[i]}
            read -p "yes or no"' ' ans
            if [ $ans == 'yes' ]
            then
                    sudo nvme connect  -t tcp -n ${nqnLis[i]} -a $ip -s 4420
            elif [ $ans == 'no' ]
            then
                    continue
            else
                    echo 'enter valid input'
            fi
    done
}



echo 'connect nvme devices'
echo 'Choose one of the following action'
echo '1.Discover'
echo '1.Connect'


read no

case $no in
    1) echo '1.discover'
            Discover
    ;;
    2) echo '2.connect'
            Connect
    ;;
esac