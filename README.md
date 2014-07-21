# node-zimbra

This package is designed to be the simplest way possible to communicate with Zimbra Soap Service. You can communitcate with SOAP service present in Zimbra Server. This is probed with 8.0+ version.

### Example:
The following example calls two Zimbra method getAuthToken and getAccountInfo.

```
ZimbraSoap = require('./soap').ZimbraSoap

zimbraSoap = new ZimbraSoap(CONFIG.zimbra.soap_url, CONFIG.zimbra.admin_user, CONFIG.zimbra.admin_pass)
  zimbraSoap.getAuthToken (err, token) ->
    if not err
      console.log "Token: #{token}"
      zimbraSoap.getAccountInfo employees[employees.length-1].email, token, (err, info) ->
        if not err
          console.log "#{employees[employees.length-1].email} - Existe"
        else
          #console.log "Error Somewhere 2 #{err}"
          console.log "#{employees[employees.length-1].email} - No Existe"
        employees.pop()
        checkEmail employees if employees.length > 0
    else
      console.log "Error Somewhere 1 #{err}"
```


