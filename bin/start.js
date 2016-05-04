'use strict';

const app = require('../server');
const PORT = process.env.PORT || 3000;

app(process.env).listen(PORT, () => {
  console.log('Listening at port %s', PORT);
});
