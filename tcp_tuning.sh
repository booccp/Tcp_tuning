#!/bin/bash

# 定义绿色输出的函数
green_echo() {
  echo -e "\033[32m$1\033[0m"
}

# 定义红色输出的函数
red_echo() {
  echo -e "\033[31m$1\033[0m"
}

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
  red_echo "请以root用户运行此脚本。"
  exit 1
fi

# 应用TCP窗口调优参数
green_echo "应用TCP窗口调优参数..."

# 删除已有的相关配置
green_echo "删除已有的相关配置..."
sed -i '/net.ipv4.tcp_no_metrics_save/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_frto/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_rfc1337/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_sack/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_fack/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_window_scaling/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_adv_win_scale/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_moderate_rcvbuf/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.core.rmem_max/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.core.wmem_max/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.udp_rmem_min/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.udp_wmem_min/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf &> /dev/null
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf &> /dev/null

# 添加新的配置
green_echo "添加新的配置到 /etc/sysctl.conf..."
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 16384 33554432
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.core.default_qdisc=fq_pie
net.ipv4.tcp_congestion_control=bbr
EOF

# 重新加载sysctl配置
green_echo "重新加载sysctl配置..."
SYSCTL_OUTPUT=$(sysctl -p 2>&1)
if [ $? -ne 0 ]; then
  red_echo "重新加载sysctl配置失败。"
  red_echo "$SYSCTL_OUTPUT"
  exit 1
fi

green_echo "TCP窗口调优参数已应用。"
