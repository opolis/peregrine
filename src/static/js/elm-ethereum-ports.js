
function txSentry(fromElm, toElm, web3) {
    checkFromElmPort(fromElm);
    checkToElmPort(toElm);
    checkWeb3(web3);

    fromElm.subscribe(function (txData) {
        console.log("TxData", txData)
        try {
            web3.eth.sendTransaction(txData.txParams, function (e, r) {
                console.log("Error", e);
                toElm.send({ ref: txData.ref, txHash: r || e });
            });
        } catch (error) {
            console.log(error);
            toElm.send({ ref: txData.ref, txHash: null });
        }
    });
}


function walletSentry(toElm, web3) {
    checkToElmPort(toElm);
    checkWeb3(web3);

    var model = { account: null, networkId: 4 };

    setInterval(function () {
        web3.eth.getAccounts(function (e, accounts) {
            console.log(e);
            if (accounts !== undefined && accounts[0] !== undefined && model.account !== accounts[0]) {
                model.account = accounts[0];
                console.log('elm-ethereum-ports: Account set to', model.account);
                toElm.send(model);
            } else if (e != undefined && model.account !== null) {
                model.account = null;
                toElm.send(model);
            }
        });
    }, 2500);
}


// Logging Helpers

function checkToElmPort(port) {
    if (typeof port === 'undefined' || typeof port.send === 'undefined') {
        console.warn('elm-ethereum-ports: The port to send messages to Elm is malformed.')
    }
}

function checkFromElmPort(port) {
    if (typeof port === 'undefined' || typeof port.subscribe === 'undefined') {
        console.warn('elm-ethereum-ports: The port to subscribe to messages from Elm is malformed.')
    }
}

function checkWeb3(web3) {
    if (typeof web3 === 'undefined') {
        console.warn('elm-ethereum-ports: web3 object is undefined')
    }
}

exports.txSentry = txSentry;
exports.walletSentry = walletSentry;