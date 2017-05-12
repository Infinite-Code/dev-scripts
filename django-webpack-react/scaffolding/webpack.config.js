const path = require('path');
const webpack = require('webpack');
const BundleTracker = require('webpack-bundle-tracker');

const IS_PROD = process.env.NODE_ENV === 'production';
const HOST = process.env.HOST || "localhost";
const PORT = process.env.PORT || "3000";
const BUNDLE_PATH = 'dist/'
const DEV_BUNDLE_PATH = 'assets/bundles/'


const config = {
    context: __dirname,
    entry: {
        'app': [
            './assets/js/index'
        ],
    },
    output: {
        pathinfo: true,
        path: path.resolve(BUNDLE_PATH),
        filename: `${IS_PROD ? '[hash:7]' : '[name]'}.js`
    },

    plugins: [
        new BundleTracker({filename: './webpack-stats.json'}),
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoEmitOnErrorsPlugin(),
    ],

    module: {
        loaders: [
      // we pass the output from babel loader to react-hot loader
      { test: /\.jsx?$/, exclude: /node_modules/, loader: 'babel-loader' },
        ],
    },

    resolve: {
        modules: [
            path.resolve('./assets/js'), // no more relative path
            './node_modules',
        ],
        extensions: ['.js', '.jsx']
    },
}


if (IS_PROD) {
    config.plugins = config.plugins.concat([
        // removes a lot of debugging code in React
        new webpack.DefinePlugin({
            'process.env': {
                'NODE_ENV': '"production"',
            }}),
        new webpack.optimize.OccurrenceOrderPlugin(),
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false,
                screw_ie8: true,
                drop_console: true,
                drop_debugger: true
            },
            output: {
                comments: false,
            },
            sourceMap: false,
        })
    ])
} else{
    config.cache = true;
    config.devtool = 'eval'; //or cheap-module-eval-source-map
    config.plugins.push(
        new webpack.DefinePlugin({
            '__DEV__': true
        })
    );
    config.output.publicPath = `http://${HOST}:${PORT}/${DEV_BUNDLE_PATH}`
    config.devServer = {
        headers: { "Access-Control-Allow-Origin": "*" },
        contentBase: __dirname,
        host: HOST,
        port: PORT,
        hot: true,
        inline: true,
        noInfo: true,
    };
}


module.exports = config
