<template>
  <div class="profile-container">
    <div class="page-header">
      <h2>个人信息</h2>
      <p>管理您的个人资料和设置</p>
    </div>

    <!-- 用户信息卡片 -->
    <div class="user-info-section">
      <el-card shadow="hover" class="user-card">
        <div class="user-profile">
          <div class="user-avatar">
            <img v-if="userInfo.avatar" :src="userInfo.avatar" :alt="userInfo.name" />
            <i v-else class="el-icon-user-solid"></i>
            <el-button class="change-avatar-btn" type="primary" size="mini" circle>
              <i class="el-icon-camera"></i>
            </el-button>
          </div>
          <div class="user-details">
            <div class="user-name">{{ userInfo.name }}</div>
            <div class="user-age">{{ userInfo.age }}岁</div>
            <div class="user-location">
              <i class="el-icon-location"></i>
              {{ userInfo.location }}
            </div>
            <div class="user-join-date">
              <i class="el-icon-date"></i>
              加入时间: {{ userInfo.joinDate }}
            </div>
          </div>
          <div class="user-actions">
            <el-button type="primary" @click="showEditDialog = true">
              <i class="el-icon-edit"></i>
              编辑信息
            </el-button>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 统计信息 -->
    <div class="stats-section">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-chat-dot-round" style="color: #67c23a;"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ stats.totalChats }}</div>
                <div class="stat-label">聊天次数</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-plus" style="color: #409eff;"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ stats.healthRecords }}</div>
                <div class="stat-label">健康记录</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-time" style="color: #e6a23c;"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ stats.medicineReminders }}</div>
                <div class="stat-label">用药提醒</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-phone" style="color: #f56c6c;"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ stats.familyContacts }}</div>
                <div class="stat-label">家人联系</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 设置选项 -->
    <div class="settings-section">
      <el-card shadow="hover">
        <div class="card-header">
          <i class="el-icon-setting"></i>
          <span>系统设置</span>
        </div>
        
        <div class="settings-list">
          <!-- 字体大小 -->
          <div class="setting-item">
            <div class="setting-label">
              <i class="el-icon-document"></i>
              <span>字体大小</span>
            </div>
            <div class="setting-control">
              <el-radio-group v-model="settings.fontSize" @change="updateFontSize">
                <el-radio label="small">小</el-radio>
                <el-radio label="medium">中</el-radio>
                <el-radio label="large">大</el-radio>
                <el-radio label="extra-large">特大</el-radio>
              </el-radio-group>
            </div>
          </div>

          <!-- 主题色彩 -->
          <div class="setting-item">
            <div class="setting-label">
              <i class="el-icon-brush"></i>
              <span>主题色彩</span>
            </div>
            <div class="setting-control">
              <div class="theme-colors">
                <div 
                  v-for="theme in themes" 
                  :key="theme.name"
                  class="theme-color"
                  :class="{ active: settings.theme === theme.name }"
                  :style="{ backgroundColor: theme.color }"
                  @click="changeTheme(theme.name)"
                  :title="theme.label"
                />
              </div>
            </div>
          </div>

          <!-- 语音播报 -->
          <div class="setting-item">
            <div class="setting-label">
              <i class="el-icon-microphone"></i>
              <span>语音播报</span>
            </div>
            <div class="setting-control">
              <el-switch v-model="settings.voiceEnabled" @change="updateVoiceSetting"/>
            </div>
          </div>

          <!-- 消息提醒 -->
          <div class="setting-item">
            <div class="setting-label">
              <i class="el-icon-bell"></i>
              <span>消息提醒</span>
            </div>
            <div class="setting-control">
              <el-switch v-model="settings.notificationEnabled" @change="updateNotificationSetting"/>
            </div>
          </div>

          <!-- 简化模式 -->
          <div class="setting-item">
            <div class="setting-label">
              <i class="el-icon-view"></i>
              <span>简化模式</span>
            </div>
            <div class="setting-control">
              <el-switch v-model="settings.simpleMode" @change="updateSimpleMode"/>
            </div>
          </div>

          <!-- 自动保存 -->
          <div class="setting-item">
            <div class="setting-label">
              <i class="el-icon-document-checked"></i>
              <span>自动保存</span>
            </div>
            <div class="setting-control">
              <el-switch v-model="settings.autoSave" @change="updateAutoSave"/>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 紧急联系人 -->
    <div class="emergency-contacts">
      <el-card shadow="hover">
        <div class="card-header">
          <i class="el-icon-warning-outline"></i>
          <span>紧急联系人</span>
        </div>
        
        <div class="emergency-list">
          <div v-for="contact in emergencyContacts" :key="contact.id" class="emergency-item">
            <div class="emergency-info">
              <div class="emergency-name">{{ contact.name }}</div>
              <div class="emergency-relation">{{ contact.relation }}</div>
              <div class="emergency-phone">{{ contact.phone }}</div>
            </div>
            <div class="emergency-actions">
              <el-button type="success" size="small" @click="callEmergencyContact(contact)">
                <i class="el-icon-phone"></i>
                呼叫
              </el-button>
              <el-button type="primary" size="small" @click="editEmergencyContact(contact)">
                <i class="el-icon-edit"></i>
                编辑
              </el-button>
            </div>
          </div>
        </div>
        
        <div class="add-emergency">
          <el-button type="primary" @click="showEmergencyDialog = true">
            <i class="el-icon-plus"></i>
            添加紧急联系人
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- 关于应用 -->
    <div class="about-section">
      <el-card shadow="hover">
        <div class="card-header">
          <i class="el-icon-info"></i>
          <span>关于应用</span>
        </div>
        
        <div class="about-content">
          <div class="about-item">
            <span class="about-label">应用名称:</span>
            <span class="about-value">温馨陪伴</span>
          </div>
          <div class="about-item">
            <span class="about-label">版本号:</span>
            <span class="about-value">v1.0.0</span>
          </div>
          <div class="about-item">
            <span class="about-label">更新日期:</span>
            <span class="about-value">2024-12-19</span>
          </div>
          <div class="about-item">
            <span class="about-label">技术支持:</span>
            <span class="about-value">客服热线: 400-000-0000</span>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 编辑用户信息对话框 -->
    <el-dialog title="编辑个人信息" :visible.sync="showEditDialog" width="500px">
      <el-form :model="editForm" :rules="editRules" ref="editForm" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="editForm.name" placeholder="请输入姓名"/>
        </el-form-item>
        
        <el-form-item label="年龄" prop="age">
          <el-input-number v-model="editForm.age" :min="1" :max="120" style="width: 100%"/>
        </el-form-item>
        
        <el-form-item label="性别" prop="gender">
          <el-radio-group v-model="editForm.gender">
            <el-radio label="男">男</el-radio>
            <el-radio label="女">女</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item label="地址" prop="location">
          <el-input v-model="editForm.location" placeholder="请输入地址"/>
        </el-form-item>
        
        <el-form-item label="电话" prop="phone">
          <el-input v-model="editForm.phone" placeholder="请输入电话号码"/>
        </el-form-item>
      </el-form>
      
      <div slot="footer">
        <el-button @click="showEditDialog = false" size="large">取消</el-button>
        <el-button type="primary" @click="saveUserInfo" size="large">保存</el-button>
      </div>
    </el-dialog>

    <!-- 添加紧急联系人对话框 -->
    <el-dialog title="添加紧急联系人" :visible.sync="showEmergencyDialog" width="500px">
      <el-form :model="emergencyForm" :rules="emergencyRules" ref="emergencyForm" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="emergencyForm.name" placeholder="请输入姓名"/>
        </el-form-item>
        
        <el-form-item label="关系" prop="relation">
          <el-input v-model="emergencyForm.relation" placeholder="请输入关系"/>
        </el-form-item>
        
        <el-form-item label="电话" prop="phone">
          <el-input v-model="emergencyForm.phone" placeholder="请输入电话号码"/>
        </el-form-item>
      </el-form>
      
      <div slot="footer">
        <el-button @click="showEmergencyDialog = false" size="large">取消</el-button>
        <el-button type="primary" @click="saveEmergencyContact" size="large">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'Profile',
  data() {
    return {
      showEditDialog: false,
      showEmergencyDialog: false,
      userInfo: {
        name: '张大爷',
        age: 68,
        gender: '男',
        location: '北京市朝阳区',
        phone: '138-0000-0000',
        avatar: null,
        joinDate: '2024-01-15'
      },
      stats: {
        totalChats: 156,
        healthRecords: 23,
        medicineReminders: 8,
        familyContacts: 4
      },
      settings: {
        fontSize: 'large',
        theme: 'blue',
        voiceEnabled: true,
        notificationEnabled: true,
        simpleMode: false,
        autoSave: true
      },
      themes: [
        { name: 'blue', label: '蓝色', color: '#409eff' },
        { name: 'green', label: '绿色', color: '#67c23a' },
        { name: 'orange', label: '橙色', color: '#e6a23c' },
        { name: 'red', label: '红色', color: '#f56c6c' },
        { name: 'purple', label: '紫色', color: '#9b59b6' }
      ],
      emergencyContacts: [
        { id: 1, name: '小明', relation: '儿子', phone: '138-0000-1234' },
        { id: 2, name: '小丽', relation: '女儿', phone: '139-0000-5678' }
      ],
      editForm: {
        name: '',
        age: 0,
        gender: '',
        location: '',
        phone: ''
      },
      emergencyForm: {
        name: '',
        relation: '',
        phone: ''
      },
      editRules: {
        name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
        age: [{ required: true, message: '请输入年龄', trigger: 'blur' }]
      },
      emergencyRules: {
        name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
        relation: [{ required: true, message: '请输入关系', trigger: 'blur' }],
        phone: [{ required: true, message: '请输入电话号码', trigger: 'blur' }]
      }
    }
  },
  methods: {
    updateFontSize(size) {
      this.$message.success(`字体大小已调整为: ${this.getFontSizeLabel(size)}`)
      // 这里可以实际改变页面字体大小
    },
    getFontSizeLabel(size) {
      const labels = {
        'small': '小',
        'medium': '中',
        'large': '大',
        'extra-large': '特大'
      }
      return labels[size] || '中'
    },
    changeTheme(themeName) {
      this.settings.theme = themeName
      const theme = this.themes.find(t => t.name === themeName)
      this.$message.success(`主题已切换为: ${theme.label}`)
      // 这里可以实际改变页面主题
    },
    updateVoiceSetting(enabled) {
      this.$message.success(enabled ? '语音播报已开启' : '语音播报已关闭')
    },
    updateNotificationSetting(enabled) {
      this.$message.success(enabled ? '消息提醒已开启' : '消息提醒已关闭')
    },
    updateSimpleMode(enabled) {
      this.$message.success(enabled ? '简化模式已开启' : '简化模式已关闭')
    },
    updateAutoSave(enabled) {
      this.$message.success(enabled ? '自动保存已开启' : '自动保存已关闭')
    },
    callEmergencyContact(contact) {
      this.$message.success(`正在呼叫 ${contact.name} (${contact.phone})`)
    },
    editEmergencyContact(contact) {
      this.$message.info('编辑功能开发中...')
    },
    saveUserInfo() {
      this.$refs.editForm.validate((valid) => {
        if (valid) {
          Object.assign(this.userInfo, this.editForm)
          this.$message.success('个人信息更新成功！')
          this.showEditDialog = false
        }
      })
    },
    saveEmergencyContact() {
      this.$refs.emergencyForm.validate((valid) => {
        if (valid) {
          const contact = {
            id: Date.now(),
            ...this.emergencyForm
          }
          this.emergencyContacts.push(contact)
          this.$message.success('紧急联系人添加成功！')
          this.showEmergencyDialog = false
          this.resetEmergencyForm()
        }
      })
    },
    resetEmergencyForm() {
      this.emergencyForm = {
        name: '',
        relation: '',
        phone: ''
      }
      this.$refs.emergencyForm.resetFields()
    }
  },
  watch: {
    showEditDialog(val) {
      if (val) {
        this.editForm = { ...this.userInfo }
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.profile-container {
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

.user-info-section {
  margin-bottom: 30px;
}

.user-card {
  .user-profile {
    display: flex;
    align-items: center;
    padding: 20px;
    
    .user-avatar {
      position: relative;
      width: 100px;
      height: 100px;
      margin-right: 30px;
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
        font-size: 50px;
        color: #636e72;
      }
      
      .change-avatar-btn {
        position: absolute;
        bottom: 0;
        right: 0;
        width: 30px;
        height: 30px;
      }
    }
    
    .user-details {
      flex: 1;
      
      .user-name {
        font-size: 24px;
        font-weight: bold;
        color: #2d3436;
        margin-bottom: 8px;
      }
      
      .user-age {
        font-size: 16px;
        color: #636e72;
        margin-bottom: 8px;
      }
      
      .user-location, .user-join-date {
        font-size: 14px;
        color: #636e72;
        margin-bottom: 5px;
        
        i {
          margin-right: 5px;
          color: #74b9ff;
        }
      }
    }
    
    .user-actions {
      .el-button {
        min-width: 100px;
      }
    }
  }
}

.stats-section {
  margin-bottom: 30px;
}

.stat-card {
  .stat-content {
    display: flex;
    align-items: center;
    padding: 15px;
    
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

.settings-section, .emergency-contacts, .about-section {
  margin-bottom: 30px;
}

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

.settings-list {
  .setting-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #eee;
    
    &:last-child {
      border-bottom: none;
    }
    
    .setting-label {
      display: flex;
      align-items: center;
      font-size: 16px;
      color: #2d3436;
      
      i {
        margin-right: 10px;
        color: #74b9ff;
      }
    }
    
    .setting-control {
      .theme-colors {
        display: flex;
        gap: 10px;
        
        .theme-color {
          width: 24px;
          height: 24px;
          border-radius: 50%;
          cursor: pointer;
          border: 2px solid transparent;
          transition: all 0.3s ease;
          
          &:hover {
            transform: scale(1.1);
          }
          
          &.active {
            border-color: #2d3436;
            transform: scale(1.2);
          }
        }
      }
    }
  }
}

.emergency-list {
  .emergency-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #eee;
    
    &:last-child {
      border-bottom: none;
    }
    
    .emergency-info {
      .emergency-name {
        font-size: 16px;
        font-weight: bold;
        color: #2d3436;
        margin-bottom: 3px;
      }
      
      .emergency-relation {
        font-size: 14px;
        color: #636e72;
        margin-bottom: 3px;
      }
      
      .emergency-phone {
        font-size: 14px;
        color: #74b9ff;
      }
    }
    
    .emergency-actions {
      display: flex;
      gap: 10px;
    }
  }
}

.add-emergency {
  text-align: center;
  margin-top: 20px;
}

.about-content {
  .about-item {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid #eee;
    
    &:last-child {
      border-bottom: none;
    }
    
    .about-label {
      color: #636e72;
      font-size: 14px;
    }
    
    .about-value {
      color: #2d3436;
      font-size: 14px;
      font-weight: 500;
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .profile-container {
    padding: 15px;
  }
  
  .page-header h2 {
    font-size: 24px;
  }
  
  .user-profile {
    flex-direction: column;
    text-align: center;
    
    .user-avatar {
      margin-right: 0;
      margin-bottom: 20px;
    }
    
    .user-actions {
      margin-top: 15px;
    }
  }
  
  .setting-item {
    flex-direction: column;
    align-items: flex-start !important;
    
    .setting-control {
      margin-top: 10px;
      width: 100%;
    }
  }
  
  .emergency-item {
    flex-direction: column;
    align-items: flex-start !important;
    
    .emergency-actions {
      margin-top: 10px;
    }
  }
  
  .about-item {
    flex-direction: column;
    align-items: flex-start !important;
    
    .about-value {
      margin-top: 5px;
    }
  }
}
</style>