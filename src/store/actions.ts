import * as OpenCollective from '../services/entreprise'
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
): Promise<void> => {
  const response = await OpenCollective.connect()
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
  await connect(context, ACCOUNT_TYPE_USER)
}

const entrepriseConnect = async (
  context: ActionContext<any, any>
): Promise<void> => {
  await connect(context, ACCOUNT_TYPE_COMPANY)
}

export default {
  userConnect,
  entrepriseConnect,
}
