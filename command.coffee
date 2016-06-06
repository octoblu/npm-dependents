colors   = require 'colors'
dashdash = require 'dashdash'
fs       = require 'fs'
_        = require 'lodash'

NpmDependents = require './index.coffee'
PACKAGE_JSON  = require './package.json'

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help'
},{
  names: ['json', 'j']
  type: 'bool'
  help: 'JSON output'
}, {
  names: ['list', 'l']
  type: 'bool'
  help: 'List all dependents'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version'
}]

class Command
  constructor: (@argv) ->
    @parser = dashdash.createParser options: OPTIONS

  fatal: (error) =>
    console.error error.stack
    process.exit 1

  getOpts: =>
    opts = @parser.parse @argv
    {help, json, list, version} = opts
    @_printVersion() if version
    npmPackage = _.first opts._args
    npmPackage = @_getFromPackageJSON() unless npmPackage?

    unless npmPackage? && !help
      @_printHelp {help, npmPackage}

    return {json, list, npmPackage}

  run: =>
    {json, list, npmPackage} = @getOpts()

    return @_list {json, npmPackage} if list
    return @_count {json, npmPackage}

  _count: ({json, npmPackage}) =>
    npmDependents = new NpmDependents {npmPackage}
    npmDependents.list (error, dependents) =>
      return @fatal error if error?
      return @_printJSON count: _.size(dependents) if json
      console.log "Number of dependents: #{_.size dependents}"

  _getFromPackageJSON: =>
    try
      JSON.parse(fs.readFileSync('./package.json')).name

  _list: ({json, npmPackage}) =>
    npmDependents = new NpmDependents {npmPackage}
    npmDependents.list (error, dependents) =>
      return @fatal error if error?
      return @_printJSON dependents if json
      _.each dependents, (dependent) =>
        console.log dependent

  _printHelp: ({help, npmPackage}) =>
    console.log "usage: npm-dependents [options] <npm-package>\n"
    console.log "If <npm-package> is ommited, will try to auto-discover"
    console.log "from a package.json in the current directory."
    console.log "options:\n"
    console.log @parser.help()
    process.exit 0 if help

    unless npmPackage?
      console.log colors.red '  <npm-package> is required or must be run from directory containing a package.json'
    process.exit 1

  _printJSON: (obj) =>
    console.log JSON.stringify(obj, null, 2)

  _printVersion: =>
    console.log "v#{PACKAGE_JSON.version}"
    process.exit 0

module.exports = Command
