'use strict';

var data = '';

process.stdin.setEncoding('utf8');

process.stdin.on('readable', () => {
  var chunk = process.stdin.read();
  if (chunk !== null) {
    data += chunk;
  }
});

process.stdin.on('end', () => {
  var output = renderElm(data.split('\n').filter(Boolean).map(envvar => envvar.split(/=(.*)/)));
  process.stdout.write(output);
});

function renderElm (vars) {
  return `module Config exposing (..)

type alias Config =
  { ${vars.map(renderTypeField).filter(Boolean).join('\n  , ')}
  }

config : Config
config =
  { ${vars.map(renderRecordField).filter(Boolean).join('\n  , ')}
  }
`;
}

function renderTypeField ([key]) {
  var name = sanitizeKey(snakeToCamel(key));
  if(!name) {
    return '';
  }
  return `${name} : String`;
}

  function renderRecordField ([key, value]) {
  var name = sanitizeKey(snakeToCamel(key));
  if(!name) {
    return '';
  }
  return `${name} = "${sanitizeValue(value)}"`;
}

function snakeToCamel (name) {
  return name.toLowerCase().replace(/_(.)/g, ([_, char]) => {
    return char.toUpperCase();
  });
}

function sanitizeKey (name) {
  if(name[0] === '_') {
    name = name.substring(1);
  }

  if(['port'].indexOf(name) !== -1) {
    name = name + '_';
  }

  return name;
}

function sanitizeValue (value) {
  return value.replace(/"/g, '\\"');
}
