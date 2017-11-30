require('./bootstrap');

window.formatAsCurrency = value => {
    if (value === null) return null;

    let langage = (navigator.language || navigator.browserLanguage).split(
        '-'
    )[0];

    return value.toLocaleString(langage, {
        style: 'currency',
        currency: 'gbp'
    });
};

Vue.filter('currency', window.formatAsCurrency);

Vue.filter('date', value => {
    return moment(value).format('DD/MM/YY');
});

const app = new Vue({
    el: '#app'
});
