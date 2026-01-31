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
    rm -rf dis.txt
}



Create(){

    
    lsblk | grep 'disk' > disk.txt
    diskLis=($(grep 'nvme' disk.txt | awk -F"       " '{print $1}'))
    


    echo 'enter name of zpool you want to create'
    read name
    echo 'for zpool which raid do you want to use'
    echo '1.RAID0           (minimum 1 SSD needed)'
    echo '2.RAID1[MIRROR]   (minimum 2 SSD needed)'
    echo '3.RAIDZ           (minimum 2 SSD needed)'
    echo '4.RAIDZ2          (minimum 4 SSD needed)'

    read no
    case $no in 
    1) echo '1.RAID0'
        repli='' 
        echo 'enter the number of SSD to be used in zpool'
        read number_of_main_SSD
        
        for (( i=0; i<$number_of_main_SSD; i++ ));
        do
            x=$(($i+1))
            echo 'select the number'$x' SSD for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            if [ $i == 0 ];
            then
                cmd='zpool create -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}
            else
                cmd+=' /dev/'${diskLis[$main_ssd]}
            fi
        done
        $cmd

    ;;
    2) echo '2.RAID1 (mirror)'
        repli='mirror'
        echo 'enter the number of mirrors you want to create in pool'
        read number_of_mirror
        for (( i=0; i<$number_of_mirror; i++ ));
        do
            x=$(($i+1))
            echo 'select the main SSD first amd then the backup for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            read back_ssd
            if [ $i == 0 ];
            then
                cmd='zpool create -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            else
                cmd+=' '$repli'/dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            fi

        done
        $cmd
        
    ;;
    3) echo '3.RAIDZ'
        repli=raidz
        echo 'enter the number of raidz pairs you want to create in pool'
        read number_of_mirror
        for (( i=0; i<$number_of_mirror; i++ ));
        do
            x=$(($i+1))
            echo 'select the main SSD first and then the second for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            read back_ssd
            if [ $i == 0 ];
            then
                cmd='zpool create -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            else
                cmd+=' '$repli'/dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            fi

        done 
        $cmd       
        
    ;;
    4) echo '4.RAIDZ2'
        repli=raidz2
        echo 'enter the number of raidz pairs you want to create in pool'
        read number_of_mirror
        for (( i=0; i<$number_of_mirror; i++ ));
        do
            x=$(($i+1))
            echo 'select the first second third SSD in sequence for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            read second_ssd
            read third_ssd
            read fourth_ssd
            if [ $i == 0 ];
            then
                cmd='zpool create -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$second_ssd]}' /dev/'${diskLis[$third_ssd]}' /dev/'${diskLis[$fourth_ssd]}
            else
                cmd+=' '$repli'/dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$second_ssd]}' /dev/'${diskLis[$third_ssd]}' /dev/'${diskLis[$third_ssd]}' /dev/'${diskLis[$fourth_ssd]}
            fi

        done
        $cmd
    ;;
    esac
    rm -rf disk.txt
}

Destroy()
{
    echo 'enter the name of zpool you want to destroy'
    read name
    zpool destroy $name
}

Replace()
{
    echo 'check for the SSD to be replaced'
    echo ''
    Status

    lsblk | grep 'disk' > disk.txt
    diskLis=($(grep 'nvme' disk.txt | awk -F"       " '{print $1}'))

    echo 'Enter the name of pool you want to replace SSD from'
    read pool

    device_no=$(zpool status $pool | grep 'UNAVAIL' | awk -F" " '{print $1}')

    echo 'Enter the name of pool you want to replace SSD from'
    read pool

    echo 'select the SSD you want to replace (New device in pool)'
    declare -p diskLis
    read new_device

    cmd='zpool replace -f '$pool' '$device_no' /dev/'${diskLis[$new_device]}
    $cmd

    rm -rf disk.txt
    echo 'if you face error detach and attach the SSD from zpool'    
}

Clear()
{
    echo 'enter the name of zpool you want to clear'
    read name
    zpool clear $name   
}

Attach()
{
    lsblk | grep 'disk' > disk.txt
    diskLis=($(grep 'nvme' disk.txt | awk -F"       " '{print $1}'))

    echo 'Enter the name of pool you want to attach SSD to'
    read pool
    
    echo 'select the ssd you want to attach to (Existing device in pool)'
    declare -p diskLis
    read device

    echo 'select the SSD you want to attach (New device in pool)'
    declare -p diskLis
    read new_device

    cmd='zpool attach -f '$pool' /dev/'${diskLis[$device]}' /dev/'${diskLis[$new_device]}
    $cmd
    rm -rf disk.txt
}

Detach()
{
    lsblk | grep 'disk' > disk.txt
    diskLis=($(grep 'nvme' disk.txt | awk -F"       " '{print $1}'))
    Status
    echo 'Enter the name of pool you want to detach SSD from'
    read pool
    
    echo 'select the ssd you want to detach (Existing device in pool)'
    declare -p diskLis
    read device

    cmd='zpool	detach'$pool' /dev/'${diskLis[$device]}
    rm -rf disk.txt
}

