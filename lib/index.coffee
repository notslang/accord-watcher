PathWatcher = require 'pathwatcher'
File = require 'fobject'
_ = require 'lodash'
accord = require 'accord'

class Watcher
  ###*
   * Holds the rules that are used to produce the output files. The keys for
     the rules are the canonical filepaths of the output files (because each
     output file can only have one rule that is used to produce it).
   * @type {Object}
  ###
  _rules: undefined

  ###*
   * Holds the watchers. Each key is the filepath to the file being watched.
   * @type {Object}
  ###
  _watchers: undefined

  ###*
   * The latest Job result for each output file.
   * @type {Object}
  ###
  _latestJobResults: undefined

  constructor: ->
    @_rules = []
    @_watchers = []
    @_latestJobResults = []

  ###*
   * [addRule description]
   * @param {[type]} inputFile
   * @param {[type]} outputFile
   * @param {[type]} [operations...] This can be empty, it will just mean that
     the file is copied to the new location without any modification
  ###
  addRule: (inputFile, outputFile, operations...) =>
    @_rules.push(
      inputFile: inputFile
      outputFile: outputFile
      operations: operations
    )
    @_executeRule(@_rules[-1..][0])

  ###*
   * Test if we can get rid of a particular watcher, or if there are still rules
     that list it as a dep.
   * @param {String} path The canonicalized path to the file being watched
  ###
  _watcherIsRemovable: (path) ->
    return false

  _handleFileChange: (event, path) =>
    for rule in @_getRulesForDep(path)
      @_executeRule(rule)

  ###*
   * Find all the relations that rely on a particular dep
   * @param {String} path
  ###
  _getRulesForDep: (path) =>
    relationsForDep = []
    for file, rule in @_rules
      if path in @_latestJobResults[file].dependencies
        relationsForDep.push(rule)
    return relationsForDep

  ###*
   * Run the operations defined in the rule, and write the result to
     Rule.outputFile. This should be called whenever the input file is modified
     or right after the rule is added to start compilation and determine the
     deps
   * @param {Object} rule
   * @todo Add optimization by just copying files to their destination if their
     rule doesn't define any operations.
  ###
  _executeRule: (rule) =>
    if rule.operations.length isnt 0
      operations = _.clone(rule.operations, true) # we're going to mutate it
      firstOp = operations.shift()
      adapter = accord.load(firstOp.name)
      firstOp.method = (
        # TODO: make this a bit more robust
        if firstOp.method is 'render'
          'renderFile'
        else
          'compileFileClient'
      )
      firstOp.options ?= {}
      if firstOp.data?
        firstOp.options.data = firstOp.data
      promise = adapter[firstOp.method](
        rule.inputFile,
        firstOp.options
      )

      # chain each operation onto the promise
      for operation in operations
        adapter = accord.load(firstOp.name)
        operation.options.data = operation.data
        # TODO: add something here to check if the file has been modified since
        # the job began & kill the promise if the results no longer matter
        promise = promise.then(
          _.partialRight(adapter[operation.method], operation.options)
        )

      promise.done((job) =>
        console.log job
        console.log rule
        # TODO: track this write... we just leave it alone right now
        new File(rule.outputFile).write(job.text)
        @_latestJobResults[rule.outputFile] = job
        for dep in job.dependancies
          @_watchers[rule.inputFile] ?= new PathWatcher(
            rule.inputFile,
            @_handleFileChange
          )
      )
    return

module.exports = Watcher
