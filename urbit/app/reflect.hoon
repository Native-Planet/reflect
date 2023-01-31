/+  dbug, default-agent, schooner, server
|%
+$  state  (map @p @ud)
+$  card  card:agent:gall
::++  base-url  "http://192.168.0.104"
++  base-url  "http://localhost:2015"
++  content-location  '/reflect/'
++  header  '<head><base href="./reflect/"></head>'

--
%-  agent:dbug
^-  agent:gall
=|  state
=*  state  -
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %.n) bowl)
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  
    :*  %pass  /eyre/connect  %arvo  %e
        %connect  `/reflect  %reflect
    ==
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  =vase
  ^-  (quip card _this)
  `this(state !<(_state vase))
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?>  =(src.bowl our.bowl)
  ?+    mark
    `this
    ::
      %handle-http-request
    =^  cards  state
      (handle-http !<([@ta =inbound-request:eyre] vase))
    [cards this]
  ==
  ::
  ++  handle-http
    |=  [eyre-id=@ta =inbound-request:eyre]
    ^-  (quip card _state)
    ::=/  =request:http  [method.request.inbound-request 'http://localhost:2015/' ~ ~]
    =/  =request:http  request.inbound-request
    ::~&  [eyre-id request]
    :: Set correct url
    =/  url  (trim 8 (trip url.request))
    ::~&  base-url
    ~&  url
    ::~&  (weld base-url (weld "/" q.url))
    :: Clean up incomming header list
    =|  hl=(map @t @t)  
    =.  hl  (~(gas by hl) header-list.request)
    =.  hl  (~(del by hl) 'connection')
    =.  hl  (~(del by hl) 'host')
    =.  header-list.request  ~(tap by hl)
    =.  url.request  (crip (weld base-url (weld "/" q.url)))
    =/  =task:iris  [%request request *outbound-config:iris]
    =/  =card:agent:gall  [%pass /reflect/[eyre-id] %arvo %i task]
    :_  state
        [card ~]
    ::=/  ,request-line:server
      ::(parse-request-line:server url.request.inbound-request)
    ::=+  send=(cury response:schooner eyre-id)
    ::?.  authenticated.inbound-request
      :::_  state
      ::%-  send
      ::[302 ~ [%login-redirect './apps/reflect']]
    ::::
    ::?+    method.request.inbound-request
      ::[(send [405 ~ [%stock ~]]) state]
      ::::
        ::%'GET'
      ::?+    site
        :::::_  state
        ::(send [404 ~ [%plain "404 - Not Found"]])
        ::::
          ::[%apps %reflect ~]
        :::_  state
        ::(send [200 ~ [%plain "200 - working"]])
      ::==
      ::::
        ::%'POST'
      :::_  state
      :::~  [%give %fact ~[/incs] %noun !>(~)]  ==
    ::==
  --
::
::
++  on-peek  on-peek:def
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%http-response *]
    `this
  ==
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card:agent:gall _this)
  =/  eyre-id  +<.wire
  ::=/  =simple-payload:http
  :: makes sure that the card is an http response from iris
  ?:  ?=(%http-response +<.sign-arvo)
  =/  payload=client-response:iris  +>.sign-arvo
    ?:  ?=(%finished -.payload)
      =/  response=[=response-header:http full-file=(unit mime-data:iris)]  +.payload
      =|  hl=(map @t @t)  
      =.  hl  (~(gas by hl) headers.response-header.response)
      =.  hl  (~(del by hl) 'content-length')
      =.  hl  (~(put by hl) 'Content-Location' content-location)
      =.  hl  (~(put by hl) 'Content-Base' content-location)
      ::=.  hl  (~(put by hl) 'Content-Length' '1256')
      =.  headers.response-header.response  ~(tap by hl)
      ?~  full-file.response
        `this
      =/  =simple-payload:http  
        =/  got-full-file  u.full-file.response
        ~&  full-file.response
        ?=  type.full-file  'text/html; charset=utf-8'
          =.  q.data.got-full-file  (runt [1 header] q.data.got-full-file)
        ~
        =/  data=(unit octs)  `(as-octs:mimes:html q.data.got-full-file)
        ::~&  ["headers" response-header.response]
        ::~&  ["data" data]
        [response-header.response data]

      ::~&  ["simple-payload" simple-payload]
      ::~&  ["eyre-id" eyre-id]
      ::~&  ["wire" wire]
      :_  this
        (give-simple-payload:app:server eyre-id simple-payload)
    (on-arvo:def wire sign-arvo)
  (on-arvo:def wire sign-arvo)
  ::?.  ?=([%iris %http-response %finished *] q.res)
    ::(strand-fail:strand %bad-sign ~)
  ::~&  +.q.res
  ::?~  full-file.client-response.q.res
    ::(strand-fail:strand %no-body ~)
++  on-fail  on-fail:def
--

