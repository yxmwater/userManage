<template>
  <div class="contact-container">
    <div class="page-header">
      <h2>联系家人</h2>
      <p>与亲人保持联系，爱就在身边</p>
    </div>

    <!-- 紧急联系 -->
    <div class="emergency-section">
      <el-card shadow="hover" class="emergency-card">
        <div class="card-header">
          <i class="el-icon-warning-outline"></i>
          <span>紧急联系</span>
        </div>
        <div class="emergency-buttons">
          <el-button 
            type="danger" 
            size="large" 
            @click="makeEmergencyCall('110')"
            class="emergency-btn"
          >
            <i class="el-icon-phone"></i>
            报警 110
          </el-button>
          <el-button 
            type="warning" 
            size="large" 
            @click="makeEmergencyCall('120')"
            class="emergency-btn"
          >
            <i class="el-icon-first-aid-kit"></i>
            急救 120
          </el-button>
          <el-button 
            type="info" 
            size="large" 
            @click="makeEmergencyCall('119')"
            class="emergency-btn"
          >
            <i class="el-icon-warning"></i>
            火警 119
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- 家人联系 -->
    <div class="family-section">
      <div class="section-header">
        <h3>家人联系</h3>
        <el-button type="primary" @click="showAddDialog = true" size="small">
          <i class="el-icon-plus"></i>
          添加联系人
        </el-button>
      </div>
      
      <div class="family-grid">
        <el-card 
          v-for="contact in familyContacts" 
          :key="contact.id" 
          shadow="hover" 
          class="contact-card"
        >
          <div class="contact-avatar">
            <img v-if="contact.avatar" :src="contact.avatar" :alt="contact.name" />
            <i v-else class="el-icon-user-solid"></i>
          </div>
          <div class="contact-info">
            <div class="contact-name">{{ contact.name }}</div>
            <div class="contact-relation">{{ contact.relation }}</div>
            <div class="contact-phone">{{ contact.phone }}</div>
            <div class="contact-status" :class="contact.status">
              <i :class="getStatusIcon(contact.status)"></i>
              {{ getStatusText(contact.status) }}
            </div>
          </div>
          <div class="contact-actions">
            <el-button 
              type="success" 
              circle 
              @click="makeVoiceCall(contact)"
              :title="`给${contact.name}打电话`"
            >
              <i class="el-icon-phone"></i>
            </el-button>
            <el-button 
              type="primary" 
              circle 
              @click="makeVideoCall(contact)"
              :title="`和${contact.name}视频通话`"
            >
              <i class="el-icon-video-camera"></i>
            </el-button>
            <el-button 
              type="info" 
              circle 
              @click="sendMessage(contact)"
              :title="`给${contact.name}发消息`"
            >
              <i class="el-icon-message"></i>
            </el-button>
            <el-button 
              type="warning" 
              circle 
              @click="editContact(contact)"
              :title="编辑联系人"
            >
              <i class="el-icon-edit"></i>
            </el-button>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 通话记录 -->
    <div class="call-history">
      <el-card shadow="hover">
        <div class="card-header">
          <i class="el-icon-phone-outline"></i>
          <span>最近通话</span>
        </div>
        <div class="history-list">
          <div v-if="callHistory.length > 0">
            <div 
              v-for="call in callHistory" 
              :key="call.id"
              class="history-item"
            >
              <div class="call-info">
                <div class="call-avatar">
                  <i :class="getCallIcon(call.type)"></i>
                </div>
                <div class="call-details">
                  <div class="call-name">{{ call.name }}</div>
                  <div class="call-time">{{ call.time }}</div>
                </div>
              </div>
              <div class="call-status">
                <div class="call-duration">{{ call.duration }}</div>
                <div class="call-type" :class="call.status">{{ call.status }}</div>
              </div>
              <div class="call-actions">
                <el-button 
                  type="text" 
                  @click="callBack(call)"
                  style="color: #67c23a;"
                >
                  回拨
                </el-button>
              </div>
            </div>
          </div>
          <div v-else class="no-history">
            <p>暂无通话记录</p>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 添加联系人对话框 -->
    <el-dialog title="添加家人联系方式" :visible.sync="showAddDialog" width="500px">
      <el-form :model="newContact" :rules="contactRules" ref="contactForm" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="newContact.name" placeholder="请输入姓名"/>
        </el-form-item>
        
        <el-form-item label="关系" prop="relation">
          <el-select v-model="newContact.relation" placeholder="请选择关系" style="width: 100%">
            <el-option label="儿子" value="儿子"/>
            <el-option label="女儿" value="女儿"/>
            <el-option label="老伴" value="老伴"/>
            <el-option label="孙子" value="孙子"/>
            <el-option label="孙女" value="孙女"/>
            <el-option label="兄弟姐妹" value="兄弟姐妹"/>
            <el-option label="其他亲人" value="其他亲人"/>
          </el-select>
        </el-form-item>
        
        <el-form-item label="电话" prop="phone">
          <el-input v-model="newContact.phone" placeholder="请输入电话号码"/>
        </el-form-item>
        
        <el-form-item label="备注">
          <el-input 
            v-model="newContact.note" 
            type="textarea" 
            :rows="2"
            placeholder="可以添加一些备注信息"
          />
        </el-form-item>
      </el-form>
      
      <div slot="footer">
        <el-button @click="showAddDialog = false" size="large">取消</el-button>
        <el-button type="primary" @click="saveContact" size="large">保存</el-button>
      </div>
    </el-dialog>

    <!-- 视频通话对话框 -->
    <el-dialog 
      title="视频通话" 
      :visible.sync="showVideoDialog" 
      width="600px"
      :before-close="endCall"
    >
      <div class="video-call-container">
        <div class="video-area">
          <div class="remote-video">
            <div class="video-placeholder">
              <div class="calling-animation">
                <div class="calling-avatar">
                  <i class="el-icon-user-solid"></i>
                </div>
                <div class="calling-text">正在呼叫 {{ currentCall?.name }}...</div>
                <div class="calling-dots">
                  <span></span>
                  <span></span>
                  <span></span>
                </div>
              </div>
            </div>
          </div>
          <div class="local-video">
            <div class="video-placeholder small">
              <i class="el-icon-video-camera-solid"></i>
            </div>
          </div>
        </div>
        <div class="call-controls">
          <el-button type="danger" circle @click="endCall" size="large">
            <i class="el-icon-phone"></i>
          </el-button>
          <el-button circle @click="toggleMute" size="large">
            <i :class="isMuted ? 'el-icon-microphone' : 'el-icon-microphone'"></i>
          </el-button>
          <el-button circle @click="toggleVideo" size="large">
            <i :class="isVideoOn ? 'el-icon-video-camera' : 'el-icon-video-camera-solid'"></i>
          </el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'Contact',
  data() {
    return {
      showAddDialog: false,
      showVideoDialog: false,
      isMuted: false,
      isVideoOn: true,
      currentCall: null,
      newContact: {
        name: '',
        relation: '',
        phone: '',
        note: ''
      },
      contactRules: {
        name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
        relation: [{ required: true, message: '请选择关系', trigger: 'change' }],
        phone: [
          { required: true, message: '请输入电话号码', trigger: 'blur' },
          { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
        ]
      },
      familyContacts: [
        {
          id: 1,
          name: '小明',
          relation: '儿子',
          phone: '138-0000-1234',
          status: 'online',
          avatar: null
        },
        {
          id: 2,
          name: '小丽',
          relation: '女儿',
          phone: '139-0000-5678',
          status: 'offline',
          avatar: null
        },
        {
          id: 3,
          name: '老张',
          relation: '老伴',
          phone: '137-0000-9012',
          status: 'busy',
          avatar: null
        },
        {
          id: 4,
          name: '小虎',
          relation: '孙子',
          phone: '135-0000-3456',
          status: 'online',
          avatar: null
        }
      ],
      callHistory: [
        {
          id: 1,
          name: '小明',
          type: 'video',
          time: '今天 14:30',
          duration: '15分钟',
          status: '已接通'
        },
        {
          id: 2,
          name: '小丽',
          type: 'voice',
          time: '昨天 19:20',
          duration: '8分钟',
          status: '已接通'
        },
        {
          id: 3,
          name: '老张',
          type: 'voice',
          time: '前天 10:15',
          duration: '未接通',
          status: '未接通'
        }
      ]
    }
  },
  methods: {
    getStatusIcon(status) {
      const iconMap = {
        'online': 'el-icon-success',
        'offline': 'el-icon-remove-outline',
        'busy': 'el-icon-warning-outline'
      }
      return iconMap[status] || 'el-icon-remove-outline'
    },
    getStatusText(status) {
      const textMap = {
        'online': '在线',
        'offline': '离线',
        'busy': '忙碌'
      }
      return textMap[status] || '未知'
    },
    getCallIcon(type) {
      return type === 'video' ? 'el-icon-video-camera' : 'el-icon-phone'
    },
    makeEmergencyCall(number) {
      this.$confirm(`确定要拨打 ${number} 吗？`, '紧急呼叫', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$message.success(`正在拨打 ${number}...`)
        // 这里可以集成实际的拨号功能
      }).catch(() => {
        this.$message.info('已取消拨号')
      })
    },
    makeVoiceCall(contact) {
      this.$message.success(`正在呼叫 ${contact.name}...`)
      // 添加通话记录
      this.addCallHistory(contact, 'voice')
    },
    makeVideoCall(contact) {
      this.currentCall = contact
      this.showVideoDialog = true
      this.$message.success(`正在发起视频通话 ${contact.name}...`)
      
      // 模拟连接延迟
      setTimeout(() => {
        if (this.showVideoDialog) {
          this.$message.success('视频通话已连接')
        }
      }, 3000)
      
      this.addCallHistory(contact, 'video')
    },
    sendMessage(contact) {
      this.$message.info(`消息功能开发中，将向 ${contact.name} 发送消息`)
    },
    editContact(contact) {
      this.$message.info('编辑功能开发中...')
    },
    callBack(call) {
      const contact = this.familyContacts.find(c => c.name === call.name)
      if (contact) {
        if (call.type === 'video') {
          this.makeVideoCall(contact)
        } else {
          this.makeVoiceCall(contact)
        }
      }
    },
    addCallHistory(contact, type) {
      const newCall = {
        id: Date.now(),
        name: contact.name,
        type: type,
        time: '刚刚',
        duration: '连接中...',
        status: '拨号中'
      }
      this.callHistory.unshift(newCall)
      
      // 模拟通话结束后更新状态
      setTimeout(() => {
        const index = this.callHistory.findIndex(c => c.id === newCall.id)
        if (index > -1) {
          this.callHistory[index].status = '已接通'
          this.callHistory[index].duration = `${Math.floor(Math.random() * 20) + 5}分钟`
        }
      }, 5000)
    },
    endCall() {
      this.showVideoDialog = false
      this.currentCall = null
      this.isMuted = false
      this.isVideoOn = true
      this.$message.info('通话已结束')
    },
    toggleMute() {
      this.isMuted = !this.isMuted
      this.$message.info(this.isMuted ? '已静音' : '已取消静音')
    },
    toggleVideo() {
      this.isVideoOn = !this.isVideoOn
      this.$message.info(this.isVideoOn ? '视频已开启' : '视频已关闭')
    },
    saveContact() {
      this.$refs.contactForm.validate((valid) => {
        if (valid) {
          const contact = {
            id: Date.now(),
            ...this.newContact,
            status: 'offline',
            avatar: null
          }
          
          this.familyContacts.push(contact)
          this.$message.success('联系人添加成功！')
          this.showAddDialog = false
          this.resetForm()
        }
      })
    },
    resetForm() {
      this.newContact = {
        name: '',
        relation: '',
        phone: '',
        note: ''
      }
      this.$refs.contactForm.resetFields()
    }
  }
}
</script>

