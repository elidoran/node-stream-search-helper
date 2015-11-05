# string-search-helper
[![Build Status](https://travis-ci.org/elidoran/node-stream-search-helper.svg?branch=master)](https://travis-ci.org/elidoran/node-stream-search-helper)
[![Dependency Status](https://gemnasium.com/elidoran/node-stream-search-helper.png)](https://gemnasium.com/elidoran/node-stream-search-helper)
[![npm version](https://badge.fury.io/js/stream-search-helper.svg)](http://badge.fury.io/js/stream-search-helper)

Aids streams searching with string or regex delimiters.

Feed strings into it and it will search for the delim and return sections. It retains enough content to find delims across search calls which allows streams to provide input in chunks.

Used by:

1. [each-part](https://github.com/elidoran/node-each-part) to split a stream into parts based on a delimiter
2. [kevas](https://github.com/elidoran/node-kevas) to find keys in text and replace with values
3. [sourcemap-extractor](https://github.com/elidoran/node-sourcemap-extractor) to strip out an inline source map from a file

## Install

```sh
npm install string-search-helper --save
```

## Usage: Standalone

Shows a simple operation example.

```coffeescript
buildSearch = require 'string-search-helper'

# # use a string delim
search = buildSearch delim:' '

string = 'some test string'

results = search string

results = [ # an array, each a search match
  before:'some', delim:' '  # `before` is the string content before the delim
  before:'test', delim:' '  # recurse:true by default so matches a second time
]

end = search.end() # get any leftovers (think 'flush')
end = # is an object containing `string` property with any leftover text
  string:'string'


# # use a regular expression delim
search = buildSearch delim:/({{|}})/

string = 'some {{key}} string'

results = search string

results = [ # an array, each a search match
  before:'some ', delim:'{{'  # `delim` is the delim matched, helpful for regex
  before:'key', delim:'}}'    # note delim is different this time
]

end = search.end() # get any leftovers (think 'flush')
end = # is an object containing `string` property with any leftover text
  string:' string'

```

## Usage: By Stream

Show how [each-part]() stream transform uses this.

```coffeescript
# search string with delim
results = search string

for result in results
  # a `string` result should be stored cuz we haven't found a delim yet
  if result.string? then # it stores the value for a future `part`

  # `before` means we found a delim, so, combine with stored and pass on
  else if result.before? then # combine it with stored value and push it
```

## API: buildSearch(options)

Build options:

1. [required] delim - must be a string or a regular expression
2. [optional] min - minimum characters required for a delim match. When `delim` is a string then its length is used as `min`. When `delim` is a regex you must specify a `min` for things to work.
3. [optional] recurse - defaults to true, whether search should search repeatedly until it fails to find a delim and then return an array of results.

```coffeescript
buildSearch = require 'string-search-helper'

search = buildSearch
  delim: /some regex delim/
  min: 123 # search will retain 122 characters of text to use in next search (123 - 1)
  recurse: false

# `search` is a function. it has two sub-function properties: delim() and end()
```

## API: search(string)

The function performing the searches using strings passed to it.

It has two sub-function properties which are described in their own API sections below.

```coffeescript
string1 = 'some string to search first'
string2 = 'another string for second search call'

results = search string1
# process results array

# add another string to continue the search
results = search string2
# process results array

# all done searching, no more strings to add, so get what's left
end = search.end()
```


## API: search.delim(stringOrRegex[, min])

Change the `delim` and optionally the `min` value. Allows changing the delim between individual search calls.

```coffeescript
# do a search
results = search string1

# now change the delim
search.delim 'new delim'

# and do another search
results = search string2
```


## API: search.end()

As with streams some content can be left when there's no more to add. Use this sub-function to get the leftover string.

```coffeescript
search = buildSearch delim:' '
results = search 'some string'
# results will have 'some' in it
# to get the leftover 'string' part:
end = search.end()
# end is an object with a `string` property, which, contains the value 'string'
```

## MIT License
