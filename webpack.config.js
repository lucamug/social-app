const path = require('path')
const autoprefixer = require('autoprefixer')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

module.exports = 
  { watch: true
  , entry: 
    { app: './src/index.js'
    }
  , output:
    { path : path.resolve(__dirname, 'dist')
    , filename: '[name].js'
    }
  , module: 
    { noParse: /.\elm$/
    , rules:
      [ { test: /\.js$/
        , exclude: [/elm-stuff/, /node_modules/]
        , use: 
          { loader: 'babel-loader'
          , options: 
        // Latest stable ECMAScript features
            { presets: 
              [ [ 'babel-preset-env',
                    { targets: 
                        // React parses on ie 9, so we should too
                      { ie: 9
                        // We currently minify with uglify
                        // Remove after https://github.com/mishoo/UglifyJS2/issues/448
                      , uglify: true
                      }
                      // Disable polyfill transforms
                    , useBuiltIns: false
                      // Do not transform modules to CJS
                    , modules: false
                    }
                ]
              ]
            , plugins: 
              [ [ 'babel-plugin-transform-runtime'
                , { "helpers": false
                  , "polyfill": false
                  , "regenerator": true
                  }
                ]
              ]
            }
          }
        }
      , { test: /\.elm$/
        , exclude: [/elm-stuff/, /node_modules/]
        , use: 
          { loader: 'elm-webpack-loader'
          , options:{debug: true}
          }
        }
      ,
      // "postcss" loader applies autoprefixer to our CSS.
      // "css" loader resolves paths in CSS and adds assets as dependencies.
      // "style" loader turns CSS into JS modules that inject <style> tags.
      // In production, we use a plugin to extract that CSS to a file, but
      // in development "style" loader enables hot editing of CSS.
      {
        test: /\.css$/,
        use: 
          [ 'style-loader'
          , { loader: 'css-loader'
            , options: { importLoaders: 1 }
            }
          , { loader: 'postcss-loader'
            , options: 
              { ident: 'postcss' // https://webpack.js.org/guides/migrating/#complex-options
              , plugins: () => [
                autoprefixer({
                  browsers: [
                    '>1%',
                    'last 4 versions',
                    'Firefox ESR',
                    'not ie < 9'
                  ]
                })]
              }
            }
          ]
        },
      {
        exclude: [/\.html$/, /\.js$/, /\.elm$/, /\.css$/, /\.json$/, /\.svg$/],
        loader: 'url-loader',
        options: {
          limit: 10000,
          name: 'static/media/[name].[hash:8].[ext]'
        }
      },

      // "file" loader for svg
      {
        test: /\.svg$/,
        loader: 'file-loader',
        options: {
          name: 'static/media/[name].[hash:8].[ext]'
        }
      }

      ]
    }
  , plugins: 
    [ new HtmlWebpackPlugin({inject: true, template: './public/index.html'})
    , new CopyWebpackPlugin([{from: 'public/images', to: 'images'}])
    ]
  , devServer:
    { historyApiFallback: true
    , contentBase: path.join(__dirname, 'dist')
    , port: 9000
    , open: true
    }
  }
