class @WalletReceiveIndexDialogViewController extends ledger.common.DialogViewController

  view:
    amountInput: '#amount_input'
    receiverAddress: "#receiver_address"
    accountsSelect: '#accounts_select'
    colorSquare: '#color_square'

  onAfterRender: ->
    super

    # apply params
    if @params.amount?
      @view.amountInput.val @params.amount

    # configure view
    @view.qrcode = new QRCode "qrcode_frame",
      text: ""
      width: 196
      height: 196
      colorDark : "#000000"
      colorLight : "#ffffff"
      correctLevel : QRCode.CorrectLevel.H
    @view.amountInput.amountInput(ledger.preferences.instance.getBitcoinUnitMaximumDecimalDigitsCount())
    @_updateAccountsSelect()
    @_updateColorSquare()
    @_updateQrCode()
    @_updateReceiverAddress()
    @_listenEvents()

  onShow: ->
    super
    @view.amountInput.focus()

  mail: ->
    window.open 'mailto:?body=' + @_receivingAddress()

  print: ->
    @renderedSelector.print()

  _listenEvents: ->
    @view.amountInput.on 'keydown', (e) =>
      _.defer => @_updateQrCode()
    @view.accountsSelect.on 'change', =>
      @_updateColorSquare()
      @_updateQrCode()
      @_updateReceiverAddress()

  _updateQrCode: () ->
    l @_bitcoinAddressUri()
    @view.qrcode.makeCode(@_bitcoinAddressUri());

  _updateReceiverAddress: ->
    @view.receiverAddress.text @_receivingAddress()

  _bitcoinAddressUri: ->
    uri = "bitcoin:" + @_receivingAddress()
    uri += "?amount=#{ledger.formatters.fromSatoshiToBTC(@_selectedAmount())}" if @_selectedAmount() isnt "0" and @_selectedAmount() isnt 0
    uri

  _updateAccountsSelect: ->
    accounts = Account.displayableAccounts()
    for account in accounts
      option = $('<option></option>').text(account.name + ' (' + ledger.formatters.formatValue(account.balance) + ')').val(account.index)
      option.attr('selected', true) if @params.account_id? and account.index is +@params.account_id
      @view.accountsSelect.append option

  _updateColorSquare: ->
    @view.colorSquare.css('color', @_selectedAccount().get('color'))

  _selectedAccount: ->
    Account.find(index: parseInt(@view.accountsSelect.val())).first()

  _selectedAmount: ->
    ledger.formatters.fromValueToSatoshi(@view.amountInput.val() or "0")

  _receivingAddress: ->
    @_selectedAccount().getWalletAccount().getCurrentPublicAddress()