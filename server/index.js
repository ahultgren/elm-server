'use strict';

const http = require('http');
const Url = require('url');
const uuid = require('uuid');

global.window = global;
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

module.exports = (env) => {
  const reqs = {};

  const elmServer = Elm.worker(Elm.Server, {
    request: {id: '', method: '', url: simpleUrl('/')},
  });

  elmServer.ports.response.subscribe((response) => {
    if(!reqs[response.id]) {
      // TODO A specific noop-type for the initial bullshit event
      return;
    }
    reqs[response.id].res.write(String(response.body));
    reqs[response.id].res.end();
  });

  let i = 0;
  return http.createServer((req, res) => {
    const id = uuid.v4();
    const simpleReq = {
      id,
      method: req.method,
      url: simpleUrl(req.url),
    };

    reqs[id] = {req, res};
    console.log(simpleReq);
    elmServer.ports.request.send(simpleReq);
  });
};
