// ReSharper disable UnusedParameter
// ReSharper disable UseOfImplicitGlobalInFunctionScope
Ext.ns('PgmD.eds');
/**
 * @namespace PgmD.eds
 * @class NameField
 * @extemds Ext.form.TriggerField
 */
PgmD.eds.NameField = Ext.extend(Ext.form.TriggerField, {
	editable: false,
	multiSelect: true,
	records: {},
	triggerClass: 'x-form-names-trigger',
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		Ext.apply(me, {
			onTriggerClick: function (evt) {
				new Ext.Window({
					autoDestroy: true,
					constrain: true,
					height: 280,
					layout: 'fit',
					modal: true,
					title: 'Personnel Search',
					width: 220,
					items: [{
						autoScroll: true,
						border: false,
						filterSource: me.filterSource,
						multiSelect: me.multiSelect,
						ref: 'SearchPanel',
						source: me.source,
						xtype: 'EdsSearchPanel'
					}],
					buttons: [{
						text: 'Apply',
						iconCls: 'silk-disk',
						handler: function (item, e) {
							var win = item.ownerCt.ownerCt;
							win.SearchPanel.onAddClick(item, e);
							var store = win.SearchPanel.listview.getStore();
							var records = [];
							if (store.getCount() > 0) {
								var names = [];
								var bemsId = [];
								store.each(function (record) {
									names.push(record.get('BoeingDisplayName'));
									bemsId.push(record.get('BoeingBemsId'));
									records.push(record.copy());
									return true;
								});
								me.setValue(names.join('; '));
								me.bemsId.setValue(bemsId.join('; '));
								me.records = records;
							} else {
								me.setValue('');
								me.bemsId.setValue('');
							}
							if (me.checkSave) {
								if (me.originalValue !== me.getValue()) {
									var form = me.ownerCt.ownerCt;
									PgmD.panelDetail.SaveOnClosed.needSave = 1;
									form.addSaveCheck(false, PgmD.panelDetail.SaveOnClosed.objToSave, 'General Info', form.getForm());
								}
							}
							win.close();
						}
					}, {
						text: 'Cancel',
						iconCls: 'silk-cancel',
						handler: function (item, e) {
							item.ownerCt.ownerCt.close();
						}
					}],
					listeners: {
						show: function (win) {
							if (me.getValue().length > 0) {
								win.SearchPanel.listview.getStore().add(me.records);
							}
						}
					}
				}).show();
			}
		});
		me.constructor.superclass.initComponent.call(me);
	}
});
Ext.reg('EdsNameField', PgmD.eds.NameField);
/**
 * @namespace PgmD.eds
 * @class SearchField
 * @extends Ext.form.ComboBox
 */
PgmD.eds.SearchField = Ext.extend(Ext.form.ComboBox, {
	loadingText: 'Searching...',
	queryDelay: 750,
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		var tipFormat = '<p><b>BEMS ID:</b>&nbsp;&nbsp;{BoeingBemsId}</p>';
		tipFormat += '<p><b>Display Name:</b>&nbsp;&nbsp;{BoeingDisplayName}</p>';
		tipFormat += '<p><b>Department:</b>&nbsp;&nbsp;{DepartmentNumber}</p>';
		tipFormat += '<p><b>Telephone:</b>&nbsp;&nbsp;{TelephoneNumber}</p>';
		tipFormat += '<p><b>E-Mail:</b>&nbsp;&nbsp;{BoeingInternetEmail}</p>';
		tipFormat += '<p><b>US Citizen:</b>&nbsp;&nbsp;{UsPersonText}</p>';
		tipFormat += '<p><b>Source:</b>&nbsp;&nbsp;{Source}</p>';
		Ext.apply(me, {
			displayField: 'UniqueDisplayName',
			enableKeyEvents: true,
			forceSelection: true,
			hideTrigger: true,
			lazyRender: true,
			minChars: me.source === 'DB' ? 1 : 4,
			triggerAction: 'all',
			tpl: '<tpl for="."><div class="x-combo-list-item" ext:qwidth="250" ext:qtip="' + tipFormat + '" >{BoeingDisplayName}</div></tpl>',
			valueField: 'BoeingBemsId',
			store: new Ext.data.JsonStore({
				baseParams: {
					action: 'getPerson' + (me.source || 'EDS'),
					filterBy: '',
					filterSource: me.filterSource
				},
				proxy: new Ext.data.HttpProxy({
					disableCaching: false,
					method: 'GET',
					url: 'view/GetContent.aspx',
					failure: function (response, opts) {
						if (response.status === 0) {
							Ext.Msg.alert(response.statusText.toUpperCase(), 'WSSO Session Expired', function (btn) {
								top.location = PgmD.basePath;
							});
						}
					}
				}),
				idProperty: 'BoeingBemsId',
				root: 'data',
				fields: ['BoeingBemsId', 'BoeingDisplayName', 'GivenName', 'Initials', 'SN', 'DepartmentNumber', 'TelephoneNumber', 'BoeingInternetEmail', 'City', 'State', 'UsPerson', 'BoeingEmployee', {
					name: 'Source',
					defaultValue: me.source || 'EDS'
				}, {
						name: 'UsPersonText',
						convert: function (v, record) {
							return record.UsPerson === '1' ? 'Yes' : 'No';
						}
					}, {
						name: 'UniqueDisplayName',
						convert: function (v, record) {
							return String.format('{0} ({1})', record.BoeingDisplayName, record.BoeingBemsId);
						}
					}]
			})
		});
		me.constructor.superclass.initComponent.call(me);
	}
});
Ext.reg('EdsSearchField', PgmD.eds.SearchField);
/**
 * @namespace PgmD.eds
 * @class SearchPanel
 * @extends Ext.Panel
 */
