import './main.css';
import {db, auth, msging, storage} from './firebase.js'
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

// Main.embed(document.getElementById('root'));
var app = Main.fullscreen({ width: window.innerWidth, height: window.innerHeight });

registerServiceWorker();
