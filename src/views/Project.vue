<template lang="html">
  <div class="home">
    <div class="card-home-wrapper">
      <card
        :title="`Project ${$route.params.id}`"
        :subtitle="`Balance: ${
          Math.round(project[3] * Math.pow(10, -18) * 100) / 100 || 0
        } ETH\n${project[4]} Contributors`"
        :gradient="true"
      >
        <div class="card-main">
          <projects-view
            :project="project"
            :onAddContributor="handleAddContributor"
            :onCloseProject="handleCloseProject"
            :onSponsoringProject="handleSponsoringProject"
          />
        </div>
      </card>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Web3 from 'web3'

import Card from '@/components/Card.vue'
import ProjectsView from '@/components/ProjectsView.vue'

export default defineComponent({
  components: { Card, ProjectsView },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const project: any[] = []
    const web3 = new Web3(
      new Web3.providers.HttpProvider('http://127.0.0.1:7545')
    )
    return { project, web3 }
  },
  methods: {
    async updateAccount(): Promise<void> {
      const { contract } = this
      this.project = await contract.methods
        .getProjectDetails(this.$route.params.id)
        .call()
    },
    async handleAddContributor(contributor: string): Promise<void> {
      await this.contract.methods
        .addContributor(this.$route.params.id, contributor)
        .send()
      await this.updateAccount()
    },
    async handleCloseProject(): Promise<void> {
      await this.contract.methods.closeProject(this.$route.params.id).send()
      this.$router.push({ name: 'Account' })
    },
    async handleSponsoringProject(amount: number): Promise<void> {
      await this.contract.methods
        .sponsoringProject(this.$route.params.id)
        .send({
          from: this.address,
          value: this.web3.utils.toWei(amount.toString(), 'ether'),
        })
      await this.updateAccount()
    },
  },
  async mounted() {
    const { contract } = this
    const project = await contract.methods
      .getProjectDetails(this.$route.params.id)
      .call()
    console.log(project)
    if (project[project[2].length - 1]) this.project = project
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}
.card-home-wrapper {
  width: 100%;
  height: 100%;
}

.card-main {
  display: flex;
  flex-direction: row;
  height: 100%;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>