PgmD.eds.SearchPanel = Ext.extend(Ext.Panel, {
	autoScroll: true,
	containerScroll: true,
	singleSelect: true,
	multiSelect: true,
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		var tipFormat = '<p><b>BEMS ID:</b>&nbsp;&nbsp;{BoeingBemsId}</p>';
		tipFormat += '<p><b>Display Name:</b>&nbsp;&nbsp;{BoeingDisplayName}</p>';
		tipFormat += '<p><b>Department:</b>&nbsp;&nbsp;{DepartmentNumber}</p>';
		tipFormat += '<p><b>Telephone:</b>&nbsp;&nbsp;{TelephoneNumber}</p>';
		tipFormat += '<p><b>E-Mail:</b>&nbsp;&nbsp;{BoeingInternetEmail}</p>';
		tipFormat += '<p><b>US Citizen:</b>&nbsp;&nbsp;{UsPersonText}</p>';
		tipFormat += '<p><b>Source:</b>&nbsp;&nbsp;{Source}</p>';
		Ext.apply(this, {
			layout: 'fit',
			items: [{
				emptyText: 'Type into the search box above then press "Enter" to add user',
				hideHeaders: true,
				iconCls: 'silk-group-key',
				multiSelect: me.multiSelect,
				ref: 'listview',
				singleSelect: !me.multiSelect,
				columns: [{
					tpl: '<div style="white-space: normal" ext:qwidth="250" ext:qtip="' + tipFormat + '">{BoeingDisplayName}</div>',
					dataIndex: 'BoeingDisplayName'
				}],
				store: new Ext.data.ArrayStore({
					fields: ['BoeingBemsId', 'BoeingDisplayName', 'GivenName', 'Initials', 'SN', 'DepartmentNumber', 'TelephoneNumber', 'BoeingInternetEmail', 'City', 'State', 'UsPerson', 'BoeingEmployee', {
						name: 'Source',
						defaultValue: me.source || 'EDS'
					}, {
						name: 'UsPersonText',
						convert: function (v, record) {
							return record.UsPerson === '1' ? 'Yes' : 'No';
						}
					}]
				}),
				listeners: {
					dblclick: function (listview, index, node, evt) {
						listview.getStore().removeAt(index);
					}
				},
				xtype: 'listview'
			}],
			tbar: {
				layout: 'hbox',
				items: [{
					allowBlank: me.allowBlank === undefined ? true : me.allowBlank,
					emptyText: me.srchEmptyText,
					filterSource: me.filterSource,
					flex: 1,
					ref: 'comboSearchName',
					listeners: {
						specialkey: {
							fn: function (field, evt) {
								switch (evt.getKey()) {
									case Ext.EventObject.ENTER:
										evt.preventDefault();
										me.onAddClick();
										break;
									case Ext.EventObject.ESC:
										evt.preventDefault();
										if (field.getValue()) {
											field.reset();
											field.clearValue();
										}
										break;
									default:
								}
							},
							scope: this
						}
					},
					source: me.source,
					xtype: 'EdsSearchField'
				}, {
					flex: 0,
					iconCls: 'silk-accept',
					tooltip: 'Add user',
					handler: function (item, evt) {
						me.onAddClick(item, evt);
					}
				}, {
					flex: 0,
					iconCls: 'silk-delete',
					tooltip: 'Delete selected user',
					handler: function (item, evt) {
						me.onDeleteClick(item, evt);
					}
				}]
			}
		});
		me.constructor.superclass.initComponent.call(me);
	},
	/**
	 * Check if form is valid
	 * @return {boolean} true/false
	 */
	isValid: function () {
		var me = this;
		return me.listview.getStore().data.length > 0 ? true : false;
	},
	/**
	 *
	 * @param {Button} item button
	 * @param {EventObject} evt event
	 */
	onAddClick: function (item, evt) {
		var me = this;
		var combo = me.getTopToolbar().comboSearchName;
		if (combo.getValue() !== null && combo.getValue() !== '') {
			me.listview.getStore().insert(0, combo.getStore().getById(combo.getValue()));
			if (me.allowBlank !== undefined && !me.allowBlank) {
				Ext.apply(combo, {
					allowBlank: true,
					emptyText: ''
				});
			}
		}
		combo.reset();
		combo.clearValue();
	},
	/**
	 *
	 * @param {Button} item button 
	 * @param {EventObject} evt event
	 */
	onDeleteClick: function (item, evt) {
		var me = this;
		var combo = me.getTopToolbar().comboSearchName;
		var records = me.listview.getSelectedRecords();
		if (records.length > 0) {
			for (var i = 0; i < records.length; i++) {
				me.listview.getStore().remove(records[i]);
			}
		}
		if (me.allowBlank !== undefined && !me.allowBlank && me.listview.getStore().data.length === 0) {
			Ext.apply(combo, {
				allowBlank: me.allowBlank === undefined ? true : me.allowBlank,
				emptyText: me.srchEmptyText
			});
			combo.reset();
			combo.validate();
		}
	}
});
Ext.reg('EdsSearchPanel', PgmD.eds.SearchPanel);
