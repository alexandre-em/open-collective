<template>
  <div class="home-wrapper">
    <div class="listHistoryProject" v-for="item in key.contributor" v-bind:value="item" :key="item">{{item}}</div>
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
  name: 'RecapProject',
  //components: { Card, CollectiveButton, Spacer },
  components:{Card, NewButton},
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const connect = () => store.dispatch('ethereumConnect')
    return { address, connect }
  },
    data(){
        const nbContributor = 0
        const isActivated = false
        const listAdress : string[] = ["daji133fujv","kndaizo331ejio1","an1zedk456d11"]
        const listContributor : string[] = ["test"]
        //"daji133fujv" : new Date("2015-03-25"), "kndaizo331ejio1" : new Date("2020-03-25")
        interface History {
        date: Date;
        type: any;
        }

        interface Contributor{
            type: string;
            address: string;
        }
        interface Bounties{
            type: string;
            name: string;
            reward: number;
        }
        

        const listHistoryProject : {[key:string] : History[] } = {"Projet 1": [
            {date:new Date("1-1-2021"),type: {type:"Contributor","adress":"0xikodazjhiodaz"}},
            {date:new Date("1-1-2021"),type: {type:"Bounties",name: "bounties1",reward: 5}},
        
        ]}
      
      
        return {nbContributor, isActivated, listContributor, listHistoryProject}
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



</style>
