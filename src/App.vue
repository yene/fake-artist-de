<template>
  <div id="app">
    <div v-if="gameState === 0">
      <h1 class="main-title">Ein Fake Artist geht nach Zürich</h1>
      Eine Farbe pro Spieler wählen<div class="spacer"></div>
      <div class="color-selection">
        <label v-for="(c) in colors" :key="c" class="a-color" :style="'background-color: ' + c" v-bind:class="{ selected: pickedColors.includes(c) }">
          <img src="@/assets/check-regular.svg">
          <input type="checkbox" v-model="pickedColors" :value="c" />
        </label>
      </div>

      <button class="my-button" v-on:click="startGame" :disabled="pickedColors.length < 2">Start</button>
      <div class="spacer"></div><div class="spacer"></div>
      <img src="@/assets/box.png">
    </div>
    <div v-else-if="showPlayer !== ''">
      <h1>Du bist <span :style="'color:' + showPlayer">{{translateColor(showPlayer)}}</span></h1>
      <p>Kategory: <span class="capitalize">{{currentCard.category}}</span></p>
      <p v-if="fakePlayer === showPlayer">Du bist der Fake Artist</p>
      <p v-else>Wort: <span class="capitalize">{{currentCard.name}}</span></p>
      <button class="my-button" v-on:click="sawCard">Verstanden!</button>
    </div>
    <div v-else>
      <div>
        <h2>Wähle deine Farbe</h2>
        <div v-for="(c) in pickedColors" :key="c">
          <button :style="'background-color:' + c" class="color-box" v-on:click="showPlayerWith(c)">
            <span>{{translateColor(c)}}</span>
          </button>
        </div>
      </div>
      <br>
      <button class="my-button" v-on:click="newWord">Neues Wort</button>
      <div class="spacer"></div>
      <button class="my-button" v-on:click="exitGame">Spiel beenden</button>
    </div>
  </div>
</template>

<script>
import {wordsDE} from './words-de.js';
import Swal from 'sweetalert2';

export default {
  name: 'app',
  components: {
  },
  data() {
    return {
      showPlayer: '',
      fakePlayer: '',
      colors: ['red', 'green', 'blue', 'orange', 'yellow', 'darkblue', 'brown', 'darkred', 'darkgreen', 'black'],
      pickedColors: [],
      gameState: 0, // 0 setup, 1 playing
      playedCards: [],
      currentCard: {category: '', name: ''},
    }
  },
  mounted() {
    try {
      if (!window.plugins.insomnia.isEnabled) {
        window.plugins.insomnia.setEnabled(true);
      }
    } catch(e) {
      // console.log(e);
    }

    var local = window.localStorage.getItem('save');
    if (local !== null) {
      var s = JSON.parse(local);
      this.gameState = s.gameState;
      this.pickedColors = s.pickedColors;
      this.playedCards = s.playedCards;
      this.fakePlayer = s.fakePlayer;
      this.currentCard = s.currentCard;
    }
  },
  methods: {
    showPlayerWith(c) {
      this.showPlayer = c;
      /*window._timeout = setTimeout(() => {
        this.showPlayer = -1;
      }, 7000);*/
    },
    sawCard() {
      //clearTimeout(window._timeout);
      this.showPlayer = '';
    },
    saveGame() {
      var s = {gameState: this.gameState, playedCards: this.playedCards, fakePlayer: this.fakePlayer, currentCard: this.currentCard, pickedColors: this.pickedColors};
      window.localStorage.setItem('save', JSON.stringify(s));
    },
    startGame() {
      this.gameState = 1;
      this.newWordWord();
    },
    newWord() {
      Swal.fire({
        title: 'Neues Wort?',
        text: '',
        icon: 'question',
        confirmButtonText: 'Neues Wort',
        showCancelButton: true,
        cancelButtonText: 'Abbrechen',
        reverseButtons: true,
      }).then((result) => {
        if (result.value) {
          this.newWordWord();
        }
      });
    },
    exitGame() {
      Swal.fire({
        title: 'Spiel Beenden?',
        text: 'Alle Daten werden gelöscht.',
        icon: 'warning',
        confirmButtonText: 'Beenden',
        showCancelButton: true,
        cancelButtonText: 'Abbrechen',
        confirmButtonColor: '#d33',
        reverseButtons: true,
      }).then((result) => {
        if (result.value) {
          try {
            window.localStorage.removeItem('save');
            location.reload();
          } catch (e) {
            // console.log(e);
          }
        }
      });
    },
    newWordWord() {
      var pos = randomIntFromInterval(0, wordsDE.length-1);
      while (this.playedCards.includes(pos)) {
         console.log(pos)
        pos = randomIntFromInterval(0, wordsDE.length-1);
      }

      this.playedCards.push(pos);
      this.currentCard = wordsDE[pos];
      var index = randomIntFromInterval(0, this.pickedColors.length-1);
      console.log(index);
      this.fakePlayer = this.pickedColors[index];
      this.saveGame();
    },
    translateColor(c) {
      var pool = ['black', 'red', 'green', 'blue', 'orange', 'yellow', 'darkblue', 'brown', 'darkred', 'darkgreen'];
      var index = pool.indexOf(c);
      var translations = ['Schwarz', 'Rot', 'Grün', 'Blau', 'Orange', 'Gelb', 'Dunkelblau', 'Braun', 'Dunkelrot', 'Dunkelgrün'];
      return translations[index];
    }
  }
}

