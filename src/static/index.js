import Elm from '../elm/Main';
import elm_ethereum_ports from './js/elm-ethereum-ports';
import wallet from './js/wallets';

window.web3 = wallet[0].getWeb3();

var elm_ports_driver = require('elm-ports-driver');
var Elm = require( '../elm/Main' );

window.addEventListener('load', function () {
    if (typeof web3 !== 'undefined') {
        var app = Elm.Main.fullscreen();

        elm_ethereum_ports.txSentry(app.ports.txOut, app.ports.txIn, web3);
        elm_ethereum_ports.walletSentry(app.ports.walletSentry, web3);

        elm_ports_driver.install(app.ports.output, app.ports.input,
            [ elm_ports_driver.local_storage, elm_ports_driver.local_storage_listener ]
        );
    } else {
        var app = Elm.Main.fullscreen(0);
        console.log("Metamask not detected.");
    }
});

