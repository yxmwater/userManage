<template>
  <div class="chat-container">
    <div class="page-header">
      <h2>聊天陪伴</h2>
      <p>有什么想聊的，尽管说吧</p>
    </div>

    <!-- 聊天界面 -->
    <div class="chat-interface">
      <el-card shadow="always" class="chat-card">
        <!-- 聊天记录区域 -->
        <div class="chat-messages" ref="messagesContainer">
          <div 
            v-for="message in messages" 
            :key="message.id"
            class="message-item"
            :class="{ 'user-message': message.isUser, 'bot-message': !message.isUser }"
          >
            <div class="message-avatar">
              <i :class="message.isUser ? 'el-icon-user-solid' : 'el-icon-service'"></i>
            </div>
            <div class="message-content">
              <div class="message-text">{{ message.text }}</div>
              <div class="message-time">{{ message.time }}</div>
            </div>
          </div>
          
          <!-- 正在输入提示 -->
          <div v-if="isTyping" class="typing-indicator">
            <div class="message-item bot-message">
              <div class="message-avatar">
                <i class="el-icon-service"></i>
              </div>
              <div class="message-content">
                <div class="typing-dots">
                  <span></span>
                  <span></span>
                  <span></span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 快捷回复区域 -->
        <div class="quick-replies">
          <div class="quick-reply-title">快捷话题：</div>
          <div class="quick-reply-buttons">
            <el-button 
              v-for="topic in quickTopics" 
              :key="topic.id"
              size="small"
              @click="sendQuickMessage(topic.text)"
              class="quick-reply-btn"
            >
              {{ topic.text }}
            </el-button>
          </div>
        </div>

        <!-- 输入区域 -->
        <div class="chat-input">
          <div class="input-container">
            <el-input
              v-model="inputMessage"
              type="textarea"
              :rows="2"
              placeholder="请输入您想说的话..."
              @keydown.ctrl.enter="sendMessage"
              @keydown.enter.prevent="sendMessage"
              class="message-input"
              maxlength="500"
              show-word-limit
            />
            <div class="input-actions">
              <el-button 
                type="primary" 
                @click="sendMessage"
                :disabled="!inputMessage.trim()"
                size="large"
                class="send-btn"
              >
                <i class="el-icon-s-promotion"></i>
                发送
              </el-button>
              <el-button 
                @click="clearChat"
                size="large"
                class="clear-btn"
              >
                <i class="el-icon-delete"></i>
                清空
              </el-button>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 聊天统计 -->
    <div class="chat-stats">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-chat-dot-round" style="color: #67c23a;"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ totalMessages }}</div>
                <div class="stat-label">今日聊天</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-time" style="color: #409eff;"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ chatDuration }}</div>
                <div class="stat-label">聊天时长</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-star-on" style="color: #f56c6c;"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ mood }}</div>
                <div class="stat-label">心情指数</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 聊天提示 -->
    <div class="chat-tips">
      <el-card shadow="hover">
        <div class="tips-header">
          <i class="el-icon-info"></i>
          <span>聊天小贴士</span>
        </div>
        <div class="tips-content">
          <div class="tip-item">
            <i class="el-icon-check"></i>
            <span>可以和我聊聊您的日常生活、兴趣爱好</span>
          </div>
          <div class="tip-item">
            <i class="el-icon-check"></i>
            <span>有什么烦恼或开心的事都可以分享</span>
          </div>
          <div class="tip-item">
            <i class="el-icon-check"></i>
            <span>按 Ctrl+Enter 或点击发送按钮发送消息</span>
          </div>
          <div class="tip-item">
            <i class="el-icon-check"></i>
            <span>使用快捷话题可以快速开始对话</span>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Chat',
  data() {
    return {
      inputMessage: '',
      isTyping: false,
      totalMessages: 0,
      chatDuration: '0分钟',
      mood: '😊',
      messages: [
        {
          id: 1,
          text: '您好！我是您的聊天伙伴，很高兴见到您！今天过得怎么样？',
          isUser: false,
          time: this.getCurrentTime()
        }
      ],
      quickTopics: [
        { id: 1, text: '今天天气真不错' },
        { id: 2, text: '想聊聊家人' },
        { id: 3, text: '分享开心的事' },
        { id: 4, text: '有点担心身体' },
        { id: 5, text: '想念年轻时候' },
        { id: 6, text: '聊聊兴趣爱好' }
      ],
      chatStartTime: new Date(),
      responseTemplates: {
        greetings: [
          '您好！很高兴和您聊天！',
          '早上好！今天的心情怎么样？',
          '下午好！有什么想分享的吗？',
          '晚上好！今天过得充实吗？'
        ],
        weather: [
          '是啊，好天气总是让人心情愉快呢！',
          '天气好的时候适合出去走走，您觉得呢？',
          '这样的天气让人想起很多美好的回忆。'
        ],
        family: [
          '家人是最珍贵的财富，和家人在一起的时光总是美好的。',
          '家人的关爱是最温暖的，您一定有很多和家人的美好回忆吧。',
          '家庭和睦是最大的幸福，您的家人一定很爱您。'
        ],
        health: [
          '身体健康确实很重要，保持好心情也有助于健康哦。',
          '有什么身体不适一定要及时看医生，同时也要注意休息。',
          '健康是最重要的，建议您保持规律的作息和适当的运动。'
        ],
        memories: [
          '美好的回忆是人生的宝藏，每一段经历都很珍贵。',
          '年轻时候的事情想起来总是让人怀念，您愿意分享一些吗？',
          '过往的岁月虽然不能重来，但回忆会一直温暖着我们。'
        ],
        hobbies: [
          '有兴趣爱好真是太好了！这能让生活更加丰富多彩。',
          '坚持自己的兴趣爱好是很棒的事情，能带来很多快乐。',
          '兴趣爱好不仅有趣，还能让人保持年轻的心态呢！'
        ],
        default: [
          '说得很好，您的话让我很有感触。',
          '谢谢您的分享，我很乐意听您说话。',
          '您说得对，生活中确实有很多值得珍惜的事情。',
          '听您这么说，我也感到很温暖。',
          '您的话很有道理，让我学到了很多。'
        ]
      }
    }
  },
  mounted() {
    this.scrollToBottom()
    this.startChatTimer()
  },
  methods: {
    getCurrentTime() {
      return new Date().toLocaleTimeString('zh-CN', {
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    sendMessage() {
      if (!this.inputMessage.trim()) return
      
      // 添加用户消息
      const userMessage = {
        id: Date.now(),
        text: this.inputMessage.trim(),
        isUser: true,
        time: this.getCurrentTime()
      }
      
      this.messages.push(userMessage)
      this.totalMessages++
      
      // 清空输入框
      const message = this.inputMessage
      this.inputMessage = ''
      
      // 滚动到底部
      this.$nextTick(() => {
        this.scrollToBottom()
      })
      
      // 模拟机器人回复
      this.generateBotResponse(message)
    },
    sendQuickMessage(text) {
      this.inputMessage = text
      this.sendMessage()
    },
    generateBotResponse(userMessage) {
      this.isTyping = true
      
      setTimeout(() => {
        const response = this.getBotResponse(userMessage)
        const botMessage = {
          id: Date.now(),
          text: response,
          isUser: false,
          time: this.getCurrentTime()
        }
        
        this.messages.push(botMessage)
        this.isTyping = false
        
        this.$nextTick(() => {
          this.scrollToBottom()
        })
      }, 1000 + Math.random() * 2000) // 1-3秒随机延迟
    },
    getBotResponse(userMessage) {
      const message = userMessage.toLowerCase()
      
      // 简单的关键词匹配来选择回复类型
      if (message.includes('天气') || message.includes('晴') || message.includes('雨')) {
        return this.getRandomResponse('weather')
      } else if (message.includes('家人') || message.includes('孩子') || message.includes('老伴')) {
        return this.getRandomResponse('family')
      } else if (message.includes('身体') || message.includes('健康') || message.includes('病')) {
        return this.getRandomResponse('health')
      } else if (message.includes('年轻') || message.includes('以前') || message.includes('回忆')) {
        return this.getRandomResponse('memories')
      } else if (message.includes('爱好') || message.includes('兴趣') || message.includes('喜欢')) {
        return this.getRandomResponse('hobbies')
      } else if (message.includes('你好') || message.includes('早上好') || message.includes('下午好') || message.includes('晚上好')) {
        return this.getRandomResponse('greetings')
      } else {
        return this.getRandomResponse('default')
      }
    },
    getRandomResponse(category) {
      const responses = this.responseTemplates[category] || this.responseTemplates.default
      return responses[Math.floor(Math.random() * responses.length)]
    },
    scrollToBottom() {
      const container = this.$refs.messagesContainer
      if (container) {
        container.scrollTop = container.scrollHeight
      }
    },
    clearChat() {
      this.$confirm('确定要清空聊天记录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.messages = [
          {
            id: Date.now(),
            text: '聊天记录已清空，我们重新开始聊天吧！',
            isUser: false,
            time: this.getCurrentTime()
          }
        ]
        this.totalMessages = 0
        this.$message.success('聊天记录已清空')
      }).catch(() => {
        this.$message.info('已取消清空')
      })
    },
    startChatTimer() {
      setInterval(() => {
        const now = new Date()
        const diff = now - this.chatStartTime
        const minutes = Math.floor(diff / 60000)
        this.chatDuration = `${minutes}分钟`
      }, 60000) // 每分钟更新一次
    }
  }
}
</script>

