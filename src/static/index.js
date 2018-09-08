
import Elm from '../elm/Main';
import elm_ethereum_ports from './js/elm-ethereum-ports';
import wallet from './js/wallets';

window.web3 = wallet[0].getWeb3();

var Elm = require( '../elm/Main' );
var app;

window.addEventListener('load', function () {
    if (typeof web3 !== 'undefined') {
        app = Elm.Main.fullscreen();
        elm_ethereum_ports.txSentry(app.ports.txOut, app.ports.txIn, web3);
        elm_ethereum_ports.walletSentry(app.ports.walletSentry, web3);
    } else {
        app = Elm.Main.fullscreen(0);
        console.log("Metamask not detected.");
    }
});

