import React from 'react'
import PropTypes from 'prop-types'


export default function App({ text }) {
    return (<h1> some {text} </h1>)
}
App.propTypes = {
    text: PropTypes.string.isRequired
}

