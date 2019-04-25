import './css/main.css'
import { Elm } from './Main.elm'
import React from "react"
import { render } from "react-dom"
import Form from "react-jsonschema-form"
import registerServiceWorker from './registerServiceWorker'
import './css/form.css'

const toggleSection = (section, uiSchema) => {
  const hiddenSections = Object.keys(uiSchema).filter(val => val !== section)
  return hiddenSections.reduce((o, key) => Object.assign(o, {[key]: {"ui:widget": "hidden",}}), {})
}

const renderForm = (settings, changeConfig, submitConfig) => {
  const log = (type) => console.log.bind(console, type)
  const [{schema, uiSchema, config}, section] = settings
  const change = (form) => changeConfig(form.formData)
  const submit = (form) => submitConfig(form.formData)
  render((
    <Form schema={schema}
          formData={config}
          onChange={change}
          onSubmit={submit}
          onError={log("errors")}
          uiSchema={toggleSection(section, uiSchema)}/>
  ), document.getElementById("SettingsForm"))
}

const app = Elm.Main.init({node: document.getElementById('root')})
const ports = app.ports

ports.renderForm.subscribe((settings) => renderForm(settings, ports.changeConfig.send, ports.submitConfig.send))

ports.logThisShit.subscribe(function(shit) {
  console.log(shit)
})

registerServiceWorker()
