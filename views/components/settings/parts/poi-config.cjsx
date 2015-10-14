path = require 'path-extra'
fs = require 'fs-extra'
remote = require 'remote'
i18n = require 'i18n'
{__, __n} = i18n
{$, $$, _, React, ReactBootstrap, FontAwesome, ROOT} = window
{Grid, Col, Button, ButtonGroup, Input, Alert, OverlayTrigger, Tooltip} = ReactBootstrap
{config, toggleModal} = window
{APPDATA_PATH} = window
{showItemInFolder, openItem} = require 'shell'

Divider = require './divider'
NavigatorBar = require './navigator-bar'
PoiConfig = React.createClass
  getInitialState: ->
    language: config.get 'poi.language', navigator.language
    enableConfirmQuit: config.get 'poi.confirm.quit', false
    enableNotify: config.get 'poi.notify.enabled', true
    notifyVolume: config.get 'poi.notify.volume', 1.0
    mapStartCheckShip: config.get 'poi.mapstartcheck.ship', false
    freeShipSlot: config.get 'poi.mapstartcheck.freeShipSlot', 4
    mapStartCheckItem: config.get 'poi.mapstartcheck.item', true
  handleSetConfirmQuit: ->
    enabled = @state.enableConfirmQuit
    config.set 'poi.confirm.quit', !enabled
    @setState
      enableConfirmQuit: !enabled
  handleSetNotify: ->
    enabled = @state.enableNotify
    config.set 'poi.notify.enabled', !enabled
    @setState
      enableNotify: !enabled
  handleChangeNotifyVolume: (e) ->
    volume = @refs.notifyVolume.getValue()
    volume = parseFloat(volume)
    return if volume is NaN
    config.set('poi.notify.volume', volume)
    @setState
      notifyVolume: volume
  handleSetMapStartCheckShip: ->
    enabled = @state.mapStartCheckShip
    config.set 'poi.mapstartcheck.ship', !enabled
    @setState
      mapStartCheckShip: !enabled
  handleSetMapStartCheckFreeShipSlot: (e) ->
    freeShipSlot = parseInt @refs.freeShipSlot.getValue()
    config.set 'poi.mapstartcheck.freeShipSlot', freeShipSlot
    @setState
      freeShipSlot: freeShipSlot
  handleSetMapStartCheckItem: ->
    enabled = @state.mapStartCheckItem
    config.set 'poi.mapstartcheck.item', !enabled
    @setState
      mapStartCheckItem: !enabled
  handleSetLanguage: (language) ->
    language = @refs.language.getValue()
    return if @state.language == language
    config.set 'poi.language', language
    i18n.setLocale language
    @setState {language}
  handleClearCookie: (e) ->
    remote.getCurrentWebContents().session.clearStorageData {storages: ['cookies']}, ->
      toggleModal __('Delete cookies'), __('Success!')
  handleClearCache: (e) ->
    remote.getCurrentWebContents().session.clearCache ->
      toggleModal __('Delete cache'), __('Success!')
  render: ->
    <form id="poi-config">
      <div className="form-group" id='navigator-bar'>
        <Divider text={__ 'Browser'} />
        <NavigatorBar />
        {
          if process.platform isnt 'darwin'
            <Grid>
              <Col xs={12}>
                <Input type="checkbox" label={__ 'Confirm before exit'} checked={@state.enableConfirmQuit} onChange={@handleSetConfirmQuit} />
              </Col>
            </Grid>
        }
      </div>
      <div className="form-group">
        <Divider text={__ 'Notification'} />
        <Grid>
          <Col xs={6}>
            <Button bsStyle={if @state.enableNotify then 'success' else 'danger'} onClick={@handleSetNotify} style={width: '100%'}>
              {if @state.enableNotify then '√ ' else ''}{__ 'Enable notification'}
            </Button>
          </Col>
          <Col xs={6}>
            <OverlayTrigger placement='top' overlay={
                <Tooltip>{__ 'Volume'} <strong>{parseInt(@state.notifyVolume * 100)}%</strong></Tooltip>
              }>
              <Input type="range" ref="notifyVolume" onInput={@handleChangeNotifyVolume}
                min={0.0} max={1.0} step={0.05} defaultValue={@state.notifyVolume} />
            </OverlayTrigger>
          </Col>
        </Grid>
      </div>
      <div className="form-group" >
        <Divider text={__ 'Slot check'} />
        <div style={display: "flex", flexFlow: "row nowrap"}>
          <div style={flex: 2, margin: "0 15px"}>
            <Input type="checkbox" label={__ 'Ship slots'} checked={@state.mapStartCheckShip} onChange={@handleSetMapStartCheckShip} />
          </div>
          <div style={flex: 2, margin: "0 15px"}>
            <Input type="checkbox" label={__ 'Item slots'} checked={@state.mapStartCheckItem} onChange={@handleSetMapStartCheckItem} />
          </div>
        </div>
        <div style={flex: 2, margin: "0 15px"}>
          <Input type="number" label={__ 'Warn when the number of empty ship slots is less than'} ref="freeShipSlot" value={@state.freeShipSlot} onChange={@handleSetMapStartCheckFreeShipSlot} placeholder="船位警告触发数" />
        </div>
      </div>
      <div className="form-group">
        <Divider text={__ 'Cache and cookies'} />
        <Grid>
          <Col xs={6}>
            <Button bsStyle="danger" onClick={@handleClearCookie} style={width: '100%'}>
              {__ 'Delete cookies'}
            </Button>
          </Col>
          <Col xs={6}>
            <Button bsStyle="danger" onClick={@handleClearCache} style={width: '100%'}>
              {__ 'Delete cache'}
            </Button>
          </Col>
          <Col xs={12}>
            <Alert bsStyle='warning' style={marginTop: '10px'}>
              {__ 'If connection error occurs frequently, delete both of them.'}
            </Alert>
          </Col>
        </Grid>
      </div>
      <div className="form-group">
        <Divider text={__ 'Language'} />
        <Grid>
          <Col xs={6}>
            <Input type="select" ref="language" value={@state.language} onChange={@handleSetLanguage}>
              <option value="zh-CN">简体中文</option>
              <option value="zh-TW">正體中文</option>
              <option value="ja-JP">日本語</option>
              <option value="en-US">English</option>
            </Input>
          </Col>
        </Grid>
      </div>
    </form>

module.exports = PoiConfig
