<template>
  <div class="medicine-container">
    <div class="page-header">
      <h2>用药提醒</h2>
      <p>合理用药，健康生活</p>
    </div>

    <!-- 今日用药概览 -->
    <div class="today-overview">
      <el-card shadow="hover" class="overview-card">
        <div class="card-header">
          <i class="el-icon-time"></i>
          <span>今日用药提醒</span>
        </div>
        <div class="today-medicines">
          <div v-if="todayMedicines.length > 0" class="medicine-timeline">
            <div 
              v-for="medicine in todayMedicines" 
              :key="medicine.id"
              class="timeline-item"
              :class="{ 'completed': medicine.taken, 'overdue': isOverdue(medicine) }"
            >
              <div class="timeline-time">{{ medicine.time }}</div>
              <div class="timeline-content">
                <div class="medicine-info">
                  <div class="medicine-name">{{ medicine.name }}</div>
                  <div class="medicine-dose">{{ medicine.dose }}</div>
                  <div class="medicine-type">{{ medicine.type }}</div>
                </div>
                <div class="timeline-actions">
                  <el-button 
                    v-if="!medicine.taken"
                    type="success" 
                    size="small"
                    @click="markAsTaken(medicine)"
                  >
                    已服用
                  </el-button>
                  <el-tag v-else type="success">已完成</el-tag>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="no-medicines">
            <p>今天暂无用药提醒</p>
            <p>保持健康，快乐每一天！</p>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 功能区域 -->
    <div class="function-area">
      <el-button 
        type="primary" 
        size="large" 
        icon="el-icon-plus"
        @click="showAddDialog = true"
        class="action-btn"
      >
        添加用药
      </el-button>
      <el-button 
        type="success" 
        size="large" 
        icon="el-icon-success"
        @click="activeTab = 'supplements'"
        class="action-btn"
      >
        保健品管理
      </el-button>
      <el-button 
        type="info" 
        size="large" 
        icon="el-icon-view"
        @click="activeTab = 'history'"
        class="action-btn"
      >
        服药记录
      </el-button>
    </div>

    <!-- Tab切换 -->
    <el-tabs v-model="activeTab" class="medicine-tabs">
      <!-- 药品管理 -->
      <el-tab-pane label="药品管理" name="medicines">
        <div class="medicines-section">
          <div class="medicines-grid">
            <el-card 
              v-for="medicine in medicines" 
              :key="medicine.id" 
              shadow="hover" 
              class="medicine-card"
            >
              <div class="medicine-header">
                <div class="medicine-title">{{ medicine.name }}</div>
                <div class="medicine-status" :class="medicine.status">{{ medicine.status }}</div>
              </div>
              <div class="medicine-details">
                <div class="detail-item">
                  <i class="el-icon-time"></i>
                  <span>{{ medicine.schedule }}</span>
                </div>
                <div class="detail-item">
                  <i class="el-icon-document"></i>
                  <span>{{ medicine.dose }}</span>
                </div>
                <div class="detail-item">
                  <i class="el-icon-date"></i>
                  <span>剩余 {{ medicine.remaining }} 天</span>
                </div>
              </div>
              <div class="medicine-actions">
                <el-button type="text" @click="editMedicine(medicine)">编辑</el-button>
                <el-button type="text" @click="deleteMedicine(medicine)" style="color: #f56c6c;">删除</el-button>
              </div>
            </el-card>
          </div>
        </div>
      </el-tab-pane>

      <!-- 保健品管理 -->
      <el-tab-pane label="保健品管理" name="supplements">
        <div class="supplements-section">
          <div class="add-supplement">
            <el-button 
              type="success" 
              icon="el-icon-plus"
              @click="showSupplementDialog = true"
            >
              添加保健品
            </el-button>
          </div>
          <div class="supplements-grid">
            <el-card 
              v-for="supplement in supplements" 
              :key="supplement.id" 
              shadow="hover" 
              class="supplement-card"
            >
              <div class="supplement-header">
                <div class="supplement-title">{{ supplement.name }}</div>
                <el-tag :type="getSupplementTagType(supplement.type)">{{ supplement.type }}</el-tag>
              </div>
              <div class="supplement-details">
                <div class="detail-item">
                  <i class="el-icon-time"></i>
                  <span>{{ supplement.schedule }}</span>
                </div>
                <div class="detail-item">
                  <i class="el-icon-document"></i>
                  <span>{{ supplement.dose }}</span>
                </div>
                <div class="detail-item">
                  <i class="el-icon-info"></i>
                  <span>{{ supplement.description }}</span>
                </div>
              </div>
              <div class="supplement-actions">
                <el-button type="text" @click="editSupplement(supplement)">编辑</el-button>
                <el-button type="text" @click="deleteSupplement(supplement)" style="color: #f56c6c;">删除</el-button>
              </div>
            </el-card>
          </div>
        </div>
      </el-tab-pane>

      <!-- 服药记录 -->
      <el-tab-pane label="服药记录" name="history">
        <div class="history-section">
          <div class="filter-controls">
            <el-date-picker
              v-model="historyDateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              size="large"
            />
            <el-select v-model="historyFilter" placeholder="选择类型" size="large">
              <el-option label="全部" value=""></el-option>
              <el-option label="药品" value="药品"></el-option>
              <el-option label="保健品" value="保健品"></el-option>
            </el-select>
          </div>
          
          <el-table :data="filteredHistory" stripe size="large" class="history-table">
            <el-table-column prop="date" label="日期" width="120"/>
            <el-table-column prop="time" label="时间" width="100"/>
            <el-table-column prop="name" label="名称" width="150"/>
            <el-table-column prop="type" label="类型" width="100">
              <template slot-scope="scope">
                <el-tag :type="scope.row.type === '药品' ? 'primary' : 'success'">
                  {{ scope.row.type }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="dose" label="剂量"/>
            <el-table-column prop="status" label="状态" width="100">
              <template slot-scope="scope">
                <el-tag :type="scope.row.status === '已服用' ? 'success' : 'danger'">
                  {{ scope.row.status }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 添加药品对话框 -->
    <el-dialog title="添加药品" :visible.sync="showAddDialog" width="500px">
      <el-form :model="newMedicine" :rules="medicineRules" ref="medicineForm" label-width="80px">
        <el-form-item label="药品名称" prop="name">
          <el-input v-model="newMedicine.name" placeholder="请输入药品名称"/>
        </el-form-item>
        
        <el-form-item label="服用剂量" prop="dose">
          <el-input v-model="newMedicine.dose" placeholder="例如：1片、10ml"/>
        </el-form-item>
        
        <el-form-item label="服用时间" prop="schedule">
          <el-checkbox-group v-model="newMedicine.times">
            <el-checkbox label="08:00">早上 08:00</el-checkbox>
            <el-checkbox label="12:00">中午 12:00</el-checkbox>
            <el-checkbox label="18:00">下午 18:00</el-checkbox>
            <el-checkbox label="22:00">晚上 22:00</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        
        <el-form-item label="用药天数" prop="duration">
          <el-input-number v-model="newMedicine.duration" :min="1" :max="365"/>
        </el-form-item>
        
        <el-form-item label="备注">
          <el-input 
            v-model="newMedicine.note" 
            type="textarea" 
            :rows="3"
            placeholder="服药注意事项、医生建议等"
          />
        </el-form-item>
      </el-form>
      
      <div slot="footer">
        <el-button @click="showAddDialog = false" size="large">取消</el-button>
        <el-button type="primary" @click="saveMedicine" size="large">保存</el-button>
      </div>
    </el-dialog>

    <!-- 添加保健品对话框 -->
    <el-dialog title="添加保健品" :visible.sync="showSupplementDialog" width="500px">
      <el-form :model="newSupplement" :rules="supplementRules" ref="supplementForm" label-width="80px">
        <el-form-item label="保健品名称" prop="name">
          <el-input v-model="newSupplement.name" placeholder="请输入保健品名称"/>
        </el-form-item>
        
        <el-form-item label="类型" prop="type">
          <el-select v-model="newSupplement.type" placeholder="选择类型" style="width: 100%">
            <el-option label="维生素" value="维生素"/>
            <el-option label="钙片" value="钙片"/>
            <el-option label="鱼油" value="鱼油"/>
            <el-option label="蛋白粉" value="蛋白粉"/>
            <el-option label="其他" value="其他"/>
          </el-select>
        </el-form-item>
        
        <el-form-item label="服用剂量" prop="dose">
          <el-input v-model="newSupplement.dose" placeholder="例如：2粒、1勺"/>
        </el-form-item>
        
        <el-form-item label="服用时间" prop="schedule">
          <el-radio-group v-model="newSupplement.schedule">
            <el-radio label="餐前服用">餐前服用</el-radio>
            <el-radio label="餐后服用">餐后服用</el-radio>
            <el-radio label="睡前服用">睡前服用</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item label="功效描述">
          <el-input 
            v-model="newSupplement.description" 
            type="textarea" 
            :rows="2"
            placeholder="简述保健品的主要功效"
          />
        </el-form-item>
      </el-form>
      
      <div slot="footer">
        <el-button @click="showSupplementDialog = false" size="large">取消</el-button>
        <el-button type="primary" @click="saveSupplement" size="large">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'Medicine',
  data() {
    return {
      activeTab: 'medicines',
      showAddDialog: false,
      showSupplementDialog: false,
      historyDateRange: [],
      historyFilter: '',
      newMedicine: {
        name: '',
        dose: '',
        times: [],
        duration: 30,
        note: ''
      },
      newSupplement: {
        name: '',
        type: '',
        dose: '',
        schedule: '',
        description: ''
      },
      medicineRules: {
        name: [{ required: true, message: '请输入药品名称', trigger: 'blur' }],
        dose: [{ required: true, message: '请输入服用剂量', trigger: 'blur' }],
        times: [{ required: true, message: '请选择服用时间', trigger: 'change' }]
      },
      supplementRules: {
        name: [{ required: true, message: '请输入保健品名称', trigger: 'blur' }],
        type: [{ required: true, message: '请选择类型', trigger: 'change' }],
        dose: [{ required: true, message: '请输入服用剂量', trigger: 'blur' }]
      },
      todayMedicines: [
        { id: 1, time: '08:00', name: '降压药', dose: '1片', type: '药品', taken: true },
        { id: 2, time: '12:00', name: '维生素C', dose: '2粒', type: '保健品', taken: false },
        { id: 3, time: '18:00', name: '降压药', dose: '1片', type: '药品', taken: false },
        { id: 4, time: '20:00', name: '钙片', dose: '1粒', type: '保健品', taken: false }
      ],
      medicines: [
        { id: 1, name: '硝苯地平缓释片', dose: '1片/次', schedule: '每日2次', remaining: 25, status: '正常' },
        { id: 2, name: '阿司匹林', dose: '100mg/次', schedule: '每日1次', remaining: 45, status: '正常' },
        { id: 3, name: '二甲双胍', dose: '0.5g/次', schedule: '每日3次', remaining: 5, status: '库存不足' }
      ],
      supplements: [
        { id: 1, name: '复合维生素', type: '维生素', dose: '1粒/次', schedule: '餐后服用', description: '补充多种维生素和矿物质' },
        { id: 2, name: '液体钙', type: '钙片', dose: '10ml/次', schedule: '睡前服用', description: '补充钙质，强健骨骼' },
        { id: 3, name: '深海鱼油', type: '鱼油', dose: '2粒/次', schedule: '餐后服用', description: '补充Omega-3，保护心血管' }
      ],
      medicineHistory: [
        { date: '2024-12-19', time: '08:00', name: '降压药', type: '药品', dose: '1片', status: '已服用' },
        { date: '2024-12-19', time: '12:00', name: '维生素C', type: '保健品', dose: '2粒', status: '已服用' },
        { date: '2024-12-18', time: '18:00', name: '降压药', type: '药品', dose: '1片', status: '已服用' },
        { date: '2024-12-18', time: '20:00', name: '钙片', type: '保健品', dose: '1粒', status: '已服用' }
      ]
    }
  },
  computed: {
    filteredHistory() {
      let history = [...this.medicineHistory]
      
      // 按日期筛选
      if (this.historyDateRange && this.historyDateRange.length === 2) {
        const [startDate, endDate] = this.historyDateRange
        history = history.filter(record => {
          const recordDate = new Date(record.date)
          return recordDate >= startDate && recordDate <= endDate
        })
      }
      
      // 按类型筛选
      if (this.historyFilter) {
        history = history.filter(record => record.type === this.historyFilter)
      }
      
      return history.sort((a, b) => {
        const dateA = new Date(a.date + ' ' + a.time)
        const dateB = new Date(b.date + ' ' + b.time)
        return dateB - dateA
      })
    }
  },
  methods: {
    isOverdue(medicine) {
      const now = new Date()
      const [hour, minute] = medicine.time.split(':').map(Number)
      const medicineTime = new Date()
      medicineTime.setHours(hour, minute, 0, 0)
      return now > medicineTime && !medicine.taken
    },
    markAsTaken(medicine) {
      medicine.taken = true
      this.medicineHistory.unshift({
        date: new Date().toISOString().split('T')[0],
        time: medicine.time,
        name: medicine.name,
        type: medicine.type,
        dose: medicine.dose,
        status: '已服用'
      })
      this.$message.success('已标记为完成！')
    },
    getSupplementTagType(type) {
      const typeMap = {
        '维生素': 'success',
        '钙片': 'warning',
        '鱼油': 'primary',
        '蛋白粉': 'info',
        '其他': 'default'
      }
      return typeMap[type] || 'default'
    },
    saveMedicine() {
      this.$refs.medicineForm.validate((valid) => {
        if (valid) {
          const medicine = {
            id: Date.now(),
            name: this.newMedicine.name,
            dose: this.newMedicine.dose,
            schedule: `每日${this.newMedicine.times.length}次`,
            remaining: this.newMedicine.duration,
            status: '正常'
          }
          
          this.medicines.push(medicine)
          this.$message.success('药品添加成功！')
          this.showAddDialog = false
          this.resetMedicineForm()
        }
      })
    },
    saveSupplement() {
      this.$refs.supplementForm.validate((valid) => {
        if (valid) {
          const supplement = {
            id: Date.now(),
            ...this.newSupplement
          }
          
          this.supplements.push(supplement)
          this.$message.success('保健品添加成功！')
          this.showSupplementDialog = false
          this.resetSupplementForm()
        }
      })
    },
    resetMedicineForm() {
      this.newMedicine = {
        name: '',
        dose: '',
        times: [],
        duration: 30,
        note: ''
      }
      this.$refs.medicineForm.resetFields()
    },
    resetSupplementForm() {
      this.newSupplement = {
        name: '',
        type: '',
        dose: '',
        schedule: '',
        description: ''
      }
      this.$refs.supplementForm.resetFields()
    },
    editMedicine(medicine) {
      this.$message.info('编辑功能开发中...')
    },
    deleteMedicine(medicine) {
      this.$confirm('确定要删除这个药品吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const index = this.medicines.findIndex(m => m.id === medicine.id)
        if (index > -1) {
          this.medicines.splice(index, 1)
          this.$message.success('删除成功！')
        }
      }).catch(() => {
        this.$message.info('已取消删除')
      })
    },
    editSupplement(supplement) {
      this.$message.info('编辑功能开发中...')
    },
    deleteSupplement(supplement) {
      this.$confirm('确定要删除这个保健品吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const index = this.supplements.findIndex(s => s.id === supplement.id)
        if (index > -1) {
          this.supplements.splice(index, 1)
          this.$message.success('删除成功！')
        }
      }).catch(() => {
        this.$message.info('已取消删除')
      })
    }
  }
}
</script>

