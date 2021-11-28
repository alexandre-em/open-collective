<template>
  <div class="card-main-wrapper">
    <div class="card-main-element">
      <card title="Create a project" :blue="true">
        <collective-button
          :transparent="true"
          @click="call('create', onCreateProject)"
        >
          click here
        </collective-button>
      </card>
    </div>
    <div class="card-main-element">
      <card title="Get Members list" :blue="true">
        <collective-button
          :transparent="true"
          @click="call('get', onGetMemberList)"
        >
          click here
        </collective-button>
      </card>
    </div>
    <div class="card-main-element">
      <card title="Add a member" :blue="true">
        <collective-button :transparent="true" @click="call('add')">
          click here
        </collective-button>
      </card>
    </div>
    <div class="card-main-element">
      <card title="LastProject" :blue="true">
        <collective-button :transparent="true" @click="onLastProject">
          click here
        </collective-button>
      </card>
    </div>
    <div class="card-main-element">
      <card title="Withdraw" :blue="true">
        <collective-button :transparent="true" @click="call('withdraw')">
          click here
        </collective-button>
      </card>
    </div>
    <div class="card-main-element">
      <card title="Deposit" :blue="true">
        <collective-button :transparent="true" @click="call('deposit')">
          click here
        </collective-button>
      </card>
    </div>
    <div class="card-main-element">
      <card title="Pay salary" :blue="true">
        <collective-button :transparent="true" @click="call('salary')">
          click here
        </collective-button>
      </card>
    </div>
  </div>
  <div class="card-main">
    <div class="member-list" v-if="type === 'get'">
      <div v-for="member in members" :key="member" class="member-card">
        <h2>Member</h2>
        <p>{{ member }}</p>
      </div>
    </div>
    <form
      class="add-member"
      v-else-if="type === 'add'"
      @submit.prevent="onAddMember(toAdd)"
    >
      <h1>Add a new member to your group</h1>
      <input id="add-member-input" type="text" v-model="toAdd" />
      <collective-button :transparent="true">Submit</collective-button>
    </form>
    <form
      class="add-member"
      v-if="type === 'deposit'"
      @submit.prevent="
        () => {
          onDeposit(value)
          value = 0
        }
      "
    >
      <h1>Insert the amount of ether you want to put on your account</h1>
      <input id="add-member-input" type="text" v-model="value" />
      <collective-button :transparent="true">Submit</collective-button>
    </form>
    <form
      class="add-member"
      v-if="type === 'withdraw'"
      @submit.prevent="
        () => {
          onWithdraw(value)
          value = 0
        }
      "
    >
      <h1>Insert the amount of ether you want to withdraw from your account</h1>
      <input id="add-member-input" type="text" v-model="value" />
      <collective-button :transparent="true">Submit</collective-button>
    </form>
    <form
      class="add-member"
      v-if="type === 'salary'"
      @submit.prevent="
        () => {
          onPaySalary(toAdd, value)
          value = 0
          toAdd = ''
        }
      "
    >
      <h1>
        Insert the address of the user and the amout of ether you want to send
      </h1>
      <input
        id="add-member-input"
        type="text"
        v-model="toAdd"
        placeholder="Address eg. 0x1234..."
      />
      <input id="add-member-input" type="number" v-model="value" />
      <collective-button :transparent="true">Submit</collective-button>
    </form>
  </div>
</template>

<script>
import Card from '@/components/Card.vue'
import CollectiveButton from '@/components/CollectiveButton.vue'

export default {
  name: 'EntrepriseView',
  props: {
    onCreateProject: Function,
    onGetMemberList: Function,
    onAddMember: Function,
    onLastProject: Function,
    onDeposit: Function,
    onWithdraw: Function,
    onPaySalary: Function,
  },
  components: { Card, CollectiveButton },
  data() {
    const type = ''
    const toAdd = ''
    const value = 0
    return { type, toAdd, value }
  },
  methods: {
    call(type, func) {
      if (type === 'get') this.members = func()
      else if (func) func()
      this.type = type
      this.toAdd = ''
      this.value = 0
    },
  },
}
</script>

<style lang="css" scoped>
.card-main-wrapper {
  padding: 20px;
}
.card-main-element {
  width: 250px;
  margin-bottom: 20px;
}
.card-main {
  flex: 1;
  display: flex;
  justify-content: center;
  padding: 15px;
}

.member-list {
  display: flex;
  flex-wrap: wrap;
}
.member-card {
  background-color: rgb(113, 55, 146);
  margin: 10px;
  padding: 5px;
  border-radius: 15px;
  height: min-content;
}
.member-card > p {
  font-style: italic;
  color: rgba(240, 248, 255, 0.527);
}

.add-member {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-around;
}

#add-member-input {
  border-radius: 5px;
  border-style: none;
  height: min-content;
  outline-style: none;
  padding: 10px;
  width: 60%;
}
</style>