Add(){

    
    lsblk | grep 'disk' > disk.txt
    diskLis=($(grep 'nvme' disk.txt | awk -F"       " '{print $1}'))
    


    echo 'enter name of zpool you want to add SSD to'
    read name
    echo 'for zpool which raid do you want to use'
    echo '1.RAID0           (minimum 1 SSD needed)'
    echo '2.RAID1[MIRROR]   (minimum 2 SSD needed)'
    echo '3.RAIDZ           (minimum 2 SSD needed)'
    echo '4.RAIDZ2          (minimum 4 SSD needed)'

    read no
    case $no in 
    1) echo '1.RAID0'
        repli='' 
        echo 'enter the number of SSD to be added in zpool'
        read number_of_main_SSD
        
        for (( i=0; i<$number_of_main_SSD; i++ ));
        do
            x=$(($i+1))
            echo 'select the number'$x' SSD for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            if [ $i == 0 ];
            then
                cmd='zpool add -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}
            else
                cmd+=' /dev/'${diskLis[$main_ssd]}
            fi
        done
        $cmd

    ;;
    2) echo '2.RAID1 (mirror)'
        repli='mirror'
        echo 'enter the number of mirrors you want to add in pool'
        read number_of_mirror
        for (( i=0; i<$number_of_mirror; i++ ));
        do
            x=$(($i+1))
            echo 'select the main SSD first amd then the backup for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            read back_ssd
            if [ $i == 0 ];
            then
                cmd='zpool add -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            else
                cmd+=' '$repli'/dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            fi

        done
        $cmd
        
    ;;
    3) echo '3.RAIDZ'
        repli=raidz
        echo 'enter the number of raidz pairs you want to add in pool'
        read number_of_mirror
        for (( i=0; i<$number_of_mirror; i++ ));
        do
            x=$(($i+1))
            echo 'select the main SSD first and then the second for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            read back_ssd
            if [ $i == 0 ];
            then
                cmd='zpool add -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            else
                cmd+=' '$repli'/dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$back_ssd]}
            fi

        done 
        $cmd       
        
    ;;
    4) echo '4.RAIDZ2'
        repli=raidz2
        echo 'enter the number of raidz pairs you want to add in pool'
        read number_of_mirror
        for (( i=0; i<$number_of_mirror; i++ ));
        do
            x=$(($i+1))
            echo 'select the first second third SSD in sequence for the zpool from the given list and give the index accordingly(do not select a used SSD)'
            declare -p diskLis
            read main_ssd
            read second_ssd
            read third_ssd
            read fourth_ssd
            if [ $i == 0 ];
            then
                cmd='zpool add -f '$name' '$repli' /dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$second_ssd]}' /dev/'${diskLis[$third_ssd]}' /dev/'${diskLis[$fourth_ssd]}
            else
                cmd+=' '$repli'/dev/'${diskLis[$main_ssd]}' /dev/'${diskLis[$second_ssd]}' /dev/'${diskLis[$third_ssd]}' /dev/'${diskLis[$third_ssd]}' /dev/'${diskLis[$fourth_ssd]}
            fi

        done
        $cmd
    ;;
    esac
    rm -rf disk.txt
}

List()
{
    zpool list
}

Status()
{
    zpool status
}

Import()
{
    zpool import
    echo ''
    echo 'look for the pools that are available to import from the connected devices'
    echo 'enter the name of the pool you want to import'
    read pool_name
    cmd='zpool import '$pool_name
    $cmd
}



echo 'connect nvme devices'
echo 'Choose one of the following action'
echo '1.Discover'
echo '2.Connect'
echo '3.exit'


read no

case $no in
    1) echo '1.discover'
            Discover
    ;;
    2) echo '2.connect'
            Connect
    ;;
    3) echo 'going to ZPOOL management'
        echo ''
    ;;
esac

echo 'ZFS/ZPOOL management tool'
echo 'select one of the following actions:'
echo '1.create' #done
echo '2.destroy' #done
echo '3.replace' #done
echo '4.clear' #done
echo '5.attach' #done
echo '6.detach' #done
echo '7.add' 
echo '8.list' #done
echo '9.status' #done
echo '10.import' #done
echo '11.exit' #done


case $no in
   1) echo '1.create'
        Create
   ;;
   2) echo '2.destroy'
        Destroy
   ;;
   3) echo '3.replace' 
        Replace
   ;;
   4) echo '4.clear'
        Clear
   ;;
   5) echo '5.attach'
        Attach
   ;;
   6) echo '6.detach'
        Detach
   ;;
   7) echo '7.add'
        Add
   ;;
   8) echo '8.list' 
        List
   ;;
   9) echo '9.status'
        Status
   ;;      
   10) echo 'import' 
        Import   
   ;;
   11) echo 'thanks for using this'
esac

