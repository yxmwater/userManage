<template>
    <div>
        <p>标题</p>
        <input type="text" v-model="title"/>
        <p>内容</p>
        <input type="text" v-model="content"/>
        <div class="btn" @click="add()">添加</div>
        <el-row>
            <el-button>默认按钮</el-button>
            <el-button type="primary">主要按钮</el-button>
            <el-button type="success">成功按钮</el-button>
            <el-button type="info">信息按钮</el-button>
            <el-button type="warning">警告按钮</el-button>
            <el-button type="danger">危险按钮</el-button>
        </el-row>
    </div>
</template>

<script>
    import  store from '@/store.js'
    export default {
        name: "add",
        store,
        data(){
            return {
                title:'',
                content:''
            }
        },
        methods:{
            add(){
                store.commit('addItem',{
                    title:this.title,
                    content:this.content
                })
                this.title ='';
                this.content ='';
                this.$router.push('/home/list')

            }
        }
    }
</script>

<style scoped>

</style>