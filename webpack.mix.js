let mix = require('laravel-mix');
var tailwindcss = require('tailwindcss');

mix
    .setPublicPath(__dirname)
    .js('Resources/js/app.js', 'js')
    .sass('Resources/sass/app.scss', 'css')
    .version()
    .options({
        processCssUrls: false,
        postCss: [tailwindcss('tailwind.js')]
    });