<style lang="stylus" scoped>
.chat-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
  
  h2 {
    font-size: 28px;
    color: #2d3436;
    margin-bottom: 10px;
  }
  
  p {
    color: #636e72;
    font-size: 16px;
  }
}

.chat-interface {
  margin-bottom: 30px;
}

.chat-card {
  border-radius: 15px;
  overflow: hidden;
}

.chat-messages {
  height: 400px;
  overflow-y: auto;
  padding: 20px;
  background: #f8f9fa;
  
  &::-webkit-scrollbar {
    width: 6px;
  }
  
  &::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 3px;
  }
  
  &::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 3px;
    
    &:hover {
      background: #a8a8a8;
    }
  }
}

.message-item {
  display: flex;
  margin-bottom: 20px;
  
  &.user-message {
    justify-content: flex-end;
    
    .message-content {
      background: #409eff;
      color: white;
      border-radius: 18px 18px 5px 18px;
    }
  }
  
  &.bot-message {
    justify-content: flex-start;
    
    .message-content {
      background: white;
      color: #2d3436;
      border-radius: 18px 18px 18px 5px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
  }
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 10px;
  background: #e74c3c;
  color: white;
  font-size: 18px;
  flex-shrink: 0;
}

.user-message .message-avatar {
  background: #409eff;
  order: 2;
}

.bot-message .message-avatar {
  background: #27ae60;
  order: 1;
}

.message-content {
  max-width: 70%;
  padding: 12px 16px;
  
  .message-text {
    font-size: 16px;
    line-height: 1.5;
    word-wrap: break-word;
  }
  
  .message-time {
    font-size: 12px;
    opacity: 0.7;
    margin-top: 5px;
  }
}

.typing-indicator {
  .typing-dots {
    display: flex;
    align-items: center;
    
    span {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: #636e72;
      margin: 0 2px;
      animation: typing 1.4s infinite ease-in-out both;
      
      &:nth-child(1) { animation-delay: -0.32s; }
      &:nth-child(2) { animation-delay: -0.16s; }
      &:nth-child(3) { animation-delay: 0; }
    }
  }
}

@keyframes typing {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.quick-replies {
  padding: 15px 20px;
  border-top: 1px solid #e9ecef;
  background: white;
  
  .quick-reply-title {
    font-size: 14px;
    color: #636e72;
    margin-bottom: 10px;
  }
  
  .quick-reply-buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    
    .quick-reply-btn {
      font-size: 12px;
      padding: 5px 12px;
      height: auto;
      border-radius: 15px;
    }
  }
}

.chat-input {
  padding: 20px;
  background: white;
  border-top: 1px solid #e9ecef;
  
  .input-container {
    .message-input {
      margin-bottom: 15px;
      
      textarea {
        font-size: 16px;
        line-height: 1.5;
        resize: none;
      }
    }
    
    .input-actions {
      display: flex;
      justify-content: space-between;
      
      .send-btn {
        min-width: 100px;
      }
      
      .clear-btn {
        color: #999;
      }
    }
  }
}

.chat-stats {
  margin-bottom: 30px;
}

.stat-card {
  .stat-content {
    display: flex;
    align-items: center;
    
    .stat-icon {
      font-size: 32px;
      margin-right: 15px;
    }
    
    .stat-info {
      .stat-number {
        font-size: 24px;
        font-weight: bold;
        color: #2d3436;
        margin-bottom: 5px;
      }
      
      .stat-label {
        font-size: 14px;
        color: #636e72;
      }
    }
  }
}

.chat-tips {
  .tips-header {
    display: flex;
    align-items: center;
    font-size: 16px;
    font-weight: bold;
    color: #2d3436;
    margin-bottom: 15px;
    
    i {
      font-size: 18px;
      margin-right: 8px;
      color: #409eff;
    }
  }
  
  .tips-content {
    .tip-item {
      display: flex;
      align-items: center;
      margin-bottom: 10px;
      font-size: 14px;
      color: #636e72;
      
      i {
        font-size: 14px;
        margin-right: 8px;
        color: #27ae60;
      }
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .chat-container {
    padding: 15px;
  }
  
  .page-header h2 {
    font-size: 24px;
  }
  
  .chat-messages {
    height: 300px;
  }
  
  .message-content {
    max-width: 85%;
    
    .message-text {
      font-size: 14px;
    }
  }
  
  .message-avatar {
    width: 32px;
    height: 32px;
    font-size: 16px;
  }
  
  .input-actions {
    flex-direction: column;
    gap: 10px;
    
    .send-btn, .clear-btn {
      width: 100%;
    }
  }
  
  .quick-reply-buttons {
    .quick-reply-btn {
      font-size: 11px;
      padding: 4px 10px;
    }
  }
}
</style>