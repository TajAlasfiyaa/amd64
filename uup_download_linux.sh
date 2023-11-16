#!/bin/bash
# ����ʱ�� 2023-11-16 08:46:31 UTC
# @������ ����
# ��������
# �������Ҫ����һ��������������Ա��ܹ����ӵ� Internet��
# ��ô�����ͨ������ all_proxy ����������ʵ�֡�
# Ĭ������£��˱���Ϊ�գ������� aria2c ��ʹ���κδ���
#
# �÷���export all_proxy="proxy_address"
# ʾ����export all_proxy="127.0.0.1:8888"
#
# �й����ʹ�õĸ�����Ϣ������������վ�ҵ���
# https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-all-proxy
# https://aria2.github.io/manual/en/html/aria2c.html#environment

export all_proxy=""

# �������ý���

for prog in aria2c cabextract wimlib-imagex chntpw; do
  which $prog &>/dev/null 2>&1 && continue;

  echo "$prog �ƺ�δ��װ"
  echo "��鿴 readme.unix.md �˽���ϸ��Ϣ"
  exit 1
done

mkiso_present=0
which genisoimage &>/dev/null && mkiso_present=1
which mkisofs &>/dev/null && mkiso_present=1

if [ $mkiso_present -eq 0 ]; then
  echo "Genisoimage �� MKISofs �ƺ���û�а�װ"
  echo "��鿴 readme.unix.md �˽���ϸ��Ϣ"
  exit 1
fi

destDir="UUPs"
tempScript="aria2_script.$RANDOM.txt"

echo "�������� converters..."
aria2c --no-conf --log-level=info --log="aria2_download.log" -x16 -s16 -j5 --allow-overwrite=true --auto-file-renaming=false -d"files" -i"files/converter_multi"
if [ $? != 0 ]; then
  echo ""
  exit 1
fi

echo ""
echo "���ڼ��� aria2 �ű�����"
aria2c --no-conf --log-level=info --log="aria2_download.log" -o"$tempScript" --allow-overwrite=true --auto-file-renaming=false "https://www.uupdump.cn/get.php?id=2d652122-0ea3-477a-9807-c8506fec8fc4&pack=en-us&edition=professional&aria2=2"
if [ $? != 0 ]; then
  echo "�޷����� aria2 �ű�"
  exit 1
fi

detectedError=`grep '#UUPDUMP_ERROR:' "$tempScript" | sed 's/#UUPDUMP_ERROR://g'`
if [ ! -z $detectedError ]; then
    echo "�޷��� Windows ���·������������ݡ�ԭ��$detectedError"
    echo "�����������Ȼ���ڣ��ܿ��������ڳ������صļ��Ѵ� Windows ���·�������ɾ����"
    exit 1
fi

echo ""
echo "���ڳ��������ļ�����"
aria2c --no-conf --log-level=info --log="aria2_download.log" -x16 -s16 -j5 -c -R -d"$destDir" -i"$tempScript"
if [ $? != 0 ]; then
  echo "�����������ļ�ʱ��������"
  exit 1
fi

echo ""
if [ -e ./files/convert.sh ]; then
  chmod +x ./files/convert.sh
  ./files/convert.sh wim "$destDir" 0
fi
