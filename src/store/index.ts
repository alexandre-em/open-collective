import { createStore } from 'vuex'
import actions from './actions'

export default createStore({
  state: {
    contract: null,
    account: {
      address: null,
      balance: 0,
      type: '',
    },
  },
  mutations: {
    updateEthereum(state, { address, contract, balance, type }) {
      state.account.address = address
      state.account.balance = balance
      state.account.type = type
      state.contract = contract
    },
  },
  actions,
  modules: {},
})
