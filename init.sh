#!/usr/bin/env bash

npm init -y

if [ ! -d "css" ];then
    mkdir "css"
fi

if [ ! -d "css/components" ];then
    mkdir "css/components"
fi
echo '@import "./components/";' > "css/bundle.less"



appless=`cat << EOF
#app {
    width: 80%;
    min-height: 400px;
    margin: 0 auto;
    text-align: center;
}
EOF
`
echo "${appless}" > "css/components/app.less"



if [ ! -d "src" ];then
    mkdir "src"
fi
indexts=`cat << EOF
const app = document.getElementById('app')
app.innerHTML = 'Hello world!'
EOF
`
echo "${indexts}" > "src/index.ts"

npm i --save-dev f2e-server less typescript rollup f2e-middle-rollup rollup-plugin-commonjs rollup-plugin-node-resolve rollup-plugin-typescript2

f2econfig=`cat << EOF
const { argv } = process
const build = argv[argv.length - 1] === 'build'
module.exports = {
    livereload: !build,
    build,
    useLess: true,
    gzip: true,
    onRoute: p => p || 'index.html',
    buildFilter: p => !p || /src|css|index/.test(p),
    middlewares: [ { middleware: 'rollup' } ],
    output: require('path').join(__dirname, './output')
}
EOF
`
echo "$f2econfig" > ".f2econfig.js"
echo "output" >> ".gitignore"


tsconfig=`cat << EOF
{
    "compilerOptions": {
        "declaration": true,
        "outDir": "dist",
        "moduleResolution": "node",
        "module": "esnext",
        "jsx": "react",
        "jsxFactory": "h",
        "sourceMap": true,
        "target": "esnext"
    },
    "include": [
        "src/**.ts",
        "src/**.tsx"
    ]
}
EOF
`
echo "$tsconfig" > "tsconfig.json"
echo "dist" >> ".gitignore"

rollupconfig=`cat << EOF
const typescript = require('rollup-plugin-typescript2')
const commonjs = require('rollup-plugin-commonjs')
const nodeResolve = require('rollup-plugin-node-resolve')
module.exports = [{
    input: 'src/index.ts',
    plugins: [
        typescript(),
        nodeResolve(),
        commonjs()
    ],
    output: {
        sourcemap: true,
        file: 'bundle.js',
        format: 'iife'
    }
}]
EOF
`
echo "$rollupconfig" > "rollup.config.js"
echo ".rpt2_cache" >> ".gitignore"

indexhtml=`cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>App</title>
    <link rel="stylesheet" href="css/bundle.css">
</head>
<body>
    <div id="app"></div>
    <script src="bundle.js"></script>
</body>
</html>
EOF
`
echo "$indexhtml" > "index.html"

node -e 'let package = require("./package.json");Object.assign(package.scripts, {"start": "f2e start","build": "f2e build"});require("fs").writeFileSync("./package.json", JSON.stringify(package, 0, 2))'
npm start
