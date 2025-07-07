<template>
  <div class="health-container">
    <div class="page-header">
      <h2>健康管理</h2>
      <p>记录您的健康指标，关爱身体每一天</p>
    </div>

    <!-- 快速操作区域 -->
    <div class="quick-operations">
      <el-button 
        type="primary" 
        size="large" 
        icon="el-icon-plus"
        @click="showAddDialog = true"
        class="add-btn"
      >
        添加记录
      </el-button>
      <el-button 
        type="info" 
        size="large" 
        icon="el-icon-view"
        @click="activeTab = 'history'"
        class="view-btn"
      >
        查看历史
      </el-button>
    </div>

    <!-- 今日概览 -->
    <div class="today-overview">
      <h3>今日健康概览</h3>
      <div class="health-cards">
        <el-card class="health-item" v-for="item in healthOverview" :key="item.type" shadow="hover">
          <div class="health-icon">
            <i :class="item.icon" :style="{color: item.color}"></i>
          </div>
          <div class="health-info">
            <div class="health-name">{{ item.name }}</div>
            <div class="health-value" :style="{color: item.color}">
              {{ item.value || '暂无记录' }}
            </div>
            <div class="health-status" :style="{color: getStatusColor(item.status)}">
              {{ item.status }}
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 健康建议 -->
    <div class="health-suggestions">
      <el-card shadow="hover">
        <div class="card-header">
          <i class="el-icon-star-on"></i>
          <span>健康建议</span>
        </div>
        <div class="suggestions-content">
          <div v-for="suggestion in healthSuggestions" :key="suggestion.id" class="suggestion-item">
            <div class="suggestion-icon">
              <i :class="suggestion.icon" :style="{color: suggestion.color}"></i>
            </div>
            <div class="suggestion-text">{{ suggestion.text }}</div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Tab切换 -->
    <el-tabs v-model="activeTab" class="health-tabs">
      <!-- 历史记录 -->
      <el-tab-pane label="历史记录" name="history">
        <div class="history-section">
          <div class="filter-controls">
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              size="large"
              @change="filterRecords"
            />
            <el-select v-model="selectedType" placeholder="选择指标类型" size="large" @change="filterRecords">
              <el-option label="全部" value=""></el-option>
              <el-option label="血压" value="血压"></el-option>
              <el-option label="血糖" value="血糖"></el-option>
              <el-option label="体重" value="体重"></el-option>
              <el-option label="心率" value="心率"></el-option>
            </el-select>
          </div>
          
          <el-table :data="filteredRecords" stripe size="large" class="health-table">
            <el-table-column prop="date" label="日期" width="120">
              <template slot-scope="scope">
                <i class="el-icon-time"></i>
                <span>{{ scope.row.date }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="type" label="指标类型" width="100"/>
            <el-table-column prop="value" label="数值" width="120">
              <template slot-scope="scope">
                <span :style="{color: getValueColor(scope.row)}">{{ scope.row.value }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template slot-scope="scope">
                <el-tag :type="getTagType(scope.row.status)">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="note" label="备注"/>
            <el-table-column label="操作" width="100">
              <template slot-scope="scope">
                <el-button type="text" size="small" @click="editRecord(scope.row)">编辑</el-button>
                <el-button type="text" size="small" @click="deleteRecord(scope.row)" style="color: #f56c6c;">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <!-- 图表分析 -->
      <el-tab-pane label="图表分析" name="chart">
        <div class="chart-section">
          <p style="text-align: center; color: #999; padding: 50px;">
            图表功能开发中，敬请期待...
          </p>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 添加记录对话框 -->
    <el-dialog title="添加健康记录" :visible.sync="showAddDialog" width="500px">
      <el-form :model="newRecord" :rules="formRules" ref="recordForm" label-width="80px">
        <el-form-item label="指标类型" prop="type">
          <el-select v-model="newRecord.type" placeholder="请选择指标类型" style="width: 100%">
            <el-option label="血压" value="血压"></el-option>
            <el-option label="血糖" value="血糖"></el-option>
            <el-option label="体重" value="体重"></el-option>
            <el-option label="心率" value="心率"></el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="数值" prop="value">
          <el-input 
            v-model="newRecord.value" 
            :placeholder="getPlaceholder(newRecord.type)"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="测量时间" prop="date">
          <el-date-picker
            v-model="newRecord.datetime"
            type="datetime"
            placeholder="选择测量时间"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="备注">
          <el-input 
            v-model="newRecord.note" 
            type="textarea" 
            :rows="3"
            placeholder="记录当时的身体状况、服药情况等"
          />
        </el-form-item>
      </el-form>
      
      <div slot="footer">
        <el-button @click="showAddDialog = false" size="large">取消</el-button>
        <el-button type="primary" @click="saveRecord" size="large">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'Health',
  data() {
    return {
      activeTab: 'history',
      showAddDialog: false,
      dateRange: [],
      selectedType: '',
      newRecord: {
        type: '',
        value: '',
        datetime: new Date(),
        note: ''
      },
      formRules: {
        type: [{ required: true, message: '请选择指标类型', trigger: 'change' }],
        value: [{ required: true, message: '请输入数值', trigger: 'blur' }],
        date: [{ required: true, message: '请选择测量时间', trigger: 'change' }]
      },
      healthRecords: [
        { id: 1, date: '2024-12-19', type: '血压', value: '130/85 mmHg', status: '偏高', note: '早晨测量' },
        { id: 2, date: '2024-12-19', type: '血糖', value: '6.2 mmol/L', status: '正常', note: '餐后2小时' },
        { id: 3, date: '2024-12-18', type: '体重', value: '68.5 kg', status: '正常', note: '' },
        { id: 4, date: '2024-12-18', type: '心率', value: '72 次/分', status: '正常', note: '静息心率' },
        { id: 5, date: '2024-12-17', type: '血压', value: '125/82 mmHg', status: '正常', note: '晚上测量' }
      ],
      healthOverview: [
        { 
          type: 'blood_pressure', 
          name: '血压', 
          value: '130/85 mmHg', 
          status: '偏高',
          icon: 'el-icon-monitor',
          color: '#f39c12'
        },
        { 
          type: 'blood_sugar', 
          name: '血糖', 
          value: '6.2 mmol/L', 
          status: '正常',
          icon: 'el-icon-connection',
          color: '#27ae60'
        },
        { 
          type: 'weight', 
          name: '体重', 
          value: '68.5 kg', 
          status: '正常',
          icon: 'el-icon-scale-to-original',
          color: '#3498db'
        },
        { 
          type: 'heart_rate', 
          name: '心率', 
          value: '72 次/分', 
          status: '正常',
          icon: 'el-icon-cpu',
          color: '#e74c3c'
        }
      ],
      healthSuggestions: [
        { id: 1, text: '血压偏高，建议减少盐分摄入，多吃蔬菜水果', icon: 'el-icon-warning', color: '#f39c12' },
        { id: 2, text: '坚持每天散步30分钟，有助于控制血压', icon: 'el-icon-success', color: '#27ae60' },
        { id: 3, text: '定期监测血糖，保持饮食规律', icon: 'el-icon-info', color: '#3498db' },
        { id: 4, text: '保持充足睡眠，避免过度劳累', icon: 'el-icon-moon', color: '#9b59b6' }
      ]
    }
  },
  computed: {
    filteredRecords() {
      let records = [...this.healthRecords]
      
      // 按日期筛选
      if (this.dateRange && this.dateRange.length === 2) {
        const [startDate, endDate] = this.dateRange
        records = records.filter(record => {
          const recordDate = new Date(record.date)
          return recordDate >= startDate && recordDate <= endDate
        })
      }
      
      // 按类型筛选
      if (this.selectedType) {
        records = records.filter(record => record.type === this.selectedType)
      }
      
      return records.sort((a, b) => new Date(b.date) - new Date(a.date))
    }
  },
  methods: {
    getStatusColor(status) {
      const colorMap = {
        '正常': '#27ae60',
        '偏高': '#f39c12',
        '偏低': '#3498db',
        '异常': '#e74c3c'
      }
      return colorMap[status] || '#95a5a6'
    },
    getValueColor(record) {
      return this.getStatusColor(record.status)
    },
    getTagType(status) {
      const typeMap = {
        '正常': 'success',
        '偏高': 'warning',
        '偏低': 'info',
        '异常': 'danger'
      }
      return typeMap[status] || 'info'
    },
    getPlaceholder(type) {
      const placeholderMap = {
        '血压': '例如：120/80',
        '血糖': '例如：6.1',
        '体重': '例如：65.5',
        '心率': '例如：75'
      }
      return placeholderMap[type] || '请输入数值'
    },
    filterRecords() {
      // 筛选逻辑在computed中处理
    },
    saveRecord() {
      this.$refs.recordForm.validate((valid) => {
        if (valid) {
          const record = {
            id: Date.now(),
            date: this.newRecord.datetime.toISOString().split('T')[0],
            type: this.newRecord.type,
            value: this.newRecord.value,
            status: this.calculateStatus(this.newRecord.type, this.newRecord.value),
            note: this.newRecord.note
          }
          
          this.healthRecords.unshift(record)
          this.updateOverview()
          
          this.$message.success('记录添加成功！')
          this.showAddDialog = false
          this.resetForm()
        }
      })
    },
    calculateStatus(type, value) {
      // 简单的状态判断逻辑
      if (type === '血压') {
        const [systolic] = value.split('/').map(v => parseInt(v))
        if (systolic < 120) return '正常'
        if (systolic < 140) return '偏高'
        return '异常'
      }
      if (type === '血糖') {
        const glucose = parseFloat(value)
        if (glucose < 6.1) return '正常'
        if (glucose < 7.0) return '偏高'
        return '异常'
      }
      return '正常'
    },
    updateOverview() {
      // 更新今日概览数据
      const today = new Date().toISOString().split('T')[0]
      const todayRecords = this.healthRecords.filter(record => record.date === today)
      
      this.healthOverview.forEach(item => {
        const record = todayRecords.find(r => r.type === item.name)
        if (record) {
          item.value = record.value
          item.status = record.status
        }
      })
    },
    resetForm() {
      this.newRecord = {
        type: '',
        value: '',
        datetime: new Date(),
        note: ''
      }
      this.$refs.recordForm.resetFields()
    },
    editRecord(record) {
      this.$message.info('编辑功能开发中...')
    },
    deleteRecord(record) {
      this.$confirm('确定要删除这条记录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const index = this.healthRecords.findIndex(r => r.id === record.id)
        if (index > -1) {
          this.healthRecords.splice(index, 1)
          this.$message.success('删除成功！')
          this.updateOverview()
        }
      }).catch(() => {
        this.$message.info('已取消删除')
      })
    }
  }
}
</script>

