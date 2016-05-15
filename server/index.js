'use strict';

const http = require('http');
const Url = require('url');

const Elm = require('../dist/elm.js');

const simpleUrl = (url) => {
  const urlObject = Url.parse(url, true);

  return {
    href: urlObject.href,
    auth: urlObject.auth,
    pathname: urlObject.pathname,
    search: urlObject.search,
    path: urlObject.path,
    // query: urlObject.query, need dict support
  };
};

const idGenerator = function* () {
  var id = 0;
  while (true) {
    if(id >= Number.MAX_SAFE_INTEGER) {
      id = 0;
    }
    yield String(id++);
  }
};

module.exports = (env) => {
  const elmServer = Elm.Server.worker();
  const reqs = {};
  const generateId = idGenerator();

  elmServer.ports.response.subscribe((response) => {
    var res = reqs[response.id].res;

    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.statusCode = response.statusCode;
    res.write(String(response.body));
    res.end();

    delete reqs[response.id];
  });

  return http.createServer((req, res) => {
    const id = generateId.next().value;
    const simpleReq = {
      id,
      method: req.method,
      url: simpleUrl(req.url),
    };

    reqs[id] = {req, res};
    elmServer.ports.request.send(simpleReq);
  });
};
