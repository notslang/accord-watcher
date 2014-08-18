# Accord Watcher
Allows accord to recompile files when they change.

## Features
- individual file watching, but not adding files based on directory paths or ignore patterns... just individual files because this module should remain very unopinionated.
- advanced specification of compile jobs:
  - specifying what data gets passed to which file, and what plugins/extensions are used for each file (in the case of non-isolated files)
  - what each file compiles into, including 1:many compiles
  - what operations are performed on each file (may include multiple operations from different adapters)
- keeping track of inter-file dependencies, and recompiling whenever those dependencies are modified

## Compile Job Spec
The compile jobs are stored as a list of objects, with each object representing a single job. There may be multiple jobs per file - for example, if one file needs to be compiled with several different sets of data, as is the case with templates for pages where the content is stored in an external CMS, or in Markdown files (which don't support specifying a template).

### Input File
The path to the file being compiled. If you are (for example) using a template to compile markdown files, then this is the path to the template, and the markdown files would be considered data, not the input file.

### Output File
The file that the result of the job should be written to. You cannot specify multiple files here: 1:many compilations are done by using multiple jobs, each with the same input file, but different output files (and whatever other alterations are needed - like sending different data to each job).

### Data
The data that is sent to the job, as a JSON-sterilizable object. In many cases, (including every adapter that is `isolated`) this will just be `undefined`. Data is only needed if you're compiling a template.

Support for non-JSON datatypes may be added in a future release through the use of JASON.

### Extensions


### Operation
Describes what to do with the file. Can be any of the following, so long as the adapter supports it:
- render
- compile
- compileClient