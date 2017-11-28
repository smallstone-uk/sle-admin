window._ = require('lodash');

window.ajax = require('axios');
window.ajax.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

window.Vue = require('vue');

require('./event');

window.moment = require('moment');
