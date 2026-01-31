Destroy()
{
    echo 'enter the name of zpool you want to destroy'
    read name
    zpool destroy $name
}