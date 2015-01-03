'use strict'

$ = require('gulp-load-plugins')()
browserSync = require 'browser-sync'
del = require 'del'
gulp = require 'gulp'
reload = browserSync.reload
runSequence = require 'run-sequence'

AUTOPREFIXER_BROWSERS = [
  'ie >= 10',
  'ie_mob >= 10',
  'ff >= 30',
  'chrome >= 34',
  'safari >= 7',
  'opera >= 23',
  'ios >= 7',
  'android >= 4.4',
  'bb >= 10'
]

# browserify
gulp.task 'browserify', ->
  gulp.src ['app/react/**/*.js']
    .pipe $.browserify
        debug: true,
        transform: [ 'reactify' ]
    .pipe gulp.dest '.tmp/js'
    .pipe gulp.dest 'dist/js'
    .pipe $.size title: 'browserify'

# Optimize images
gulp.task 'images', ->
  gulp.src 'app/img/**/*'
    .pipe $.cache $.imagemin
      progressive: true,
      interlaced: true
    .pipe gulp.dest 'dist/img'
    .pipe $.size title: 'images'

# Compile react scripts and js
gulp.task 'scripts', ->
  gulp.src 'app/js/**/*.coffee'
    .pipe $.coffee()
    .pipe $.uglify preserveComments: 'some'
    .pipe $.concat 'main.js'
    .pipe gulp.dest 'dist/js'
    .pipe gulp.dest '.tmp/js'
    .pipe $.size title: 'scripts'

# Compile and Automatically Prefix Stylesheets
gulp.task 'styles', ->
  # For best performance, don't add Sass partials to `gulp.src`
  gulp.src ['app/css/*.scss', 'app/css/**/*.css']
    .pipe $.changed 'css', extension: '.scss'
    .pipe $.sass precision: 10
    .on 'error', console.error.bind console
    .pipe $.autoprefixer browsers: AUTOPREFIXER_BROWSERS
    .pipe gulp.dest '.tmp/css'
    # Concatenate And Minify Styles
    .pipe $.if '*.css', $.csso()
    .pipe gulp.dest 'dist/css'
    .pipe $.size title: 'styles'

# Scan Your HTML For Assets & Optimize Them
gulp.task 'html', ->
  assets = $.useref.assets searchPath: '{.tmp,app}'

  gulp.src 'app/**/*.html'
    .pipe assets
    # Concatenate And Minify JavaScript
    .pipe $.if '*.js', $.uglify preserveComments: 'some'
    # Remove Any Unused CSS
    # Note: If not using the Style Guide, you can delete it from
    # the next line to only include styles your project uses.
    # .pipe $.if '*.css', $.uncss
    #  html: [
    #    'app/index.html'
    #  ]
    # CSS Selectors for UnCSS to ignore
    #  ignore: [
    #    /(\w|-)*reveal(\w|-)*/
    #  ]
    # Concatenate And Minify Styles
    # In case you are still using useref build blocks
    .pipe $.if '*.css', $.csso()
    .pipe assets.restore()
    .pipe $.useref()
    # Minify Any HTML
    .pipe $.if '*.html', $.minifyHtml()
    # Output Files
    .pipe gulp.dest 'dist'
    .pipe $.size title: 'html'


# Copy All Files At The Root Level (app)
gulp.task 'copy', ->
  gulp.src [
      'app/*',
      '!app/*.html',
      'node_modules/apache-server-configs/dist/.htaccess'
    ], dot: true
  .pipe gulp.dest 'dist'
  .pipe $.size title: 'copy'

# Watch Files For Changes & Reload
gulp.task 'serve', ['scripts', 'styles', 'browserify'], ->
  browserSync
    notify: false,
    logPrefix: 'VC',
    server: ['.tmp', 'app']

  gulp.watch ['app/**/*.html'], reload
  gulp.watch ['app/css/**/*.{scss,css}'], ['styles', reload]
  gulp.watch ['app/js/**/*.coffee'], ['scripts', reload]
  gulp.watch ['app/js/**/*.js'], reload
  gulp.watch ['app/react/**/* '], ['browserify', reload]
  gulp.watch ['app/img/**/*'], reload

# Build and serve the output from the dist build
gulp.task 'serve:dist', ['default'], () ->
  browserSync
    notify: false,
    logPrefix: 'VC',
    server: 'dist'

# Clean Output Directory
gulp.task 'clean', del.bind null, ['.tmp', 'dist/*', '!dist/.git'], dot: true

# Build Production Files, the Default Task
gulp.task 'default', ['clean'], (cb) ->
  runSequence ['scripts', 'styles', 'html', 'images', 'browserify'], 'copy', cb
