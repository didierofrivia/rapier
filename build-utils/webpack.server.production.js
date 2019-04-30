const path = require('path')
const nodeExternals = require('webpack-node-externals')
const CopyWebpackPlugin = require('copy-webpack-plugin')

module.exports = () => ({
  mode: 'production',
  devtool: false,
  externals: [
    nodeExternals()
  ],
  name : 'server',
  target: 'node',
  output: {
    publicPath: './',
    path: path.resolve(__dirname, '../dist/'),
    filename: 'server.prod.js'
  },
  resolve: {
    extensions: ['.webpack-loader.js', '.web-loader.js', '.loader.js', '.js', '.jsx'],
    modules: [
      path.resolve(__dirname, 'node_modules')
    ]
  },
  node: {
    console: false,
    global: false,
    process: false,
    Buffer: false,
    __filename: false,
    __dirname: false,
  },
  plugins: [
    new CopyWebpackPlugin([
      { from: 'config/examples/', to: 'config/' },
    ])
  ]
})
