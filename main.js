const spawnSync = require('child_process').spawnSync;
const path = require("path");

ACTION_PATH = __dirname

const proc = spawnSync('bash', [path.join(__dirname, 'main.sh')], {stdio: 'inherit'});
process.exit(proc.status)
