// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
import '../css/login.css'
import '../css/register.css'

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import * as React from 'react'
import * as ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import store from './store'
import Home from './Component/Home'
import { transitions, positions, Provider as AlertProvider } from 'react-alert'
import AlertTemplate from 'react-alert-template-basic'
import { BrowserRouter } from 'react-router-dom';

// This code starts up the React app when it runs in a browser. It sets up the routing
// configuration and injects the app into a DOM element.

// optional configuration
const options = {
    // you can also just use 'bottom center'
    position: positions.TOP_CENTER,
    timeout: 5000,
    offset: '30px',
    // you can also just use 'scale'
    transition: transitions.SCALE
}

var react_app = document.getElementById('react-app');
if (react_app != null) {
    ReactDOM.render(
        <Provider store={store}>
            <BrowserRouter>
                <AlertProvider template={AlertTemplate} {...options}>
                    <Home />
                </AlertProvider>
            </BrowserRouter>
        </Provider>
        , react_app)
}
