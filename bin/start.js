'use strict';

const app = require('../server');
const Elm = require('../dist/elm');

const PORT = process.env.PORT || 3000;


app(Elm.Example, process.env).listen(PORT, () => {
  console.log('Listening at port %s', PORT);
});
