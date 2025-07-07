<template>
  <div id="app">
    <div class="main-container">
      <header class="header">
        <h1 class="title">温馨陪伴</h1>
        <div class="current-time">{{ currentTime }}</div>
      </header>
      
      <nav class="navigation" v-if="$route.name !== 'login'">
        <el-button 
          v-for="nav in navigations" 
          :key="nav.path"
          :type="$route.path === nav.path ? 'primary' : 'default'"
          size="large"
          class="nav-button"
          @click="$router.push(nav.path)"
        >
          <i :class="nav.icon"></i>
          {{ nav.name }}
        </el-button>
      </nav>
      
      <main class="content">
        <router-view/>
      </main>
    </div>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      currentTime: '',
      navigations: [
        { name: '首页', path: '/home', icon: 'el-icon-house' },
        { name: '健康管理', path: '/health', icon: 'el-icon-plus' },
        { name: '用药提醒', path: '/medicine', icon: 'el-icon-time' },
        { name: '聊天陪伴', path: '/chat', icon: 'el-icon-chat-dot-round' },
        { name: '联系家人', path: '/contact', icon: 'el-icon-phone' },
        { name: '个人信息', path: '/profile', icon: 'el-icon-user' }
      ]
    }
  },
  mounted() {
    this.updateTime()
    setInterval(this.updateTime, 1000)
  },
  methods: {
    updateTime() {
      const now = new Date()
      this.currentTime = now.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    }
  }
}
</script>

<style lang="stylus">
* {
  padding: 0;
  margin: 0;
  box-sizing: border-box;
}

body {
  font-family: '微软雅黑', 'Microsoft YaHei', sans-serif;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
}

#app {
  min-height: 100vh;
}

.main-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  text-align: center;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
  
  .title {
    font-size: 32px;
    font-weight: bold;
    margin-bottom: 10px;
  }
  
  .current-time {
    font-size: 18px;
    opacity: 0.9;
  }
}

.navigation {
  background: white;
  padding: 20px;
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 15px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  
  .nav-button {
    min-width: 140px;
    height: 60px;
    font-size: 16px;
    font-weight: bold;
    border-radius: 8px;
    
    i {
      margin-right: 8px;
      font-size: 18px;
    }
  }
}

.content {
  flex: 1;
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}

// 全局按钮样式优化
.el-button {
  transition: all 0.3s ease;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  }
}

// 响应式设计
@media (max-width: 768px) {
  .header .title {
    font-size: 24px;
  }
  
  .navigation {
    padding: 10px;
    
    .nav-button {
      min-width: 120px;
      height: 50px;
      font-size: 14px;
    }
  }
  
  .content {
    padding: 15px;
  }
}
</style>
