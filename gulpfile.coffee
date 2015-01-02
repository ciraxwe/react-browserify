'use strict'

gulp = require 'gulp'
$ = require('gulp-load-plugins')()
del = require 'del'
runSequence = require 'run-sequence'
browserSync = require 'browser-sync'
pagespeed = require 'psi'
reload = browserSync.reload

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

# Optimize images
gulp.task 'images', () ->
  gulp.src('app/img/**/*')
    .pipe($.cache($.imagemin(
      progressive: true,
      interlaced: true
    )))
    .pipe(gulp.dest 'dist/img')
    .pipe($.size title: 'images')

# Copy All Files At The Root Level (app)
gulp.task 'copy', () ->
  gulp.src([
    'app/*',
    '!app/*.html',
    'node_modules/apache-server-configs/dist/.htaccess'
  ], dot: true)
  .pipe(gulp.dest 'dist')
  .pipe($.size title: 'copy')

# Copy Web Fonts To Dist
gulp.task 'fonts', () ->
  gulp.src(['app/fonts/**'])
    .pipe(gulp.dest 'dist/fonts')
    .pipe($.size title: 'fonts')

# Compile react scripts and js
gulp.task 'scripts', () ->
  gulp.src(['app/jsx/**/*.js'])
    .pipe($.browserify
        debug: true,
        transform: [ 'reactify' ]
    )
    .pipe(gulp.dest '.tmp/jsx')
    .pipe(gulp.dest 'dist/jsx')


# Compile and Automatically Prefix Stylesheets
gulp.task 'styles', () ->
  # For best performance, don't add Sass partials to `gulp.src`
  gulp.src([
    'app/css/*.scss',
    'app/css/**/*.css'
  ])
    .pipe($.changed 'css', extension: '.scss' )
    .pipe($.sass precision: 10)
    .on('error', console.error.bind console)
    .pipe($.autoprefixer browsers: AUTOPREFIXER_BROWSERS)
    .pipe(gulp.dest '.tmp/css')
    # Concatenate And Minify Styles
    .pipe($.if '*.css', $.csso())
    .pipe(gulp.dest 'dist/css')
    .pipe($.size title: 'styles')

# Scan Your HTML For Assets & Optimize Them
gulp.task 'html', () ->
  assets = $.useref.assets searchPath: '{.tmp,app}'

  gulp.src('app/**/*.html')
    .pipe(assets)
    # Concatenate And Minify JavaScript
    .pipe($.if '*.js', $.uglify(preserveComments: 'some'))
    # Remove Any Unused CSS
    # Note: If not using the Style Guide, you can delete it from
    # the next line to only include styles your project uses.
    .pipe($.if('*.css', $.uncss(
      html: [
        'app/index.html'
      ]
    )))
    # Concatenate And Minify Styles
    # In case you are still using useref build blocks
    .pipe($.if '*.css', $.csso())
    .pipe(assets.restore())
    .pipe($.useref())
    # Minify Any HTML
    .pipe($.if '*.html', $.minifyHtml())
    # Output Files
    .pipe(gulp.dest 'dist')
    .pipe($.size title: 'html')

# Clean Output Directory
gulp.task 'clean', del.bind(null, ['.tmp', 'dist/*', '!dist/.git'], dot: true)

# Watch Files For Changes & Reload
gulp.task 'serve', ['scripts', 'styles'], () ->
  browserSync
    notify: false,
    # Customize the BrowserSync console logging prefix
    logPrefix: 'VC',
    # Run as an https by uncommenting 'https: true'
    # Note: this uses an unsigned certificate which on first access
    #       will present a certificate warning in the browser.
    # https: true,
    server: ['.tmp', 'app']

  gulp.watch ['app/**/*.html'], reload
  gulp.watch ['app/css/**/*.{scss,css}'], ['styles', reload]
  gulp.watch ['app/js/**/*.js'], ['scripts', reload]
  gulp.watch ['app/jsx/**/*.{js,jsx}'], ['scripts', reload]
  gulp.watch ['app/img/**/*'], reload

# Build and serve the output from the dist build
gulp.task 'serve:dist', ['default'], () ->
  browserSync
    notify: false,
    logPrefix: 'VC',
    # Run as an https by uncommenting 'https: true'
    # Note: this uses an unsigned certificate which on first access
    #       will present a certificate warning in the browser.
    # https: true,
    server: 'dist'

# Build Production Files, the Default Task
gulp.task 'default', ['clean'], (cb) ->
  runSequence 'styles', ['html', 'images', 'fonts', 'copy'], cb
