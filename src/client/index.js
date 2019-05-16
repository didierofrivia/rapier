import './css/main.css'
import { Elm } from './Main.elm'
import React from "react"
import { render } from "react-dom"
import Form from "react-jsonschema-form"
// import registerServiceWorker from './registerServiceWorker'
import './css/form.css'

const toggleSection = (section, uiSchema) => {
  const hiddenSections = Object.keys(uiSchema).filter(val => val !== section)
  return hiddenSections.reduce((obj, key) => Object.assign({}, obj, {[key]: {"ui:widget": "hidden",}}), uiSchema)
}

const CustomEnumValuesWidget = (props) => {
  const {id, label, value, schema, formContext} = props
  const $enum = schema.$enum.split('/')
  const config = formContext.config
  const path = $enum.slice(1, -1)
  const prop = $enum.slice(-1)[0]
  const values = path.reduce((acc, curr) => acc[curr], config).map(val => val[prop])
  const change = value => {
    props.onChange(value)
  }
  (values.length === 1) && change(values[0]) // Auto-select the only value

  return (
    (values.length) ?
        <select value={value} id={id} className="form-control" onChange={event => change(event.target.event)}>
          {values.map((val, idx) => <option key={`${val}-${idx}`} value={val}>{val}</option>)}
        </select>
    : <p>There's no {label} created.</p>
  )

}

const renderForm = (settings, changeConfig, submitConfig) => {
  const log = (type) => console.log.bind(console, type)
  const [{schema, uiSchema, config}, section] = settings
  const change = (form) => changeConfig(form.formData)
  const submit = (form) => submitConfig(form.formData)
  const widgets = {
    customEnumValuesWidget: CustomEnumValuesWidget
  }

  render((
    <Form schema={schema}
          formData={config}
          onChange={change}
          onSubmit={submit}
          onError={log("errors")}
          formContext={{config}}
          widgets={widgets}
          uiSchema={toggleSection(section, uiSchema)}>
      <button className="btn btn-info" type="submit">Save config</button>
    </Form>
  ), document.getElementById("SettingsForm"))
}

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: {
    apiUrl: process.env.API_URL,
    portNumber: process.env.PORT
  }
})
const ports = app.ports

ports.renderForm.subscribe((settings) => renderForm(settings, ports.changeConfig.send, ports.submitConfig.send))

ports.logThisShit.subscribe(function(shit) {
  console.log(shit)
})

// registerServiceWorker()
