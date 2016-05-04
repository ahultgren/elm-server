'use strict';

const http = require('http');
const url = require('url');
const uuid = require('uuid');

const Elm = require('../dist/elm.js');

module.exports = (env) => {
  var reqs = {};
  var i = 0;
  var elmServer = Elm.worker(Elm.Server, {
    incoming: ['0', 0],
  });

  elmServer.ports.outgoing.subscribe((x) => {
    reqs[x[0]].res.write(String(x[1]));
    reqs[x[0]].res.end();
  });

  return http.createServer((req, res) => {
    var id = uuid.v4();
    reqs[id] = {req, res};
    elmServer.ports.incoming.send([id, i++]);
  });
};
