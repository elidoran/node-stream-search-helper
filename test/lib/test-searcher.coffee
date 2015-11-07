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

  describe 'with open braces delim', ->

    it 'should find two strings', () ->

      testString = 'some{{key'

      search = buildSearch delim:/(\\{1,2})?({{|}})/, min:4, groups:2
      results = search testString
      end = search.end()
      expectedResults = [ 'some', 'key' ]
      assert.equal results.length, 1, 'search should return a single result'
      assert.equal results[0].before, expectedResults[0]
      assert.equal results[0].delim, '{{'
      assert.equal results[0].g1, undefined, 'no g1 should be captured'
      assert.equal results[0].g2, '{{'
      assert.equal end.string, 'key'

  describe 'with open/close braces delim', ->

    it 'should find two strings', () ->

      testString = 'some {{key}} string'

      search = buildSearch delim:/(\\{1,2})?({{)/, min:4, recurse:false, groups:2

      results1 = search testString
      search.delim /(\\{1,2})?(}})/
      results2 = search()
      end = search.end()

      assert.equal results1.length, 1, 'search should return a single result'

      assert.equal results1[0].before, 'some '
      assert.equal results1[0].delim, '{{'
      assert.equal results1[0].g1, undefined, 'no g1 should be captured'
      assert.equal results1[0].g2, '{{'

      assert.equal results2.length, 1, 'search should return a single result'

      assert.equal results2[0].before, 'key'
      assert.equal results2[0].delim, '}}'
      assert.equal results2[0].g1, undefined, 'no g1 should be captured'
      assert.equal results2[0].g2, '}}'

      assert.equal end.string, ' string'

  describe 'with escaped slash before open braces delim', ->

    it 'should find two strings and show double escape in g1', () ->

      testString = 'some\\\\{{key'

      search = buildSearch delim:/(\\{1,2})?({{|}})/, min:4, groups:2
      results = search testString
      end = search.end()
      expectedResults = [ 'some', 'key' ]
      assert.equal results.length, 1, 'search should return a single result'
      assert.equal results[0].before, expectedResults[0]
      assert.equal results[0].delim, '\\\\{{'
      assert.equal results[0].g1, '\\\\'
      assert.equal results[0].g2, '{{'
      assert.equal end.string, 'key'

  describe 'with escaped slash before open/close braces delim', ->

    it 'should find two strings and show double escape in g1', () ->

      testString = 'some \\\\{{key}} string'

      search = buildSearch delim:/(\\{1,2})?({{)/, min:4, recurse:false, groups:2

      results1 = search testString
      search.delim /(\\{1,2})?(}})/
      results2 = search()
      end = search.end()

      assert.equal results1.length, 1, 'search should return a single result'

      assert.equal results1[0].before, 'some '
      assert.equal results1[0].delim, '\\\\{{'
      assert.equal results1[0].g1, '\\\\'
      assert.equal results1[0].g2, '{{'

      assert.equal results2.length, 1, 'search should return a single result'

      assert.equal results2[0].before, 'key'
      assert.equal results2[0].delim, '}}'
      assert.equal results2[0].g1, undefined, 'no g1 should be captured'
      assert.equal results2[0].g2, '}}'

      assert.equal end.string, ' string'

  describe 'with escape before open braces delim', ->

    it 'should find two strings and show single escape in g1', () ->

      testString = 'some\\{{key'

      search = buildSearch delim:/(\\{1,2})?({{|}})/, min:4, groups:2
      results = search testString
      end = search.end()
      assert.equal results.length, 1, 'search should return a single result'
      assert.equal results[0].before, 'some'
      assert.equal results[0].delim, '\\{{'
      assert.equal results[0].g1, '\\'
      assert.equal results[0].g2, '{{'

      assert.equal end.string, 'key'

  describe 'with escape before open/close braces delim', ->

    it 'should find two strings and show single escape in g1', () ->

      testString = 'some \\{{key\\}} string'

      search = buildSearch delim:/(\\{1,2})?({{)/, min:4, recurse:false, groups:2

      results1 = search testString
      search.delim /(\\{1,2})?(}})/
      results2 = search()
      end = search.end()

      assert.equal results1.length, 1, 'search should return a single result'
      assert.equal results1[0].before, 'some '
      assert.equal results1[0].delim, '\\{{'
      assert.equal results1[0].g1, '\\'
      assert.equal results1[0].g2, '{{'

      assert.equal results2.length, 1, 'search should return a single result'
      assert.equal results2[0].before, 'key'
      assert.equal results2[0].delim, '\\}}'
      assert.equal results2[0].g1, '\\'
      assert.equal results2[0].g2, '}}'

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

  describe 'with delim split across search', ->

    it 'should return all results', ->

      testString1 = 'oneDEL'
      testString2 = 'IMtwoDELIMthree'

      search = buildSearch delim:'DELIM', min:'5', recurse:true

      results = search testString1
      assert.equal results.length, 1, 'search should return 1 result from first search'
      assert.equal results[0].string, 'on'

      results = search testString2
      assert.equal results.length, 3, 'search should return 3 results from second search'
      assert.equal results[0].before, 'e'
      assert.equal results[0].delim, 'DELIM'
      assert.equal results[1].before, 'two'
      assert.equal results[1].delim, 'DELIM'
      assert.equal results[2].string, 't'

      end = search.end()
      assert.equal end.string, 'hree'
