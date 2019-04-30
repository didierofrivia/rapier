const webpack = require('webpack')
require('dotenv').config()
const path = require('path')
const webpackMerge = require('webpack-merge')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const modeConfig = env => require(`./build-utils/webpack.client.${env}`)(env)
const presetConfig = require("./build-utils/loadPresets")

module.exports = ({ mode, presets } = { mode: "production", presets: [] }) => {
  console.log(`Building for: ${mode}`)

  return webpackMerge(
    {
      mode,

      entry: {
        main: path.join(__dirname, './src/client/index.js')
      },

      plugins: [
        new HtmlWebpackPlugin({
          template: 'public/index.html',
          inject: 'body',
          filename: 'index.html',
        }),

        new webpack.EnvironmentPlugin([
          'PORT', 'API_URL'
        ]),

        new CopyWebpackPlugin([
          { from: 'public/favicon.ico' }
        ]),
      ]
    },
    modeConfig(mode),
    presetConfig({ mode, presets }),
  )
}
