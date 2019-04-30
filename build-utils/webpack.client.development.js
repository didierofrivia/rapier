const path = require("path")
const DashboardPlugin = require('webpack-dashboard/plugin')
const webpack = require('webpack')

module.exports = () => ({
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          { loader: 'elm-hot-webpack-loader' },
          {
            loader: 'elm-webpack-loader',
            options: {
              cwd: path.join(__dirname, '../'),
              debug: true
            }
          }
        ]
      },
      {
        test: /\.js$/,
        use: [
          {
            loader: require.resolve('babel-loader'),
            options: {
              babelrc: true,
              compact: false,
              presets: [
                [
                  // Latest stable ECMAScript features
                  require('@babel/preset-env').default,
                  {
                    // Do not transform modules to CJS
                    modules: false
                  }
                ]
              ],
              cacheDirectory: true,
              highlightCode: true
            }
          }
        ]
      },
      {
        test: /\.s?css$/,
        use: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff'
      },
      {
        test: /\.(ttf|otf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?|(jpg|gif)$/,
        loader: 'file-loader'
      }
    ]
  },

  plugins: [
    new webpack.HotModuleReplacementPlugin(),

    new DashboardPlugin(),
  ],

  devServer: {
    contentBase: './src/client',
    historyApiFallback: true,
    inline: true,
    stats: 'errors-only',
    hot: true,
  }
})
