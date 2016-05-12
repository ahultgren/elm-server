//import Dict, List, Maybe, Native.Scheduler //

// Inspired by https://github.com/evancz/elm-http/blob/3.0.1/src/Native/Http.js and https://github.com/ElmCast/elm-node/blob/master/src/Native/Http.js

// TODO Implement all the other requests

var _user$project$Native_Http = function () {

var http = require('http');

function get (url) {
	return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
		var req = http.get(url, function (res) {
			var data = '';
			res.on('data', function (chunk) {
					data += chunk.toString();
			});
			res.on('end', function () {
				return callback(_elm_lang$core$Native_Scheduler.succeed(data));
			});
		}).on('error', function (err) {
			return callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'NetworkError', _0: url }));
		});

		return function() {
			req.abort();
		};
	});
}

return {
	get: get,
};

}();
