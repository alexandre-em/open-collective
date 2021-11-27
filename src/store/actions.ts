import * as User from '../services/ethereum'
import * as Entreprise from '../services/entreprise'
import { ACCOUNT_TYPE_COMPANY, ACCOUNT_TYPE_USER } from '@/constants/store'
import { ActionContext } from 'vuex'

/**
 * Link a wallet address with a `user` or a `company` account
 * @param {ActionContext<AccountState, AccountState>} context
 * @param {string} type
 * @param {any} contractObject
 */
const connect = async (
  context: ActionContext<any, any>,
  type: string,
  contractObject: any
): Promise<void> => {
  const response = await contractObject.connect()
  if (response) {
    const { address, contract, balance } = response
    context.commit('updateEthereum', {
      address,
      contract,
      balance,
      type,
    })
  }
}

const userConnect = async (context: ActionContext<any, any>): Promise<void> => {
  await connect(context, ACCOUNT_TYPE_USER, User)
}

const entrepriseConnect = async (
  context: ActionContext<any, any>
): Promise<void> => {
  await connect(context, ACCOUNT_TYPE_COMPANY, Entreprise)
}

export default {
  userConnect,
  entrepriseConnect,
}
