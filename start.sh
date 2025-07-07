#!/bin/bash

# 温馨陪伴 - 老年人情感陪伴网站启动脚本

echo "=================================================="
echo "🏠 温馨陪伴 - 老年人情感陪伴网站"
echo "=================================================="
echo ""

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ 错误：未找到Node.js，请先安装Node.js"
    echo "📥 下载地址：https://nodejs.org/"
    exit 1
fi

# 检查npm是否安装
if ! command -v npm &> /dev/null; then
    echo "❌ 错误：未找到npm，请确保npm已正确安装"
    exit 1
fi

echo "✅ Node.js版本：$(node --version)"
echo "✅ npm版本：$(npm --version)"
echo ""

# 检查是否已安装依赖
if [ ! -d "node_modules" ]; then
    echo "📦 正在安装项目依赖..."
    npm install
    echo ""
fi

echo "🚀 正在启动开发服务器..."
echo "📱 启动后可以在浏览器中访问："
echo "   - 本地访问：http://localhost:8080"
echo "   - 网络访问：http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "⏹️  按 Ctrl+C 停止服务器"
echo "=================================================="
echo ""

# 使用legacy provider启动以解决Node.js版本兼容问题
NODE_OPTIONS="--openssl-legacy-provider" npm run serve