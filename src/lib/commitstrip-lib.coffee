
require('es6-promise').polyfill()

fetch = require 'node-fetch'
cheerio = require 'cheerio'

language = (l) ->
  (l || process.env.COMMITSTRIP_DEFAULT_LANGUAGE || 'en')
    .toLowerCase()

makeUrl = (l) ->
  "http://www.commitstrip.com/#{language(l)}/"

fetchCommitStrip = (uri) ->
  fetch(uri)
    .then (res) -> res.text()
    .then (body) -> cheerio.load body

latest = (l) ->
  byNumber(1, l)

byNumber = (page, l) ->
  fetchCommitStrip(makeUrl(l) + 'page/' + page)
    .then ($) ->
      fetchCommitStrip($('.excerpt a').first().attr('href'))
        .then ($) ->
          title: $('.entry-header h1').first().text()
          image: $('.entry-content img').first().attr('src')


pageCount = (l) ->
  fetchCommitStrip(makeUrl(l) + 'page/2/')
    .then ($) ->
      href = $('.wp-pagenavi a.last').attr('href')
      parseInt href.match(/page\/([0-9]+)\/$/)[1]

random = (l) ->
  pageCount(l).then (count) ->
    rnd = Math.floor(Math.random() * count) + 1
    byNumber(rnd, l)


module.exports =
  latest: latest
  pageCount: pageCount
  byNumber: byNumber
  random: random
