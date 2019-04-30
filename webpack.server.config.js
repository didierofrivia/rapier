const path = require('path')
const webpackMerge = require('webpack-merge')
const modeConfig = env => require(`./build-utils/webpack.server.${env}`)(env)
const presetConfig = require("./build-utils/loadPresets")

module.exports = ({ mode, presets } = { mode: "production", presets: [] }) => {
  console.log(`Building for: ${mode}`);

  return webpackMerge(
    {
      mode,

      entry: {
        main: path.join(__dirname, './src/server/index.js')
      },
    },
    modeConfig(mode),
    presetConfig({ mode, presets }),
  )
}
