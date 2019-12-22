<template>
  <div id="app">
    <div v-if="gameState === 0">
      <h1>Ein Fake Artist geht nach Zürich</h1>
      Anzahl Spieler<div class="spacer"></div>
      <input placeholder="Anzahl Spieler" type="number" pattern="\d*" min="2" v-model="playerCount"><div class="spacer"></div>
      <button v-on:click="startGame">Start</button>
      <div class="spacer"></div><div class="spacer"></div>
      <img src="@/assets/box.png">
    </div>
    <div v-else-if="showPlayer > -1">
      <h1>Du bist Spieler <span :style="'color:' + colors[showPlayer]">{{colorsDE[showPlayer]}}</span></h1>
      <p>Kategory: <span class="capitalize">{{currentCard.category}}</span></p>
      <p v-if="fakePlayer === showPlayer">Du bist der Fake</p>
      <p v-else>Wort: <span class="capitalize">{{currentCard.name}}</span></p>
      <button v-on:click="sawCard">Verstanden!</button>
    </div>

    <div v-else>
      <div>
        <h2>Wähle deine Farbe</h2>
        <div v-for="(c, i) in pickedColors" :key="c">
          <div :style="'background-color:' + c" class="color-box" v-on:click="showPlayerWith(i)">
            <span>{{colorsDE[i]}}</span>
          </div>
        </div>

      </div>
      <br>
      <button v-on:click="newWord">Neues Wort</button>
      <div class="spacer"></div>
      <button v-on:click="exitGame">Spiel beenden</button>
    </div>
  </div>
</template>

<script>
import {wordsDE} from './words-de.js';

export default {
  name: 'app',
  components: {
  },
  data() {
    return {
      showPlayer: -1,
      fakePlayer: -1,
      playerCount: 3,
      colors: ['black', 'red', 'green', 'blue', 'orange', 'yellow', 'darkblue', 'brown', 'darkred', 'darkgreen'],
      colorsDE: ['Schwarz', 'Rot', 'Grün', 'Blau', 'Orange', 'Gelb', 'Dunkelblau', 'Braun', 'Dunkelrot', 'Dunkelgrün'],
      gameState: 0, // 0 setup, 1 playing
      playedCards: [],
      currentCard: {category: '', name: ''},
    }
  },
  computed: {
    pickedColors() {
      return this.colors.slice(0, this.playerCount);
    }
  },
  mounted() {
    var local = window.localStorage.getItem('save');
    if (local !== null) {
      var s = JSON.parse(local);
      this.gameState = s.gameState;
      this.playerCount = s.playerCount;
      this.playedCards = s.playedCards;
      this.fakePlayer = s.fakePlayer;
    }
  },
  methods: {
    showPlayerWith(index) {
      this.showPlayer = index;
      /*window._timeout = setTimeout(() => {
        this.showPlayer = -1;
      }, 7000);*/
    },
    sawCard() {
      //clearTimeout(window._timeout);
      this.showPlayer = -1;
    },
    saveGame() {
      var s = {gameState: this.gameState, playerCount: this.playerCount, playedCards: this.playedCards, fakePlayer: this.fakePlayer};
      window.localStorage.setItem('save', JSON.stringify(s));
    },
    startGame() {
      for(var i = 0; i < 100; i++){
        this.playedCards.push(i);
      }
      this.gameState = 1;
      this.newWordWord();
    },
    newWord() {
      var ok = confirm('Neues Wort?');
      if (ok) {
        this.newWordWord();
      }
    },
    exitGame() {
      var ok = confirm('Spiel beenden?');
      if (ok) {
        window.localStorage.removeItem('save');
        location.reload();
      }
    },
    newWordWord() {
      var pos = randomIntFromInterval(0, wordsDE.length-1);
      while (this.playedCards.includes(pos)) {
        pos = randomIntFromInterval(0, wordsDE.length-1);
      }

      this.playedCards.push(pos);
      this.currentCard = wordsDE[pos];
      this.fakePlayer = randomIntFromInterval(0, this.playerCount-1);
      this.saveGame();
    }
  }
}

function randomIntFromInterval(min, max) {
	return Math.floor(Math.random()*(max-min+1)+min);
}

</script>

<style>

.color-box {
  margin: auto;
  width: 300px;
  height: 50px;
  margin-bottom: 10px;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
  font-size: 24px;
  line-height: 50px;
  font-weight: bold;
}

.color-box span {
  color: white;
  -webkit-text-stroke: px white;
}

html, body {
  margin: 0;
}

body {
  -webkit-font-smoothing: antialiased;
}

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 20px;
}

input[type="number"] {
  font-size: 20px; /*prevent browser zoom in */
}

h1 {
  font-size: 24px;
}
p {
  font-size: 20px;
}

.capitalize {
  text-transform: capitalize;
}

.spacer {
  height: 10px;
}

button {
  display: inline-block;
  background-color: transparent;
  border-radius: 4px;
  color: #555;
  text-align: center;
  font-size: 11px;
  font-weight: 600;
  text-decoration: none;
  cursor: pointer;
  border: 1px solid #bbb;
  height: 38px;
  line-height: 38px;
  padding: 0 30px;
  letter-spacing: .1rem;
  text-transform: uppercase;
  white-space: nowrap;
  box-sizing: border-box;
}

button:hover {
  border-color: #888;
  color: #333;
  outline: 0;
}
</style>