<style lang="stylus" scoped>
.health-container {
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

.quick-operations {
  text-align: center;
  margin-bottom: 30px;
  
  .add-btn, .view-btn {
    margin: 0 10px;
    min-width: 120px;
    height: 50px;
    font-size: 16px;
  }
}

.today-overview {
  margin-bottom: 30px;
  
  h3 {
    font-size: 20px;
    color: #2d3436;
    margin-bottom: 20px;
    text-align: center;
  }
}

.health-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.health-item {
  text-align: center;
  padding: 20px;
  transition: transform 0.3s ease;
  
  &:hover {
    transform: translateY(-5px);
  }
  
  .health-icon {
    font-size: 36px;
    margin-bottom: 15px;
  }
  
  .health-name {
    font-size: 16px;
    color: #636e72;
    margin-bottom: 8px;
  }
  
  .health-value {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 5px;
  }
  
  .health-status {
    font-size: 14px;
    font-weight: bold;
  }
}

.health-suggestions {
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
    font-size: 20px;
    margin-right: 8px;
    color: #f39c12;
  }
}

.suggestions-content {
  .suggestion-item {
    display: flex;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid #eee;
    
    &:last-child {
      border-bottom: none;
    }
    
    .suggestion-icon {
      font-size: 18px;
      margin-right: 12px;
      min-width: 20px;
    }
    
    .suggestion-text {
      color: #2d3436;
      line-height: 1.5;
    }
  }
}

.health-tabs {
  margin-top: 20px;
}

.history-section {
  .filter-controls {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }
}

.health-table {
  font-size: 14px;
}

.chart-section {
  min-height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

// 响应式设计
@media (max-width: 768px) {
  .health-container {
    padding: 15px;
  }
  
  .page-header h2 {
    font-size: 24px;
  }
  
  .health-cards {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  }
  
  .filter-controls {
    flex-direction: column;
    
    .el-date-picker, .el-select {
      width: 100% !important;
    }
  }
  
  .quick-operations {
    .add-btn, .view-btn {
      margin: 5px;
      width: 150px;
    }
  }
}
</style>