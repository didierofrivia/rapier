import './css/main.css'
import { Elm } from './Main.elm'
import React, { Component } from "react"
import { render } from "react-dom"
import Form from "react-jsonschema-form"
import registerServiceWorker from './registerServiceWorker'
import './css/form.css'

const app = Elm.Main.init({
  node: document.getElementById('root')
})

app.ports.renderForm.subscribe(function(settings) {
  const log = (type) => console.log.bind(console, type)
  const [schema, config] = settings

  render((
    <Form schema={schema} formData={config}
          onChange={log("changed")}
          onSubmit={log("submitted")}
          onError={log("errors")} />
  ), document.getElementById("SettingsForm"))
})

app.ports.logThisShit.subscribe(function(shit) {
  console.log(shit)
})
registerServiceWorker()
