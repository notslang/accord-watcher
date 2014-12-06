should = require 'should'
Watcher = require '../lib'
W = require 'when'
File = require 'fobject'

describe 'Watcher', ->
  before =>
    @watcher = new Watcher()

  it 'should execute rules', (done) =>
    outputFile = new File('./test/fixtures/output.coffee')
    inputFile = new File('./test/fixtures/input.coffee')
    inputFile.write(
      'console.log 5 + 10'
    ).then( =>
      @watcher.addRule(
        './test/fixtures/input.coffee'
        './test/fixtures/output.coffee'
        {
          name: 'coffee-script'
          method: 'render'
        }
      )
    ).delay(1500).then( ->
      outputFile.read(encoding: 'utf8')
    ).then((res) ->
      res.should.eql(
        '(function() {\n  console.log(5 + 10);\n\n}).call(this);\n'
      )
    ).then(inputFile.unlink).then(outputFile.unlink).done(done)
