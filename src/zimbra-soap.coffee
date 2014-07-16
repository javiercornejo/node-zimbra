request = require 'request'
js2xml = require 'js2xmlparser'
xml2js = require('xml2js').parseString
processors = require '../node_modules/xml2js/lib/processors'

class ZimbraSoap
  constructor: (@soap_host, @admin_user = '', @admin_pass = '') ->
    @def_url = @soap_host

  _conformMessage: (body) ->
    data = {
      "@": {
        "xmlns:soap": "http://www.w3.org/2003/05/soap-envelope",
        "xmlns:zadmin": "urn:zimbraAdmin",
        "xmlns:zaccount": "urn:zimbraAccount",
        "xmlns:zmail": "urn:zimbraMail",
        "xmlns:zsync": "urn:zimbraSync",
        "xmlns:zvoice": "urn:zimbraVoice",
        "xmlns:zrepl": "urn:zimbraRepl",
      },
      "soap:Header": {
        "context": {
          "@": { "xmlns": "urn:zimbra" }
        }
      },
      "soap:Body": body
    }
    js2xml "soap:Envelope", data

  _getSoapRequest: (message, cb) ->
    req_opts = {
      url: @def_url,
      method: 'POST',
      headers: {'Content-Type': 'application/soap+xml; charset=utf-8'}
      body: message,
      strictSSL: false,
      jar: true,
      timeout: 10000
    }

    request req_opts, (err, response, body) ->
      if cb?
        if not err
          parser_opts = {
            tagNameProcessors: [processors.stripPrefix],
            normalizeTags: true
            explicitArray: false
          }
          xml2js body, parser_opts, (err, res) ->
            if not err
              cb null, res
            else
              cb err, null
        else
          cb err, null
  
  method: (method, params, cb) ->
    #Internal callback
    if method.indexOf 'zadmin' > -1
      @def_url = "#{@soap_host}:7071/service/admin/soap"
    else
      @def_url = "#{@soap_host}/service/soap"
    _cb = (err, res) ->
      if not err and res?
        if cb?
          if res.envelope?.body?.fault?
            cb "ZIMBRA_ERROR: #{res.envelope.body.fault.reason.text}", null
          else if res.envelope?.body?
            cb null, res.envelope.body
          else
            cb 'INTERNAL_ERROR', res
      else
        cb err, null
    body = {}
    body[method] = params
    @_getSoapRequest @_conformMessage(body), _cb

exports.ZimbraSoap = ZimbraSoap