function randomIntFromInterval(min, max) {
	return Math.floor(Math.random()*(max-min+1)+min);
}

</script>

<style>

.color-selection {
  margin: 0 auto;
  max-width: 420px;
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 10px;
  justify-content: center;
}

.a-color img {
  margin-top: 2px;
  height: 35px;
  width: 35px;
  opacity: 0;
  transition: opacity 0.5s ease-in-out;
}

.a-color.selected {
  border: 1px solid black;
}

.a-color.selected img {
  opacity: 1;
}

.a-color {
  display: inline-block;
  margin-right: 2px;
  margin-top: 2px;
  width: 80px;
  height: 40px;
  border-radius: 5px;
  border: 1px solid transparent;
}

.a-color input {
  display: none;
}

.color-box {
  cursor: pointer;
  border: none;
  margin: auto;
  width: 300px;
  height: 50px;
  margin-bottom: 10px;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
  font-size: 24px;
  line-height: 50px;
  font-weight: bold;
}
.color-box:hover {
  border-color: #888;
  color: #333;
  outline: 0;
}

.color-box span {
  color: white;
  -webkit-text-stroke: px white;
}

html, body {
  margin: 0;
  font-family: 'Avenir', -apple-system, "Helvetica Neue", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

body {
  padding-top: env(safe-area-inset-top) !important;
  -webkit-font-smoothing: antialiased;
}

.main-title {
  margin-bottom: 5px;
}

#app {
  text-align: center;
  margin-top: 20px;
}

.swal2-popup {
  font-family: 'Avenir', -apple-system, "Helvetica Neue", Helvetica, Arial, sans-serif;
}

.dg-content {
  font-family: 'Avenir', -apple-system, "Helvetica Neue", Helvetica, Arial, sans-serif;
}
input[type="number"] {
  font-size: 20px; /*prevent browser zoom in */
  text-align: right;
  width: 100px;
}

h1 {
  font-size: 30px;
}

p {
  font-size: 24px;
}

.capitalize {
  text-transform: capitalize;
}

.spacer {
  height: 10px;
}

.my-button {
  display: inline-block;
  background-color: transparent;
  border-radius: 4px;
  color: #555;
  text-align: center;
  font-size: 18px;
  font-weight: 600;
  text-decoration: none;
  cursor: pointer;
  border: 1px solid #bbb;
  height: 45px;
  line-height: 40px;
  padding: 0 30px;
  letter-spacing: .1rem;
  text-transform: uppercase;
  white-space: nowrap;
  box-sizing: border-box;
}

.my-button:hover {
  border-color: #888;
  color: #333;
  outline: 0;
}
</style>
