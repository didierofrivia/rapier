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

const toggleSection = (section, uiSchema) => {
  const hiddenSections = Object.keys(uiSchema).filter(val => val !== section)
  return hiddenSections.reduce((o, key) => Object.assign(o, {[key]: {"ui:widget": "hidden",}}), {})
}

app.ports.renderForm.subscribe(function(settings) {
  const log = (type) => console.log.bind(console, type)
  const [{schema, uiSchema, config}, section] = settings
  render((
    <Form schema={schema}
          formData={config}
          onChange={log("changed")}
          onSubmit={log("submitted")}
          onError={log("errors")}
          uiSchema={toggleSection(section, uiSchema)}/>
  ), document.getElementById("SettingsForm"))
})

app.ports.logThisShit.subscribe(function(shit) {
  console.log(shit)
})
registerServiceWorker()