<style lang="stylus" scoped>
.contact-container {
  max-width: 1200px;
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

.emergency-section {
  margin-bottom: 30px;
}

.emergency-card {
  .card-header {
    display: flex;
    align-items: center;
    font-size: 18px;
    font-weight: bold;
    color: #e74c3c;
    margin-bottom: 20px;
    
    i {
      font-size: 20px;
      margin-right: 8px;
    }
  }
  
  .emergency-buttons {
    display: flex;
    justify-content: center;
    gap: 20px;
    flex-wrap: wrap;
    
    .emergency-btn {
      min-width: 120px;
      height: 60px;
      font-size: 16px;
      font-weight: bold;
      
      i {
        margin-right: 8px;
        font-size: 18px;
      }
    }
  }
}

.family-section {
  margin-bottom: 30px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  
  h3 {
    font-size: 20px;
    color: #2d3436;
  }
}

.family-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.contact-card {
  text-align: center;
  padding: 20px;
  transition: transform 0.3s ease;
  
  &:hover {
    transform: translateY(-5px);
  }
  
  .contact-avatar {
    width: 80px;
    height: 80px;
    margin: 0 auto 15px;
    border-radius: 50%;
    background: #f1f2f6;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    
    i {
      font-size: 40px;
      color: #636e72;
    }
  }
  
  .contact-info {
    margin-bottom: 20px;
    
    .contact-name {
      font-size: 18px;
      font-weight: bold;
      color: #2d3436;
      margin-bottom: 5px;
    }
    
    .contact-relation {
      font-size: 14px;
      color: #636e72;
      margin-bottom: 5px;
    }
    
    .contact-phone {
      font-size: 14px;
      color: #74b9ff;
      margin-bottom: 8px;
    }
    
    .contact-status {
      font-size: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      
      &.online {
        color: #00b894;
      }
      
      &.offline {
        color: #636e72;
      }
      
      &.busy {
        color: #fdcb6e;
      }
      
      i {
        margin-right: 4px;
      }
    }
  }
  
  .contact-actions {
    display: flex;
    justify-content: center;
    gap: 10px;
    flex-wrap: wrap;
  }
}

.call-history {
  margin-bottom: 30px;
  
  .card-header {
    display: flex;
    align-items: center;
    font-size: 18px;
    font-weight: bold;
    color: #2d3436;
    margin-bottom: 20px;
    
    i {
      font-size: 20px;
      margin-right: 8px;
      color: #74b9ff;
    }
  }
  
  .history-item {
    display: flex;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #eee;
    
    &:last-child {
      border-bottom: none;
    }
    
    .call-info {
      flex: 1;
      display: flex;
      align-items: center;
      
      .call-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #74b9ff;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 15px;
        
        i {
          font-size: 18px;
        }
      }
      
      .call-details {
        .call-name {
          font-size: 16px;
          font-weight: bold;
          color: #2d3436;
          margin-bottom: 3px;
        }
        
        .call-time {
          font-size: 12px;
          color: #636e72;
        }
      }
    }
    
    .call-status {
      text-align: center;
      margin-right: 15px;
      
      .call-duration {
        font-size: 14px;
        color: #2d3436;
        margin-bottom: 3px;
      }
      
      .call-type {
        font-size: 12px;
        
        &.已接通 {
          color: #00b894;
        }
        
        &.未接通 {
          color: #e17055;
        }
        
        &.拨号中 {
          color: #fdcb6e;
        }
      }
    }
  }
  
  .no-history {
    text-align: center;
    color: #636e72;
    padding: 40px 20px;
  }
}

