#fvm dart compile exe ../lib/main.dart
#rsync -avzP -e "ssh -i ~/Documents/wdk_aly_server_sshkey.pem" ../lib/main.exe root@47.104.233.165:/www/wwwroot/card.wangdekun.com

# 打包aot文件
fvm dart compile aot-snapshot ../lib/main.dart
# 上传至服务器
rsync -avzP -e "ssh -i ~/Documents/wdk_aly_server_sshkey.pem" ../lib/main.aot root@47.104.233.165:/www/wwwroot/card.wangdekun.com
# 重启 supervisorctl的server守护进程
ssh -i ~/Documents/wdk_aly_server_sshkey.pem root@47.104.233.165 "supervisorctl restart flutterCardServer:flutterCardServer_00"

# 在服务器上的一些信息
# dartaotruntime ./main.aot
#/root/snap/flutter/common/flutter/bin/cache/dar  t-sdk/bin/dartaotruntime