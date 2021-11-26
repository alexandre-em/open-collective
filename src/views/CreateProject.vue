<template>
  <div class="home-wrapper">
    <card
        v-if="!address"
        title="Add new contributor"
        :blue="true"
    >
    <div class="container-card">
        <div class="sub-container"> Name : <input /></div>
        <div class="sub-container"> Balance : <input type="Number" /></div>
        

        <div>List of contributor</div>
        <div class=box-container>
             <div class="box-item" v-for="item in listContributor" :key="item">
                {{item}}
            </div>
        </div>
    </div> 
        <div v-if="!this.isActivated">
            <new-button v-on:click="eventButtonContributor" title="Add contributor"></new-button>
        </div>

        <div v-if="this.isActivated">
            <h3>Add Contributor</h3>
            <form v-on:submit.prevent="addContributor(option,index)">
                <!--Adress of contributor :<input type="text" v-model="adress">-->
                <select name="adress" id="adress-select" v-model="option">
                    <option value="">--Please choose an adress--</option>
                     <option v-for="(option, index)  in listAdress" v-bind:value="option" :key="index">
                         {{ option }}
                    </option>
                </select>
                <button type="submit">Add adress</button>
                <button v-on:click="eventButtonContributor">Cancel</button>
            </form>
        </div>


    
        <new-button title="Submit"></new-button>
      </card>
      
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
  name: 'CreateProject',
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
      return {nbContributor, isActivated, listContributor, listAdress}
  },
  computed: {
    
  },
  methods: {
    goToAccount() {
      this.$router.push({ name: 'Account' })
    },
    eventButtonContributor() {
        this.isActivated = !this.isActivated
    },
    addContributor(adress : string, index : number) {
        this.listContributor.push(adress)
        this.isActivated = !this.isActivated
        this.listAdress.splice(index, 1);
    }



  },
})
</script>

<style lang="css" scoped>
.home-wrapper {
  margin: auto 24px auto 24px;
}

.home {
  display: grid;
  align-items: center;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  grid-gap: 24px;
}

.card-body {
  padding: 12px;
  display: block;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}
.container-card{
    margin: 1em;
}
.box-container{
    display: flex;
    flex-direction: row;
}
.box-item{
    border: solid;
    width:min-content;
    padding:5px;
    margin:5px;
    border-radius: 5px;
}


</style>
