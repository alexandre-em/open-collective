<template>
  <div class="home-wrapper">
    <div class="carte" v-for="key in listProject" v-bind:value="key" :key="key">
        <div class="title">
            <div class="name">{{key.name}}</div>
            <div class="date">{{key.date.toDateString()}}</div>
        </div>

        <div class="listContributor">
            <div class="itemContributor" v-for="item in key.contributor" v-bind:value="item" :key="item">{{item}}</div>
        </div>

    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import CollectiveButton from '@/components/CollectiveButton.vue'
import Spacer from '@/components/Spacer.vue'
import NewButton from '@/components/NewButton.vue'

export default defineComponent({
  name: 'AllProject',
  //components: { Card, CollectiveButton, Spacer },
  //components:{Card, NewButton},
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const connect = () => store.dispatch('ethereumConnect')
    return { address, connect }
  },
  data(){
      const listAdress : string[] = ["daji133fujv","kndaizo331ejio1","an1zedk456d11"]
      //"daji133fujv" : new Date("2015-03-25"), "kndaizo331ejio1" : new Date("2020-03-25")
      interface Project {
        date: Date;
        balance: number;
        contributor: string[];
        name: string;
        }

      const listProject : {[key:string] : Project } = {
          "Projet 1": {date : new Date("2015-03-25"), balance:0, contributor:["0xdaji133fujv","0xkndaizo331ejio1","0xan1zedk456d11","0xid15z5a6ui8hd5u5iq6sjdhuijdf"], name : "Projet 1"},
          "Projet 2": {date : new Date("2020-03-25"), balance:0, contributor:["0xdaji133fujv"],  name : "Projet 2"},
          }
      
      
      return {listAdress,listProject}
  },
  computed: {
    
  },
  methods: {
    goToAccount() {
      this.$router.push({ name: 'Account' })
    },
  },
})
</script>

<style lang="css" scoped>

.title{
    display:flex;
}
.date{
    font-size:10px;
    margin-left: 10px;
    margin-top: 5px;
}

.listContributor{
    display:flex;
    flex-wrap: wrap;
    justify-content: space-between;
}

.itemContributor{
    border: solid;
    border-radius: 3px;
    width:min-content;
    padding-top: 5px;
    padding-bottom: 5px;
    padding-left:20px;
    padding-right: 20px;
}

.carte{
    margin-bottom:20px;
}
</style>
