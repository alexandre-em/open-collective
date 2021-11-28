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
  },
  components: { Card, CollectiveButton },
  data() {
    const type = ''
    const toAdd =''
    return { type, toAdd }
  },
  methods: {
    call(type, func) {
      if (type === 'get') this.members = func()
      else if (func) func()
      this.type = type
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
