# Gulp Helper

## Intro
Helpful so you don't have to remember all the different gulp modules.
Also useful as a reference.

    gulp = require 'gulp'
    coffee = require 'gulp-coffee'
    cache = require 'gulp-cached'
    gutil = require 'gulp-util'
    compressor = require 'gulp-compressor'
    uglify = require 'gulp-uglify'
    concat = require 'gulp-concat'
    source = require 'vinyl-source-stream'
    watchify = require 'watchify'
    browserify = require 'browserify'
    _ = require 'underscore'
    path = require 'path'
    exec = require('child_process').exec

### Handle errors in standard way ###

* [String] label Just a label to know where the error came from

<!-- -->

    getErrorHandler = (label) ->
        (err) ->
            gutil.log "#{label} error -- #{err.toString()}"
            gutil.log err.stack
            #    exec("osascript -e 'tell app \"Terminal\" to say \"#{label} error, #{err.message}\"'")
            gutil.beep()
            @emit 'end'

Browserify your javascripts. Sets up a watcher in and of itself that
will iteratively update on changes

* @param [String] src Source filepath to browserify
* @param [String] dest Destination filepath

<!-- -->
  
    exports.browserify = (src, dest) ->
        destFileName = path.basename(dest)
        destDir = path.dirname(dest)
        ->
            gutil.log("GulpHelpers.Browserify -- task started for #{destFileName}")
            watcher = watchify(browserify(src, watchify.args))
            rebundle = ->
                gutil.log "GulpHelpers.Browserify -- Watcher for #{destFileName} triggered update"
                watcherStream = watcher.bundle()
                watcherStream
                .on('error', getErrorHandler('Browserify'))
                .on('log', (msg) ->
                    gutil.log "GulpHelpers.Browserify -- Watcher for #{destFileName} logged '#{msg}'"
                )
                .pipe(source(destFileName))
                .pipe(gulp.dest(destDir))
                return watcherStream

            watcher.on('update', rebundle)
            return rebundle()

Compile coffeescripts task

* @param {Object} options Options for the task
* @option options {String} src Glob of source scripts to use. Defaults to src
* @option options {String} dir Output directory of javascripts. Defaults to lib
* @option options {Function} errorHandler Custom error handler if any. Defaults to a bell and a message
  
<!-- -->

    exports.coffee = (options = {}) ->
        options = _.extend {
            src: './src/**/*.coffee'
            dir: './lib/'
            errorHandler: getErrorHandler('Coffee')
        }, options
        ->
            stream = gulp.src(options.src)
            .pipe(cache('coffee'))
            .pipe(coffee())
            .on('error', options.errorHandler)
            .pipe(gulp.dest options.dir)
            return stream

Help out a gulp object by adding helpers and shortcuts to it

* @param [Object] gulp Gulp object
* @param [Object] options Options for the task
* @option options [String] src Glob of source scripts to use. Defaults to src
* @option options [String] dir Output directory of javascripts. Defaults to lib

<!-- -->

    exports.help = (_gulp, options = {}) ->
        options = _.extend {
            src: './src/**/*.coffee'
            dir: './lib/'
        }, options
        _.extend _gulp,
            src: options.src
            dir: options.dir
            coffee: exports.coffee(options)
            watchSrc: (args...) ->
                _gulp.watch options.src, args...
