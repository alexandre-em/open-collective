<template lang="html">
  <div class="home" v-if="!account.registered">
    <form @submit.prevent="signUp">
      <card
        :title="`Enter your ${type} name here`"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
        :blue="true"
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
  <div class="home" v-if="account.registered">
    <div class="card-home-wrapper">
      <card
        :title="account.username || `Group: ${account.entrepriseName}`"
        :subtitle="`Balance: ${getBalance()} ETH`"
        :gradient="true"
      >
        <div class="card-main">
          <entreprise-view
            :onCreateProject="handleCreateProject"
            :onGetMemberList="getMemberList"
            :onAddMember="handleAddMember"
            v-if="type === accountTypes[1]"
          />
          <user-view
            v-else-if="type === accountTypes[0]"
            :onChangeName="handleChangeName"
            :onDeposit="handleDeposit"
            :onSend="handleSend"
            :onCreateProject="handleCreateProject"
            :onWithdraw="handleWithdraw"
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
import CollectiveButton from '@/components/CollectiveButton.vue'
import EntrepriseView from '@/components/EntrepriseView.vue'
import UserView from '@/components/UserView.vue'
import { ACCOUNT_TYPE_COMPANY, ACCOUNT_TYPE_USER } from '@/constants/store'
import { EMPTY_ADDRESS } from '@/constants'

type AccountType = {
  add?: string
  entrepriseName?: string
  username?: string
  owner?: string
  address?: string[]
  entrepriseBalance?: number
  userBalance?: number
  nbWithdrawTransactions?: number
  registered?: boolean
  members?: string[]
}

export default defineComponent({
  components: { Card, CollectiveButton, EntrepriseView, UserView },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    const type = computed(() => store.state.account.type)
    return { address, contract, balance, type }
  },
  data() {
    const account: AccountType = {}
    const username = ''
    const corpBalance = 0
    const accountTypes = [ACCOUNT_TYPE_USER, ACCOUNT_TYPE_COMPANY]
    const web3 = new Web3(
      new Web3.providers.HttpProvider('http://127.0.0.1:7545')
    )
    return { account, username, corpBalance, accountTypes, web3 }
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
          .send({ from: address, value: 5000 })
        await this.updateAccount()
      } else {
        await contract.methods.openEntreprise(name).send({
          from: address,
          value: this.web3.utils.toWei(this.corpBalance.toString(), 'ether'),
        })
        await this.updateAccount()
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
    getBalance() {
      if (!this.account) return null
      if (this.account?.userBalance)
        return this.web3.utils.fromWei(
          this.account.userBalance.toString(),
          'ether'
        )
      else if (this.account?.entrepriseBalance)
        return this.web3.utils.fromWei(
          this.account.entrepriseBalance?.toString(),
          'ether'
        )
    },
    getMemberList() {
      return this.account.members?.filter(isMember => isMember !== EMPTY_ADDRESS)
    },
    async handleAddMember(address: string) {
      await this.contract.methods.addMember(address).send({
        from: this.address,
        value: this.web3.utils.toWei('2', 'ether'),
      })
      await this.updateAccount()
    },
    handleCreateProject() {
      this.$router.push({ name: 'CreateProject' })
    },
    async handleChangeName(name: string) {
      await this.contract.methods.changeUsername(name).send({
        from: this.address,
        value: this.web3.utils.toWei('2', 'ether'),
      })
      await this.updateAccount()
    },
    async handleSend(address: string, amount: number) {
      const amountOnEther = this.web3.utils.toWei(amount.toString(), 'ether')
      await this.contract.methods.sendMoney(address, BigInt(amountOnEther)).send()
      await this.updateAccount()
    },
    async handleDeposit(amount: number) {
      await this.contract.methods.deposit().send({
        from: this.address,
        value: this.web3.utils.toWei(amount.toString(), 'ether'),
      })
      await this.updateAccount()
    },
    async handleWithdraw(amount: number) {
      const amountOnEther = this.web3.utils.toWei(amount.toString(), 'ether')
      await this.contract.methods.withdrawUserBalance(BigInt(amountOnEther)).send()
      await this.updateAccount()
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
