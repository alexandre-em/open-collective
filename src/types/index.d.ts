type AccountState = {
  contract: any
  account: {
    address: any
    balance: number
    type: string
  }
}

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
