<template>
  <div class="home-container">
    <!-- 问候语区域 -->
    <div class="greeting-section">
      <h2 class="greeting">{{ greetingMessage }}</h2>
      <p class="today-info">今天是 {{ todayDate }} {{ weekDay }}</p>
    </div>

    <!-- 信息卡片区域 -->
    <div class="info-cards">
      <!-- 天气信息卡片 -->
      <el-card class="weather-card" shadow="hover">
        <div class="card-header">
          <i class="el-icon-sunny"></i>
          <span>天气信息</span>
        </div>
        <div class="weather-content">
          <div class="temperature">{{ weatherInfo.temperature }}°C</div>
          <div class="weather-desc">{{ weatherInfo.description }}</div>
          <div class="weather-details">
            <div class="detail-item">
              <i class="el-icon-view"></i>
              <span>湿度: {{ weatherInfo.humidity }}%</span>
            </div>
            <div class="detail-item">
              <i class="el-icon-wind-power"></i>
              <span>风力: {{ weatherInfo.windSpeed }}级</span>
            </div>
          </div>
          <div class="location">
            <i class="el-icon-location"></i>
            {{ weatherInfo.location }}
          </div>
        </div>
      </el-card>

      <!-- 节日提醒卡片 -->
      <el-card class="festival-card" shadow="hover">
        <div class="card-header">
          <i class="el-icon-present"></i>
          <span>节日提醒</span>
        </div>
        <div class="festival-content">
          <div v-if="todayFestival" class="festival-today">
            <div class="festival-name">{{ todayFestival.name }}</div>
            <div class="festival-desc">{{ todayFestival.desc }}</div>
          </div>
          <div v-else class="no-festival">
            <p>今天没有特殊节日</p>
            <p>祝您度过美好的一天！</p>
          </div>
          <div class="upcoming-festivals">
            <h4>即将到来的节日：</h4>
            <div v-for="festival in upcomingFestivals" :key="festival.date" class="upcoming-item">
              <span class="date">{{ festival.date }}</span>
              <span class="name">{{ festival.name }}</span>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 今日提醒卡片 -->
      <el-card class="reminder-card" shadow="hover">
        <div class="card-header">
          <i class="el-icon-bell"></i>
          <span>今日提醒</span>
        </div>
        <div class="reminder-content">
          <div v-if="todayReminders.length > 0">
            <div v-for="reminder in todayReminders" :key="reminder.id" class="reminder-item">
              <div class="reminder-time">{{ reminder.time }}</div>
              <div class="reminder-text">{{ reminder.text }}</div>
              <div class="reminder-type">{{ reminder.type }}</div>
            </div>
          </div>
          <div v-else class="no-reminders">
            <p>今天暂无特殊提醒</p>
            <p>记得按时吃药，保持好心情！</p>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 日历区域 -->
    <div class="calendar-section">
      <el-card class="calendar-card" shadow="hover">
        <div class="card-header">
          <i class="el-icon-date"></i>
          <span>本月日历</span>
        </div>
        <el-calendar v-model="calendarValue" class="custom-calendar">
          <template slot="dateCell" slot-scope="{date, data}">
            <div class="calendar-day">
              <span class="day-number">{{ data.day.split('-')[2] }}</span>
              <div v-if="hasEvent(data.day)" class="day-event"></div>
            </div>
          </template>
        </el-calendar>
      </el-card>
    </div>

    <!-- 快捷操作区域 -->
    <div class="quick-actions">
      <h3>快捷操作</h3>
      <div class="action-buttons">
        <el-button 
          v-for="action in quickActions" 
          :key="action.path"
          :type="action.type"
          size="large"
          class="action-btn"
          @click="$router.push(action.path)"
        >
          <i :class="action.icon"></i>
          {{ action.name }}
        </el-button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Home',
  data() {
    return {
      calendarValue: new Date(),
      weatherInfo: {
        temperature: 22,
        description: '晴转多云',
        humidity: 65,
        windSpeed: 3,
        location: '北京市朝阳区'
      },
      todayFestival: null,
      upcomingFestivals: [
        { date: '12-25', name: '圣诞节' },
        { date: '01-01', name: '元旦节' },
        { date: '02-10', name: '春节' }
      ],
      todayReminders: [
        { id: 1, time: '08:00', text: '早餐后服用降压药', type: '用药提醒' },
        { id: 2, time: '14:30', text: '午休后散步30分钟', type: '健康提醒' },
        { id: 3, time: '20:00', text: '晚餐后服用钙片', type: '保健品提醒' }
      ],
      quickActions: [
        { name: '健康记录', path: '/health', icon: 'el-icon-plus', type: 'success' },
        { name: '用药提醒', path: '/medicine', icon: 'el-icon-time', type: 'warning' },
        { name: '聊天陪伴', path: '/chat', icon: 'el-icon-chat-dot-round', type: 'primary' },
        { name: '联系家人', path: '/contact', icon: 'el-icon-phone', type: 'danger' }
      ]
    }
  },
  computed: {
    greetingMessage() {
      const hour = new Date().getHours()
      if (hour < 6) return '夜深了，早点休息'
      if (hour < 9) return '早上好！新的一天开始了'
      if (hour < 12) return '上午好！今天过得怎么样'
      if (hour < 14) return '中午好！记得午休一下'
      if (hour < 18) return '下午好！适合散散步'
      if (hour < 22) return '晚上好！和家人聊聊天吧'
      return '夜深了，准备休息吧'
    },
    todayDate() {
      return new Date().toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    },
    weekDay() {
      const days = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
      return days[new Date().getDay()]
    }
  },
  mounted() {
    this.checkTodayFestival()
    this.loadWeatherInfo()
  },
  methods: {
    hasEvent(date) {
      // 简单示例：每月15号标记为体检日
      return date.endsWith('-15')
    },
    checkTodayFestival() {
      const today = new Date()
      const month = today.getMonth() + 1
      const day = today.getDate()
      
      // 简单的节日判断逻辑
      const festivals = {
        '1-1': { name: '元旦节', desc: '新年快乐！祝您身体健康，万事如意！' },
        '2-14': { name: '情人节', desc: '爱要说出来，给家人一个拥抱吧！' },
        '3-8': { name: '妇女节', desc: '祝所有女性朋友节日快乐！' },
        '5-1': { name: '劳动节', desc: '劳动最光荣，但也要注意休息！' },
        '6-1': { name: '儿童节', desc: '和孙子孙女一起过节日吧！' },
        '10-1': { name: '国庆节', desc: '祖国生日快乐！' },
        '12-25': { name: '圣诞节', desc: '圣诞快乐！和家人团聚的好日子！' }
      }
      
      const key = `${month}-${day}`
      this.todayFestival = festivals[key] || null
    },
    async loadWeatherInfo() {
      // 这里可以调用实际的天气API
      // 现在使用模拟数据
      try {
        // 模拟API调用
        setTimeout(() => {
          this.weatherInfo = {
            temperature: Math.floor(Math.random() * 20) + 10,
            description: ['晴', '多云', '阴', '小雨'][Math.floor(Math.random() * 4)],
            humidity: Math.floor(Math.random() * 40) + 40,
            windSpeed: Math.floor(Math.random() * 5) + 1,
            location: '当前位置'
          }
        }, 1000)
      } catch (error) {
        console.error('获取天气信息失败:', error)
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.home-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.greeting-section {
  text-align: center;
  margin-bottom: 30px;
  padding: 20px;
  background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%);
  border-radius: 15px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  
  .greeting {
    font-size: 28px;
    color: #2d3436;
    margin-bottom: 10px;
    font-weight: bold;
  }
  
  .today-info {
    font-size: 18px;
    color: #636e72;
  }
}

.info-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.card-header {
  display: flex;
  align-items: center;
  font-size: 18px;
  font-weight: bold;
  color: #2d3436;
  margin-bottom: 15px;
  
  i {
    font-size: 22px;
    margin-right: 10px;
    color: #0984e3;
  }
}

.weather-card {
  .weather-content {
    text-align: center;
    
    .temperature {
      font-size: 48px;
      font-weight: bold;
      color: #e17055;
      margin-bottom: 10px;
    }
    
    .weather-desc {
      font-size: 20px;
      color: #636e72;
      margin-bottom: 15px;
    }
    
    .weather-details {
      display: flex;
      justify-content: space-around;
      margin-bottom: 15px;
      
      .detail-item {
        display: flex;
        align-items: center;
        font-size: 14px;
        color: #636e72;
        
        i {
          margin-right: 5px;
          color: #0984e3;
        }
      }
    }
    
    .location {
      font-size: 16px;
      color: #2d3436;
      
      i {
        margin-right: 5px;
        color: #e84393;
      }
    }
  }
}

.festival-card {
  .festival-content {
    .festival-today {
      text-align: center;
      margin-bottom: 20px;
      
      .festival-name {
        font-size: 24px;
        font-weight: bold;
        color: #e84393;
        margin-bottom: 10px;
      }
      
      .festival-desc {
        font-size: 16px;
        color: #636e72;
      }
    }
    
    .no-festival {
      text-align: center;
      color: #636e72;
      margin-bottom: 20px;
      
      p {
        margin: 5px 0;
      }
    }
    
    .upcoming-festivals {
      h4 {
        font-size: 16px;
        color: #2d3436;
        margin-bottom: 10px;
      }
      
      .upcoming-item {
        display: flex;
        justify-content: space-between;
        padding: 5px 0;
        border-bottom: 1px solid #ddd;
        
        .date {
          color: #636e72;
          font-size: 14px;
        }
        
        .name {
          color: #2d3436;
          font-weight: bold;
        }
      }
    }
  }
}

.reminder-card {
  .reminder-content {
    .reminder-item {
      display: flex;
      align-items: center;
      padding: 10px;
      margin-bottom: 10px;
      background: #f8f9fa;
      border-radius: 8px;
      border-left: 4px solid #00b894;
      
      .reminder-time {
        font-weight: bold;
        color: #00b894;
        margin-right: 15px;
        min-width: 60px;
      }
      
      .reminder-text {
        flex: 1;
        color: #2d3436;
      }
      
      .reminder-type {
        font-size: 12px;
        color: #636e72;
        background: #e17055;
        color: white;
        padding: 2px 8px;
        border-radius: 4px;
      }
    }
    
    .no-reminders {
      text-align: center;
      color: #636e72;
      
      p {
        margin: 8px 0;
      }
    }
  }
}

.calendar-section {
  margin-bottom: 30px;
}

.calendar-card {
  .custom-calendar {
    .calendar-day {
      position: relative;
      text-align: center;
      
      .day-number {
        font-size: 16px;
        font-weight: bold;
      }
      
      .day-event {
        position: absolute;
        bottom: 2px;
        right: 2px;
        width: 6px;
        height: 6px;
        background: #e84393;
        border-radius: 50%;
      }
    }
  }
}

.quick-actions {
  text-align: center;
  
  h3 {
    font-size: 24px;
    color: #2d3436;
    margin-bottom: 20px;
  }
  
  .action-buttons {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 15px;
    
    .action-btn {
      min-width: 150px;
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

// 响应式设计
@media (max-width: 768px) {
  .home-container {
    padding: 10px;
  }
  
  .greeting-section .greeting {
    font-size: 24px;
  }
  
  .info-cards {
    grid-template-columns: 1fr;
  }
  
  .action-buttons {
    flex-direction: column;
    align-items: center;
    
    .action-btn {
      width: 200px;
    }
  }
}
</style>