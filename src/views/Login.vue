<template>
    <div class="loginPage">
        <el-form  label-width="80px" v-if="!isReg" label-position="left">
            <el-form-item>
                <el-input placeholder="请输入用户名" v-model="name">
                    <template slot="prepend">用户名</template>
                </el-input>
            </el-form-item>

            <el-form-item>
                <el-input type="password" placeholder="请输入密码" v-model="password">
                    <template slot="prepend">密  码</template>
                </el-input>
            </el-form-item>
            <el-form-item>
                <el-button type="primary" round="true" @click="login">登录</el-button>
                <el-button type="warning" round="true" @click="reg">注册</el-button>
            </el-form-item>
        </el-form>
        <el-form status-icon label-width="80px" v-else>
            <el-form-item label="用户名" prop="name">
                <el-input v-model="name" placeholder="请输入用户名"></el-input>
            </el-form-item>
            <el-form-item label="密码" prop="password">
                <el-input type="password" v-model="password" placeholder="请输入密码"></el-input>
            </el-form-item>
            <el-form-item label="确认密码" prop="repeat">
                <el-input type="password" v-model="repeat" placeholder="请再次输入密码"></el-input>
            </el-form-item>
            <el-form-item>
                <el-button type="primary" @click="addUser">确定</el-button>
                <el-button type="info" @click="cancel">取消</el-button>
            </el-form-item>
        </el-form>
    </div>
</template>

<script>
    export default {
        name: "login",
        data(){
            return{
                isReg:false,
                name:'',
                password:'',
                repeat:''
            }
        },
        methods:{
            login(){
                if(localStorage.getItem('name')===this.name
                && localStorage.getItem('password')===this.password){
                    this.name=''
                    this.password=''
                    this.$router.push('/home/list')
                }else{
                    alert('用户名或者密码不正确！')
                }

            },
            reg(){
                this.isReg = true;
            },
            cancel(){
                this.isReg = false;
            },
            addUser(){
                if(this.password === this.repeat){
                    localStorage.setItem('name',this.name);
                    localStorage.setItem('password',this.password);
                    this.name='';
                    this.password='';
                    this.isReg = false;
                }else{
                    alert('两次密码输入不一致！')
                }

            }
        }
    }
</script>

<style scoped lang="stylus">
.loginPage{
    width 450px
    margin 150px auto
}

</style>