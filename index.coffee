_       = require 'lodash'
request = require 'request'

class NpmDependents
  constructor: ({@npmPackage}) ->
    throw new Error 'npmPackage is required' unless @npmPackage?

  list: (callback) =>
    request.get {
      url: 'http://registry.npmjs.org/-/_view/dependedUpon'
      qs:
        group_level: 2
        startkey: "[\"#{@npmPackage}\"]"
        endkey: "[\"#{@npmPackage}\",{}]"
        skip: 0
        limit: 1000
    }, (error, response, body) =>
      return callback error if error?
      return callback new Error(body) unless response.statusCode == 200
      return callback null, @processResponse body

  processResponse: (body) =>
    response = JSON.parse body
    _.map response.rows, (row) =>
      _.last row.key



module.exports = NpmDependents
