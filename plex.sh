#!/bin/bash

# 获取用户输入
read -p '请输入导出路径，即nginx-plex的映射路径（群晖需要先创建文件夹）: ' exportPath
read -p '请输入plex地址，按括号格式内格式输入（http://127.0.0.1:32400）: ' plexHost
read -p '请输入CloudDrive2挂载目录，按括号格式内格式输入（"/CloudDrive/CloudDrive"）: ' plexMountPath
read -p '请输入alist地址，按括号格式内格式输入（http://127.0.0.1:5244）: ' alistAddr
read -p '请输入alist Token，按括号格式内格式输入（alist-Token）: ' alistToken
read -p '请输入alist外网地址，按括号格式内格式输入（https://abc.com:443）: ' alistPublicAddr
read -p '请输入alist是否启用了sign签名，按括号格式内格式输入（默认false）: ' alistSignEnable
read -p '请输入alist缓存时间，按括号格式内格式输入（默认12小时）: ' alistSignExpireTime
# 询问是否更改端口
read -p '是否更改端口? (y/n): ' changePort

if [[ "$changePort" =~ ^[Yy]$ ]]; then
    read -p '请输入新的端口号: ' newPort
fi
# 创建导出路径目录（如果不存在）
mkdir -p "$exportPath"

# 启动Docker容器并导出文件
docker pull mnookey/nginx-plex:latest
docker run -d --name nginx-plex-rm mnookey/nginx-plex:latest
docker cp nginx-plex-rm:/etc/nginx/conf.d/constant.js "$exportPath/constant.js"
docker cp nginx-plex-rm:/etc/nginx/conf.d/config/constant-mount.js "$exportPath/constant-mount.js"
# 根据用户输入决定是否导出ponstant.js
if [[ "$changePort" =~ ^[Yy]$ ]]; then
    docker cp nginx-plex-rm:/etc/nginx/conf.d/includes/http.conf "$exportPath/http.conf"
    echo "http.conf 文件已导出"
    # 如果更改端口，还需要在 http.conf 中替换端口
    if [ -f "$exportPath/http.conf" ]; then
        sed -i "s|8091|$newPort|g" "$exportPath/http.conf"
        echo "http.conf 文件中的端口已更新"
    fi
else
    echo "http.conf 文件未导出"
fi

# 检查 constant.js 文件是否存在
if [ -f "$exportPath/constant.js" ]; then
    # 替换 constant.js 文件中的内容
    sed -i "s|http://172.17.0.1:32400|$plexHost|g" "$exportPath/constant.js"
    sed -i "s|\"/mnt\"|$plexMountPath|g" "$exportPath/constant.js"
    echo "constant.js 文件已更新"
else
    echo "constant.js 文件不存在"
fi

# 检查 constant-mount.js 文件是否存在
if [ -f "$exportPath/constant-mount.js" ]; then
    # 替换 constant-mount.js 文件中的内容
    sed -i "s|http://172.17.0.1:5244|$alistAddr|g" "$exportPath/constant-mount.js"
    sed -i "s|alsit-123456|$alistToken|g" "$exportPath/constant-mount.js"
    sed -i "s|http://youralist.com:5244|$alistPublicAddr|g" "$exportPath/constant-mount.js"
    echo "constant-mount.js 文件已更新"
else
    echo "constant-mount.js 文件不存在"
fi
docker rm -f nginx-plex-rm
