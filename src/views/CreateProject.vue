<template>
  <div class="home-wrapper">
    <card title="Create a new project" :blue="true">
      <div class="container-card">
        <div class="sub-container">
          <input
            type="text"
            id="project-name-input"
            placeholder="Project name"
            v-model="projectName"
          />
        </div>

        <div>List of contributors</div>
        <div class="box-container">
          <div class="box-item" v-for="item in listContributor" :key="item">
            {{ item }}
          </div>
        </div>
      </div>
      <div class="container-card">
        <div v-if="!this.isActivated">
          <new-button
            v-on:click="eventButtonContributor"
            title="Add contributor"
          ></new-button>
        </div>

        <div v-if="this.isActivated">
          <h3>Add Contributor</h3>
          <form v-on:submit.prevent="addContributor(option, index)">
            <input
              type="text"
              id="project-name-input"
              placeholder="Contributor address"
              v-model="toAdd"
            />
            <div class="add-contributors-buttons">
              <collective-button type="submit">Add address</collective-button>
              <collective-button v-on:click="eventButtonContributor">
                Cancel
              </collective-button>
            </div>
          </form>
        </div>

        <new-button title="Submit" @click="handleSubmit"></new-button>
      </div>
    </card>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import NewButton from '@/components/NewButton.vue'
import CollectiveButton from '@/components/CollectiveButton.vue'

export default defineComponent({
  components: { Card, CollectiveButton, NewButton },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    const connect = () => store.dispatch('ethereumConnect')
    return { address, balance, contract, connect }
  },
  data() {
    const nbContributor = 0
    const projectName = ''
    const isActivated = false
    const listAdress: string[] = [
      'daji133fujv',
      'kndaizo331ejio1',
      'an1zedk456d11',
    ]
    const listContributor: string[] = []
    const toAdd = ''
    return {
      nbContributor,
      isActivated,
      listContributor,
      listAdress,
      toAdd,
      projectName,
    }
  },
  methods: {
    goToAccount() {
      this.$router.push({ name: 'Account' })
    },
    eventButtonContributor() {
      this.isActivated = !this.isActivated
    },
    addContributor() {
      this.listContributor.push(this.toAdd)
      this.isActivated = !this.isActivated
    },
    async handleSubmit() {
      const project = await this.contract.methods
        .createProject(this.projectName)
        .send({ from: this.address, value: 2000 })
      this.listContributor.forEach(async contributor => {
        await this.contract.methods.addContributor(
          project.projectID,
          contributor
        )
      })
      console.log('created')
    },
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
.container-card {
  margin: 1em;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.box-container {
  display: flex;
  flex-direction: row;
}
.box-item {
  border: solid;
  width: min-content;
  padding: 5px;
  margin: 5px;
  border-radius: 5px;
}

#project-name-input {
  border-radius: 5px;
  border-style: none;
  height: min-content;
  outline-style: none;
  padding: 10px;
  margin: 10px;
  width: 100%;
}

.add-contributors-buttons {
  display: flex;
  width: 100%;
  background-color: aliceblue;
}
</style>
