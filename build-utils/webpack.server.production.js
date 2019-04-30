const path = require("path")
const nodeExternals = require('webpack-node-externals')

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
  module : {
    rules: [
      {
        test: /\.js$/,
        use: [
          {
            loader: require.resolve('babel-loader'),
            options: {
              babelrc: true,
              compact: true,
              presets: [
                [
                  // Latest stable ECMAScript features
                  require('@babel/preset-env').default,
                  {
                    // Do not transform modules to CJS
                    modules: false
                  }
                ]
              ]
            }
          }
        ]
      }
    ],
  },
  node: {
    console: false,
    global: false,
    process: false,
    Buffer: false,
    __filename: false,
    __dirname: false,
  }
})
