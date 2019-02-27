<template>
    <div>
        <button @click="toAdd()">添加</button><br/>
        User
    </div>
</template>

<script>
    export default {
        name: "user",
        methods:{
            toAdd(){
                this.$router.push('/add');
            }
        }
    }
</script>

<style scoped>

</style>