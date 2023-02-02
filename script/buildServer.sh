scriptDir="$(dirname "$0")"
cd "$scriptDir" || exit
cd ../
# 打包aot文件
fvm dart compile aot-snapshot ./lib/main.dart
# 上传至服务器
#rsync -avzP -e "ssh -i ~/Documents/wdk_aly_server_sshkey.pem" ../lib/main.aot root@47.104.233.165:/www/wwwroot/card.wangdekun.com
# 重启 supervisorctl的server守护进程
#ssh -i ~/Documents/wdk_aly_server_sshkey.pem root@47.104.233.165 "supervisorctl restart flutterCardServer:flutterCardServer_00"