.video-call-container {
  .video-area {
    position: relative;
    height: 300px;
    background: #2d3436;
    border-radius: 8px;
    overflow: hidden;
    margin-bottom: 20px;
    
    .remote-video {
      width: 100%;
      height: 100%;
      
      .video-placeholder {
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        
        .calling-animation {
          text-align: center;
          color: white;
          
          .calling-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: #74b9ff;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            
            i {
              font-size: 40px;
            }
          }
          
          .calling-text {
            font-size: 18px;
            margin-bottom: 15px;
          }
          
          .calling-dots {
            display: flex;
            justify-content: center;
            gap: 5px;
            
            span {
              width: 8px;
              height: 8px;
              border-radius: 50%;
              background: white;
              animation: calling 1.4s infinite ease-in-out both;
              
              &:nth-child(1) { animation-delay: -0.32s; }
              &:nth-child(2) { animation-delay: -0.16s; }
              &:nth-child(3) { animation-delay: 0; }
            }
          }
        }
      }
    }
    
    .local-video {
      position: absolute;
      bottom: 10px;
      right: 10px;
      width: 120px;
      height: 80px;
      background: #636e72;
      border-radius: 4px;
      
      .video-placeholder.small {
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        
        i {
          font-size: 24px;
        }
      }
    }
  }
  
  .call-controls {
    display: flex;
    justify-content: center;
    gap: 15px;
  }
}

@keyframes calling {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

// 响应式设计
@media (max-width: 768px) {
  .contact-container {
    padding: 15px;
  }
  
  .page-header h2 {
    font-size: 24px;
  }
  
  .emergency-buttons {
    flex-direction: column;
    align-items: center;
    
    .emergency-btn {
      width: 200px;
    }
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .family-grid {
    grid-template-columns: 1fr;
  }
  
  .contact-actions {
    .el-button {
      margin: 2px;
    }
  }
  
  .history-item {
    flex-direction: column;
    align-items: flex-start;
    
    .call-status {
      margin-top: 10px;
      margin-right: 0;
      text-align: left;
    }
    
    .call-actions {
      margin-top: 10px;
    }
  }
  
  .video-area {
    height: 250px;
    
    .local-video {
      width: 100px;
      height: 70px;
    }
  }
}
</style>