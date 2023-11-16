#!/bin/bash
# 生成时间 2023-11-16 08:46:31 UTC
# @正义羊 翻译
# 代理配置
# 如果你需要配置一个代理服务器，以便能够连接到 Internet，
# 那么你可以通过配置 all_proxy 环境变量来实现。
# 默认情况下，此变量为空，即配置 aria2c 不使用任何代理。
#
# 用法：export all_proxy="proxy_address"
# 示例：export all_proxy="127.0.0.1:8888"
#
# 有关如何使用的更多信息可以在以下网站找到：
# https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-all-proxy
# https://aria2.github.io/manual/en/html/aria2c.html#environment

export all_proxy=""

# 代理配置结束

for prog in aria2c cabextract wimlib-imagex chntpw; do
  which $prog &>/dev/null 2>&1 && continue;

  echo "$prog 似乎未安装"
  echo "请查看 readme.unix.md 了解详细信息"
  exit 1
done

mkiso_present=0
which genisoimage &>/dev/null && mkiso_present=1
which mkisofs &>/dev/null && mkiso_present=1

if [ $mkiso_present -eq 0 ]; then
  echo "Genisoimage 和 MKISofs 似乎都没有安装"
  echo "请查看 readme.unix.md 了解详细信息"
  exit 1
fi

destDir="UUPs"
tempScript="aria2_script.$RANDOM.txt"

echo "正在下载 converters..."
aria2c --no-conf --log-level=info --log="aria2_download.log" -x16 -s16 -j5 --allow-overwrite=true --auto-file-renaming=false -d"files" -i"files/converter_multi"
if [ $? != 0 ]; then
  echo ""
  exit 1
fi

echo ""
echo "正在检索 aria2 脚本……"
aria2c --no-conf --log-level=info --log="aria2_download.log" -o"$tempScript" --allow-overwrite=true --auto-file-renaming=false "https://www.uupdump.cn/get.php?id=2d652122-0ea3-477a-9807-c8506fec8fc4&pack=en-us&edition=professional&aria2=2"
if [ $? != 0 ]; then
  echo "无法检索 aria2 脚本"
  exit 1
fi

detectedError=`grep '#UUPDUMP_ERROR:' "$tempScript" | sed 's/#UUPDUMP_ERROR://g'`
if [ ! -z $detectedError ]; then
    echo "无法从 Windows 更新服务器检索数据。原因：$detectedError"
    echo "如果此问题仍然存在，很可能你正在尝试下载的集已从 Windows 更新服务器中删除。"
    exit 1
fi

echo ""
echo "正在尝试下载文件……"
aria2c --no-conf --log-level=info --log="aria2_download.log" -x16 -s16 -j5 -c -R -d"$destDir" -i"$tempScript"
if [ $? != 0 ]; then
  echo "我们在下载文件时遇到错误。"
  exit 1
fi

echo ""
if [ -e ./files/convert.sh ]; then
  chmod +x ./files/convert.sh
  ./files/convert.sh wim "$destDir" 0
fi
