assert   = require 'assert'
buildSearch = require '../../lib'

describe 'test search', ->

  describe 'with newline delim', ->

    it 'should find two strings', () ->

      testString = 'some string\nfor testing'

      search = buildSearch delim:'\n', min:1
      results = search testString # gives before:'some string',delim:'\n'
      end = search.end()
      expectedResults = [ 'some string', 'for testing' ]
      assert.equal results.length, 2, 'search should return two results'
      assert.equal results[0].before, expectedResults[0]
      assert.equal results[0].delim, '\n'
      assert.equal results[1].string, expectedResults[1]
      assert.equal end.string, undefined

  describe 'with newline delim', ->

    it 'should find two strings', () ->

      testString = 'some{{key'

      search = buildSearch delim:/(?:[^\\]|\\\\)({{)/, min:4 # non-escaped open braces
      results = search testString
      end = search.end()
      expectedResults = [ 'som', 'key' ]
      assert.equal results.length, 1, 'search should return a single result'
      assert.equal results[0].before, expectedResults[0]
      assert.equal results[0].delim, 'e{{'
      assert.equal results[0].g1, '{{'
      assert.equal end.string, 'key'

  describe 'with newline delim', ->

    it 'should find two strings', () ->

      testString = 'some {{key}} string'

      search = buildSearch delim:/(?:[^\\]|\\\\)({{)/, min:4, recurse:false

      results1 = search testString
      search.delim /(?:[^\\]|\\\\)(}})/, 4
      results2 = search()
      end = search.end()

      assert.equal results1.length, 1, 'search should return a single result'

      assert.equal results1[0].before, 'some'
      assert.equal results1[0].delim, ' {{'
      assert.equal results1[0].g1, '{{'

      assert.equal results2.length, 1, 'search should return a single result'

      assert.equal results2[0].before, 'ke'
      assert.equal results2[0].delim, 'y}}'
      assert.equal results2[0].g1, '}}'

      assert.equal end.string, ' string'

  describe 'with only delim', ->

    it 'should find nothing', () ->

      testString = 'delim'

      search = buildSearch delim:'delim', min:5

      results = search testString
      end = search.end()

      assert.equal results.length, 1, 'search should return a single result'

      assert.equal results[0].before, '', 'before should be an empty string'
      assert.equal results[0].delim, 'delim', 'delim is `delim`'

      assert.equal end.string, undefined, 'end string should be undefined'

  describe 'with delim at start', ->

    it 'should find delim and later string', () ->

      testString = 'delim and more'

      search = buildSearch delim:'delim', min:5

      results = search testString
      end = search.end()

      assert.equal results.length, 2, 'search should return a double result'

      assert.equal results[0].before, '', 'before should be an empty string'
      assert.equal results[0].delim, 'delim', 'delim is `delim`'

      assert.equal results[1].string, ' and '

      assert.equal end.string, 'more'
