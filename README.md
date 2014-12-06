# Accord Watcher
Allows accord to recompile files when they change.

## Features
- individual file watching, but not adding files based on directory paths or ignore patterns... just individual files because this module should remain very unopinionated.
- advanced specification of compile jobs:
  - specifying what data gets passed to which file, and what plugins/extensions are used for each file (in the case of non-isolated files)
  - what each file compiles into, including 1:many compiles
  - what operations are performed on each file (may include multiple operations from different adapters)
- keeping track of inter-file dependencies, and recompiling whenever those dependencies are modified

## Compile Rule Spec
Compile Rules define the file we're starting with, the transformations applied to the file, and where the result of those transformations goes. They basically describe recurring compilation jobs.

These rules are stored as a list of objects, with each object representing a single rule. There may be multiple rules per file - for example, if one file needs to be compiled with several different sets of data, as is the case with templates for pages where the content is stored in an external CMS, or in Markdown files (which don't support specifying a template).

### Input File
The path to the file being compiled. If you are (for example) using a template to compile markdown files, then this is the path to the template, and the markdown files would be considered data, not the input file. You cannot specify multiple files here: many:1 compilations are done by compiling an initial file that references all of the other files that get used in the rule. Those other files get tracked as dependencies of the initial file.

### Output File
The file that the result of the rule should be written to. You cannot specify multiple files here: 1:many compilations are done by using multiple rules, each with the same input file, but different output files (and whatever other alterations are needed - like sending different data to each rule).

### Data
The data that is sent to the job, as a JSON-sterilizable object. In many cases, this will just be `undefined`.

Support for non-JSON datatypes may be added in a future release through the use of JASON or [protocol-buffers](https://github.com/mafintosh/protocol-buffers).

### Extensions


### Operation
Describes what to do with the file. Can be any of the following, so long as the adapter supports it:
- render
- compileClient


```coffee
operations: [
  {
    name: 'coffee'
    method: 'render'
    options: {}
    data: undefined
  }
  {
    name: 'minify-html'
    method: 'render'
    options: {}
    data: undefined
  }
  {
    name: 'inline-source-map'
    method: 'render'
    options: {}
    data: undefined
  }
]
input: "./file.coffee"
output: "./file.js"
```


if you want data to be watched, then put the data in a file and use a transform that reads the file, adds it to the deps, and then passes the data to the next options object

the only operations that are actually applicable here are compileClient and render... switch to just using names like jade-html or jade-js to denote what operation is being applied to the text.

make a file lookup function that returns file objects so we can have a fully fake filesystem

make a path watcher shim that works with fake file objects... or give them their own on-changed event or something
