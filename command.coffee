colors   = require 'colors'
dashdash = require 'dashdash'
_        = require 'lodash'

NpmDependents = require './index.coffee'

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help'
},{
  names: ['json', 'j']
  type: 'bool'
  help: 'JSON output'
  env: 'DB_SCRIPTS_NODE_NAME'
}, {
  names: ['list', 'l']
  type: 'bool'
  help: 'List all dependents'
  env: 'DB_SCRIPTS_MONGODB_URI'
}]

class Command
  constructor: (@argv) ->
    @parser = dashdash.createParser options: OPTIONS

  fatal: (error) =>
    console.error error.stack
    process.exit 1

  getOpts: =>
    opts = @parser.parse @argv
    {help, json, list} = opts
    npmPackage = _.first opts._args

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

  _list: ({json, npmPackage}) =>
    npmDependents = new NpmDependents {npmPackage}
    npmDependents.list (error, dependents) =>
      return @fatal error if error?
      return @_printJSON dependents if json
      _.each dependents, (dependent) =>
        console.log dependent

  _printHelp: ({help, npmPackage}) =>
    console.log "usage: npm-dependents [options] <npm-package>\n"
    console.log "options:\n"
    console.log @parser.help includeEnv: true
    process.exit 0 if help

    console.log colors.red '  <npm-package> is required' unless npmPackage?
    process.exit 1

  _printJSON: (obj) =>
    console.log JSON.stringify(obj, null, 2)

module.exports = Command
