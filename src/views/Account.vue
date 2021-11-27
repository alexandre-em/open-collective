<template lang="html">
  <div class="home" v-if="!account">
    <form @submit.prevent="signUp">
      <card
        :title="`Enter your ${type} name here`"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="Type your username here"
        />
        <input
          type="number"
          class="input-username"
          v-model="corpBalance"
          placeholder="Your company's balance"
          v-if="type === accountTypes[1]"
        />
        <collective-button :transparent="true">
          Create an account
        </collective-button>
      </card>
    </form>
  </div>
  <div class="home" v-if="account">
    <div class="card-home-wrapper">
      <card
        :title="account.username || account.entrepriseName"
        :subtitle="`${balance} Ξ\t\t${
          account.userBalance || account.entrepriseBalance
        } Tokens`"
        :gradient="true"
      >
        <div class="explanations">
          This data has been fetched from the blockchain. You started by
          connecting MetaMask, and you fetched your data by reading the
          blockchain. Try to modify the code to see what's happening!
        </div>
        <div class="explanations">
          On your account on the contract, you have
          {{ account.balance }} tokens. If you click
          <button class="button-link" @click="addTokens">here</button>, you can
          add some token to your account. Just give it a try! And think to put
          an eye on Ganache!
        </div>
      </card>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import CollectiveButton from '@/components/CollectiveButton.vue'
import { ACCOUNT_TYPE_COMPANY, ACCOUNT_TYPE_USER } from '@/constants/store'

export default defineComponent({
  components: { Card, CollectiveButton },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    const type = computed(() => store.state.account.type)
    return { address, contract, balance, type }
  },
  data() {
    const account = null
    const username = ''
    const corpBalance = 0
    const accountTypes = [ACCOUNT_TYPE_USER, ACCOUNT_TYPE_COMPANY]
    return { account, username, corpBalance, accountTypes }
  },
  methods: {
    async updateAccount() {
      const { address, contract, type } = this
      this.account =
        type === ACCOUNT_TYPE_USER
          ? await contract.methods.user(address).call()
          : await contract.methods.entreprise(address).call()
    },
    async signUp() {
      const { address, contract, username, type } = this
      const name = username.trim().replace(/ /g, '_')
      if (type === ACCOUNT_TYPE_USER) {
        await contract.methods
          .openAccount(name)
          .send({ from: address, value: 50 })
        await this.updateAccount()
      } else {
        await contract.methods
          .openEntreprise(name, this.corpBalance)
          .send({ from: address, value: 500 })
      }
      this.username = ''
    },
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalance(200).send()
      await this.updateAccount()
    },
    async getAccount() {
      const { address, contract } = this
      console.log(await contract.methods.entreprise(address).call())
    },
  },
  async mounted() {
    const { address, contract, type } = this
    this.type = type
    const account =
      type === ACCOUNT_TYPE_USER
        ? await contract.methods.user(address).call()
        : await contract.methods.entreprise(address).call()
    console.log(account)
    if (account.registered) this.account = account
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 500px;
  margin: auto;
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
