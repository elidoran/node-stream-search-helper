findString = (delim, string) ->
  index = string.indexOf delim                 # find delim
  if index > -1 then index:index, delim:delim  # if found, build return result

findRegex = (regex, string, groups) ->
  match = regex.exec string                         # use regex to match
  if match?                                         # only make result when matched
    result = index:match.index, delim:match[0]      # build result index/delim
    result['g' + i] = match[i] for i in [1..groups] # copy capture groups
  return result

module.exports = (options) ->

  store = ''  # holds previous string value based on min/keep
  recurse = options.recurse ? true # do another search on remaining string
  groups = options.groups ? 1

  # these will be set by search.delim() below before returning the search fn
  delim = '' ; keep = 0 ; find = null

  # searches input for the delim; may recurse
  search = (input = '', resultsArray = []) ->
    # combine stored string with new input string
    string = store + input
    # reset `store` to empty string
    store = ''
    # unless there is enough string to search just store it and return
    unless string.length >= keep
      store = string
      return resultsArray

    # check for delim using `find` which is different for regex and string delims
    # regex.exec(string), or string.indexOf() adaptation
    found = find delim, string, groups

    if found?.index? # if found, provide string leading up to delim, and the delim

      # # Reuse the `found` object as our return result
      # set the string *before* the found delim into `found`
      found.before = string[...found.index]
      # change the string to be what's after the delim
      string = string[found.index + found.delim.length...]
      # delete the index so it's not in the returned result
      delete found.index
      # add to the results array
      resultsArray.push found

      # do another search on what remains (repeat above steps on remaining string...)
      # pass our results array so it is added to
      if recurse then search string, resultsArray
      # else store the string for later and fall-thru so done() is called
      else store = string

    else # not found, so, keep only what we need, pass on the rest
      if keep > 0 # retain only `keep` (min - 1) chars
        searched = string:string[...-keep]
        store = string[-keep...]
      else # don't keep any, pass on all of it
        searched = string:string
        # store is already set to ''

      # only add this result is there was some content to it
      if searched.string.length > 0 then resultsArray.push searched

    return resultsArray  # done with search, return array of results

  # like flush() for a stream, gets what has been stored up, unprocessed
  search.end = ->
    result = if store.length > 0 then string:store else {}
    store = ''
    return result

  # allows changing the delim and min (keep) values
  search.delim = (newDelim, newOptions) ->
    delim = newDelim
    find = if 'string' is typeof delim then findString else findRegex
    min = newOptions?.min ? options.min
    if min? then keep = min - 1
    else if 'string' is typeof delim then keep = delim.length - 1
    else keep = 0
    groups = newOptions?.groups ? groups

  # configure now based on options
  search.delim options.delim ? '\n', options

  # return our search function (which has sub-functions)
  return search
