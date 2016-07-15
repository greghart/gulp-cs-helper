# Gulp Helper

## Intro
A module for exploring how to setup a Coffeescript Gulp based workflow. Basically just a personal project 
to bundle up dependencies in an easy to use fashion. Also useful as a reference.

    gulp = require 'gulp'
    cjsx = require 'gulp-cjsx'
    cache = require 'gulp-cached'
    gutil = require 'gulp-util'
    source = require 'vinyl-source-stream'
    watchify = require 'watchify'
    browserify = require 'browserify'
    _ = require 'underscore'
    path = require 'path'
    exec = require('child_process').exec

## Methods

### Private
* [getErrorHandler](#geterrorhandler)

### Public
* [browserify](#browserify)
* [coffee](#coffee)
* [help](#help)

### <a name="geterrorhandler"/>getErrorHandler(label)###
Handle errors in standard way

#### Arguments
1. `label` *(`String`)*: Just a label to track where the error came from

#### Source

    getErrorHandler = (label) ->
        (err) ->
            gutil.log "#{label} error -- #{err.toString()}"
            gutil.log err.stack
            #    exec("osascript -e 'tell app \"Terminal\" to say \"#{label} error, #{err.message}\"'")
            gutil.beep()
            @emit 'end'

### <a name="browserify"/>browserify(src, dest)###
Browserify your javascripts. Sets up a watcher in and of itself that
will iteratively update on changes

#### Arguments
1. `src` *(`String`)*: Source filepath to browserify
2. `dest` *(`String`)*: Destination filepath

#### Source

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

### <a name="coffee"/>coffee(options={})###
Compile coffeescripts task

#### Arguments
1.`options` *(`Object`)*: Options for the task
* `options.src` *(`String`)*: Glob of source scripts to use. Defaults to src
* `options.dir` *(`String`)*; Output directory of javascripts. Defaults to lib
* `options.errorHandler` *(`Function`)*; Custom error handler if any. Defaults to a bell and a message

#### Source

    exports.coffee = (options = {}) ->
        options = _.extend {
            src: './src/**/*.coffee'
            dir: './lib/'
            errorHandler: getErrorHandler('Coffee')
        }, options
        ->
            stream = gulp.src(options.src)
            .pipe(cache('coffee'))
            .pipe(cjsx())
            .on('error', options.errorHandler)
            .pipe(gulp.dest options.dir)
            return stream

### <a name="help"/>help(gulp, options={})###
Help out a gulp object by adding helpers and shortcuts to it

#### Arguments
1. `gulp` *('Object')*: Gulp object
2. `options` *(`Object`)*: Options for the task
* `options.src` *(`String`|`Array`)*: Glob of source scripts to use. Defaults to src/
* `options.dir` *(`String`)*: Output directory of javascripts. Defaults to lib

#### Source

    exports.help = (_gulp, options = {}) ->
        options = _.extend {
            src: './src/**/*.coffee'
            dir: './lib/'
        }, options
        _.extend _gulp,
            coffee: exports.coffee(options)
            browserify: _.partial(exports.browserify, options.src, options.dir)
            watchSrc: (args...) ->
                _gulp.watch options.src, args...
