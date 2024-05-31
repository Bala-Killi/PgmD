// ReSharper disable UnusedParameter
// ReSharper disable UseOfImplicitGlobalInFunctionScope
Ext.ns('PgmD.access');
/**
 * @namespace PgmD.access
 * @class AcFormPanel
 * @extends Ext.form.FormPanel
 */
PgmD.access.AcFormPanel = Ext.extend(Ext.form.FormPanel, {
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		var now = new Date();
		var newDate = me.record.get('expiredDate');
		newDate = newDate > now.getToDateOnly() && now.add(Date.DAY, PgmD.acWarningPeriod) > newDate ? newDate.add(Date.MONTH, Number(me.record.get('extendMonths'))) : now.getToDateOnly().add(Date.MONTH, Number(me.record.get('extendMonths')));
		Ext.apply(me, {
			bodyStyle: 'padding: 10px',
			labelAlign: 'right',
			labelSeparator: '',
			labelWidth: 130,
			items: [{
				anchor: '100%',
				fieldLabel: 'Entitie Name <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qwidth=\'360\' ext:qtip=\'Abbreviated organization name\' />',
				name: 'shortName',
				style: 'padding-top: 3px',
				value: Ext.util.Format.htmlEncode(me.record.get('shortName')),
				xtype: 'displayfield'
			}, {
				allowBlank: false,
				anchor: '100%',
				displayField: 'DisplayAppRole',
				emptyText: 'Required',
				fieldLabel: 'Application and Role <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Application role privileges to be granted\' />',
				forceSelection: true,
				listeners: {
					select: function (combo, record, index) {
						var expiredDate = me.getForm().findField('expiredDate');
						combo.currentRecord = record;
						expiredDate.maxValue = new Date().add(Date.MONTH, Number(me.stores.App.getById(record.get('AppID')).get('MaxDuration')));
						expiredDate.setValue(expiredDate.getValue() ? expiredDate.getValue() : expiredDate.maxValue);
					}
				},
				mode: 'local',
				name: 'AppRole',
				readOnly: me.viewType !== 'add',
				selectOnFocus: true,
				store: me.stores.AppRoleSave,
				style: me.viewType === 'add' ? undefined : 'padding-top: 3px',
				triggerAction: 'all',
				value: me.viewType === 'add' ? undefined : me.record.get('appDisplayName') + ': ' + me.record.get('roleName'),
				valueField: 'AppRole',
				xtype: me.viewType === 'add' ? 'combo' : 'displayfield'
			}, {
				allowBlank: false,
				anchor: '100%',
				bemsId: new Ext.form.Hidden({
					name: 'ACGrantees'
				}),
				fieldLabel: 'Granted Users <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Users to be granted privileges\' />',
				height: me.viewType === 'add' ? 135 : undefined,
				multiSelect: false,
				ref: 'srchAcGrantees',
				source: 'EDS',
				srchEmptyText: 'Required',
				style: me.viewType === 'add' ? undefined : 'padding-top: 3px',
				value: me.viewType === 'add' ? undefined : String.format('{0} ({1})', me.record.get('userName'), me.record.get('userId')),
				xtype: me.viewType === 'add' ? 'EdsSearchPanel' : 'displayfield'
			}, {
				allowBlank: false,
				emptyText: 'Required',
				fieldLabel: 'Expiration Date <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Privilege expiration date\' />',
				name: 'expiredDate',
				maxValue: me.viewType === 'add' ? undefined : newDate,
				value: me.viewType === 'add' ? undefined : me.record.get('expiredDate'),
				xtype: 'datefield'
			}, {
				allowBlank: false,
				anchor: '100%',
				autoscroll: true,
				emptyText: 'Required',
				enableKeyEvents: true,
				fieldLabel: 'Reason <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Reason for granting privilege\' />',
				height: 35,
				listeners: {
					keypress: function (form, e) {
						if (e.keyCode === e.ENTER) {
							e.stopPropagation();
							e.stopEvent();
						}
					}
				},
				maxLength: 255,
				name: 'Reason',
				readOnly: me.editType === 'view' ? true : false,
				value: me.viewType === 'add' ? undefined : me.record.get('reason'),
				xtype: 'textarea'
			}],
			buttons: [{
				handler: function (item, evt) {
					me.onApplyClick(item, evt);
				},
				iconCls: 'silk-disk',
				id: String.format('{0}-{1}', me.id || me.xtype, 'btnApply'),
				text: 'Apply'
			}, {
				handler: function (item, evt) {
					me.onCloseClick(item, evt);
				},
				iconCls: 'silk-cancel',
				id: String.format('{0}-{1}', me.id || me.xtype, 'btnCancel'),
				text: 'Cancel'
			}]
		});
		me.constructor.superclass.initComponent.call(me);
	},
	/**
	 *
	 * @param {Button} item Button
	 * @param {EventObject} evt Event
	 */
	onApplyClick: function (item, evt) {
		var me = this;
		var form = me.getForm();
		if (me.viewType === 'add') {
			me.srchAcGrantees.onAddClick(item, evt);
			me.srchAcGrantees.getTopToolbar().comboSearchName.validate();
		}
		if (form.isValid() && form.isDirty() && (me.viewType === 'edit' || (me.viewType === 'add' && me.srchAcGrantees.isValid()))) {
			// Process all of the personnel elements. Database records need to be created if the user doesn't already exist.
			var bemsId = [];
			var displayName = [];
			var email = [];
			var boeingEmp = [];
			var dept = [];
			var firstName = [];
			var middle = [];
			var lastName = [];
			var source = [];
			var phone = [];
			var usPerson = [];
			var appId, roleId;
			if (me.viewType === 'add') {
				me.srchAcGrantees.listview.getStore().each(function (rec) {
					bemsId.push(rec.get('BoeingBemsId'));
					displayName.push(rec.get('BoeingDisplayName'));
					email.push(rec.get('BoeingInternetEmail'));
					boeingEmp.push(rec.get('BoeingEmployee'));
					dept.push(rec.get('DepartmentNumber'));
					firstName.push(rec.get('GivenName'));
					middle.push(rec.get('Initials'));
					lastName.push(rec.get('SN'));
					source.push(rec.get('Source'));
					phone.push(rec.get('TelephoneNumber'));
					usPerson.push(rec.get('UsPerson'));
				});
				appId = form.findField('AppRole').currentRecord.get('AppID');
				roleId = form.findField('AppRole').currentRecord.get('RoleTypeID');
			} else {
				bemsId.push(me.record.get('userId'));
				source.push(me.record.get('userSource'));
				appId = me.record.get('appId');
				roleId = me.record.get('roleId');
			}

			var fieldValues = form.getFieldValues();
			me.getEl().mask('Loading...', 'x-mask-loading');
			Ext.Ajax.request({
				params: Ext.apply({
					context: me.context,
					root: me.record.get('root'),
					oeId: me.record.get('oeId'),
					appId: appId,
					roleId: roleId,
					expiredDate: fieldValues.expiredDate,
					reason: fieldValues.Reason.replace(/\r/g, '').replace(/[\f\t\v\u00A0\u2028\u2029]/g, ' '),
					bemsId: bemsId.join(';'),
					source: source.join(';')
				}, me.viewType === 'add' ? {
					// remaining personnel info for all users entered
					displayName: displayName.join(';'),
					email: email.join(';'),
					boeingEmp: boeingEmp.join(';'),
					dept: dept.join(';'),
					firstName: firstName.join(';'),
					middle: middle.join(';'),
					lastName: lastName.join(';'),
					phone: phone.join(';'),
					usPerson: usPerson.join(';'),
					action: 'createac'
				} : {
					action: 'updateac'
				}),
				method: 'GET',
				success: function (response, options) {
					if (response.status === 200) {
						var json = Ext.util.JSON.decode(response.responseText);
						if (json.success) {
							fieldValues = form.getFieldValues();
							var store = me.grid.getStore();
							if (me.viewType === 'add') {
								me.srchAcGrantees.listview.getStore().each(function (rec) {
									// ReSharper disable once InconsistentNaming
									store.addSorted(new store.recordType({
										root: me.record.get('root'),
										oeId: me.record.get('oeId'),
										sortBC: me.record.get('sortBC'),
										generation: me.record.get('generation'),
										appPrivileges: me.record.get('appPrivileges'),
										longName: me.record.get('longName'),
										shortName: me.record.get('shortName'),
										hideGroupAdd: 0,
										hideRowDelete: 0,
										extendMonths: me.stores.App.getById(form.findField('AppRole').currentRecord.get('AppID')).get('MaxDuration'),
										appId: form.findField('AppRole').currentRecord.get('AppID'),
										appName: form.findField('AppRole').currentRecord.get('AppName'),
										appDisplayName: form.findField('AppRole').currentRecord.get('DisplayApp'),
										roleId: form.findField('AppRole').currentRecord.get('RoleTypeID'),
										roleName: form.findField('AppRole').currentRecord.get('DisplayRole'),
										userId: rec.get('BoeingBemsId'),
										userSource: rec.get('Source'),
										userName: rec.get('BoeingDisplayName'),
										user: rec.get('BoeingDisplayName') + ' (' + rec.get('BoeingBemsId') + ')',
										modID: json.data.modID,
										modName: json.data.modName,
										modUser: String.format('{0} ({1})', json.data.modName, json.data.modID),
										expiredDate: fieldValues.expiredDate,
										reason: fieldValues.Reason,
										rowactions: []
									}));
								}, this);
							} else {
								Ext.apply(me.record.data, {
									expiredDate: fieldValues.expiredDate,
									reason: fieldValues.Reason,
									modID: json.data.modID,
									modName: json.data.modName,
									modUser: json.data.modName + ' (' + json.data.modID + ')'
								});
								me.grid.getView().refresh();
							}
							Ext.Msg.show({
								buttons: Ext.MessageBox.OK,
								icon: Ext.MessageBox.INFO,
								msg: 'Saved',
								title: 'Success'
							});
							me.getEl().unmask();
						} else {
							Ext.Msg.show({
								buttons: Ext.MessageBox.OK,
								icon: Ext.MessageBox.ERROR,
								msg: 'Error occurred. ' + json.msg,
								title: 'Error'
							});
						}
					}
					me.ownerCt.close();
				},
				failure: function (response, options) {
					Ext.Msg.show({
						title: 'Error',
						msg: 'Error occurred during save',
						buttons: Ext.MessageBox.OK,
						icon: Ext.MessageBox.ERROR
					});
				},
				url: 'view/GetContent.aspx'
			});
		}
	},
	/**
	 *
	 * @param {Button} item Button
	 * @param {EventObject} evt Event
	 */
	onCloseClick: function (item, evt) {
		var me = this;
		me.ownerCt.close();
	}
});
Ext.reg('AcFormPanel', PgmD.access.AcFormPanel);