<style lang="stylus" scoped>
.medicine-container {
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

.today-overview {
  margin-bottom: 30px;
}

.overview-card {
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
      color: #e17055;
    }
  }
}

.medicine-timeline {
  .timeline-item {
    display: flex;
    padding: 15px;
    margin-bottom: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    border-left: 4px solid #74b9ff;
    transition: all 0.3s ease;
    
    &.completed {
      border-left-color: #00b894;
      background: #d1f2eb;
    }
    
    &.overdue {
      border-left-color: #e17055;
      background: #ffe6e1;
    }
    
    .timeline-time {
      font-size: 18px;
      font-weight: bold;
      color: #2d3436;
      margin-right: 20px;
      min-width: 60px;
    }
    
    .timeline-content {
      flex: 1;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .medicine-info {
      .medicine-name {
        font-size: 16px;
        font-weight: bold;
        color: #2d3436;
        margin-bottom: 5px;
      }
      
      .medicine-dose {
        font-size: 14px;
        color: #636e72;
        margin-bottom: 3px;
      }
      
      .medicine-type {
        font-size: 12px;
        color: #74b9ff;
      }
    }
  }
}

.no-medicines {
  text-align: center;
  color: #636e72;
  padding: 40px 20px;
  
  p {
    margin: 8px 0;
    font-size: 16px;
  }
}

.function-area {
  text-align: center;
  margin-bottom: 30px;
  
  .action-btn {
    margin: 0 10px;
    min-width: 130px;
    height: 50px;
    font-size: 16px;
  }
}

.medicine-tabs {
  margin-top: 20px;
}

.medicines-grid, .supplements-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.medicine-card, .supplement-card {
  .medicine-header, .supplement-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    
    .medicine-title, .supplement-title {
      font-size: 16px;
      font-weight: bold;
      color: #2d3436;
    }
    
    .medicine-status {
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      
      &.正常 {
        background: #d1f2eb;
        color: #00b894;
      }
      
      &.库存不足 {
        background: #ffe6e1;
        color: #e17055;
      }
    }
  }
  
  .medicine-details, .supplement-details {
    margin-bottom: 15px;
    
    .detail-item {
      display: flex;
      align-items: center;
      margin-bottom: 8px;
      font-size: 14px;
      color: #636e72;
      
      i {
        margin-right: 8px;
        color: #74b9ff;
        min-width: 16px;
      }
    }
  }
  
  .medicine-actions, .supplement-actions {
    text-align: right;
    
    .el-button {
      margin-left: 8px;
    }
  }
}

.add-supplement {
  margin-bottom: 20px;
  text-align: center;
}

.history-section {
  .filter-controls {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }
}

.history-table {
  font-size: 14px;
}

// 响应式设计
@media (max-width: 768px) {
  .medicine-container {
    padding: 15px;
  }
  
  .page-header h2 {
    font-size: 24px;
  }
  
  .function-area {
    .action-btn {
      margin: 5px;
      width: 140px;
    }
  }
  
  .medicines-grid, .supplements-grid {
    grid-template-columns: 1fr;
  }
  
  .timeline-item {
    flex-direction: column;
    
    .timeline-time {
      margin-bottom: 10px;
    }
    
    .timeline-content {
      flex-direction: column;
      align-items: flex-start;
      
      .timeline-actions {
        margin-top: 10px;
        align-self: flex-end;
      }
    }
  }
  
  .filter-controls {
    flex-direction: column;
    
    .el-date-picker, .el-select {
      width: 100% !important;
    }
  }
}
</style>