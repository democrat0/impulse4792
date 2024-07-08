#!/bin/bash
read -p '请输入导出路径，即nginx-plex的映射路径（群晖需要先创建文件夹）: ' exportPath
read -p '请输入plex地址，按括号格式内格式输入（http://127.0.0.1:32400）: ' plexHost
read -p '请输入CloudDrive2挂载目录，按括号格式内格式输入（"/CloudDrive/CloudDrive"）: ' plexMountPath
read -p '请输入alist地址，按括号格式内格式输入（http://127.0.0.1:5244）: ' alistAddr
read -p '请输入alist Token，按括号格式内格式输入（alist-Token）: ' alistToken
read -p '请输入alist外网地址，按括号格式内格式输入（https://abc.com:443）: ' alistPublicAddr
mkdir -p "$exportPath"
docker pull mnookey/nginx-plex:latest
docker run -d --name nginx-plex-rm mnookey/nginx-plex
docker cp nginx-plex-rm:/etc/nginx/conf.d/constant.js "$exportPath/constant.js"
docker cp nginx-plex-rm:/etc/nginx/conf.d/config/constant-mount.js "$exportPath/constant-mount.js"
docker rm -f nginx-plex-rm

if [ -f "$exportPath/constant.js" ]; then

    sed -i "s|http://172.17.0.1:32400|$plexHost|g" "$exportPath/constant.js"
    sed -i "s|\"/mnt\"|$plexMountPath|g" "$exportPath/constant.js"
    echo "constant.js 文件已更新"
else
    echo "constant.js 文件不存在"
fi

if [ -f "$exportPath/constant-mount.js" ]; then

    sed -i "s|http://172.17.0.1:5244|$alistAddr|g" "$exportPath/constant-mount.js"
    sed -i "s|alsit-123456|$alistToken|g" "$exportPath/constant-mount.js"
    sed -i "s|http://youralist.com:5244|$alistPublicAddr|g" "$exportPath/constant-mount.js"
    echo "constant-mount.js 文件已更新"
else
    echo "constant-mount.js 文件不存在"
fi
