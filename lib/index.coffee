findString = (delim, string) ->
  index = string.indexOf delim
  if index > -1 then index:index, match:delim

findRegex = (delim, string) ->
  result = delim.exec string
  if result? then result = index:result.index, match:result[0], g1:result?[1]

module.exports = (options) ->

  store = ''  # holds previous string value based on min/keep
  recurse = options.recurse ? true # do another search on remaining string

  # these will be set by search.delim() below before returning the search fn
  delim = '' ; keep = 0 ; find = null

  # searches input for the delim; may recurse
  search = (input = '', resultsArray = []) ->
    # combine stored string with new input string
    string = store + input

    # unless there is enough string to search just store it and return
    unless string.length >= keep
      store = string
      return resultsArray

    # check for delim using `find` which is different for regex and string delims
    found = find delim, string  # regex.exec(string), or string.indexOf() adaptation

    if found?.index? # if found, provide string leading up to delim, and the delim
      matched = before:string[...found.index], delim:found.match
      matched.g1 = found.g1 if found.g1?
      resultsArray.push matched
      string = string[found.index + found.match.length...]

      # do another search on what remains (repeat above steps on remaining string...)
      # pass our results array so it is added to
      if recurse then search string, resultsArray
      else store = string

    else # not found, so, keep only what we need, pass on the rest
      if keep > 0 # retain only `keep` (min - 1) chars
        searched = string:string[...-keep]
        store = string[-keep...]
      else # don't keep any, pass on all of it
        searched = string:string
        store = ''

      # only add this result is there was some content to it
      if searched.string.length > 0 then resultsArray.push searched

    return resultsArray  # done with search, return array of results

  # like flush() for a stream, gets what has been stored up, unprocessed
  search.end = ->
    result = if store.length > 0 then string:store else {}
    store = ''
    return result

  # allows changing the delim and min (keep) values
  search.delim = (newDelim, min) ->
    delim = newDelim
    find = if 'string' is typeof delim then findString else findRegex
    min ?= options.min
    if min? then keep = min - 1
    else if 'string' is typeof delim then keep = delim.length - 1
    else keep = 0

  # configure now based on options
  search.delim options.delim ? '\n', options.min

  # return our search function (which has sub-functions)
  return search
