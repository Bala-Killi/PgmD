Ext.ns('PgmD.access');
/**
 * @namespace PgmD.access
 * @class AccessGrid
 * @extends Ext.grid.EditorGridPanel
 */
PgmD.access.AccessGrid = Ext.extend(Ext.grid.EditorGridPanel, {
	context: 'Boeing Program Hierarchy',
	name: 'General',
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		me.stores = {
			App: new Ext.data.JsonStore({
				data: [{
					AppID: 0,
					AppName: 'All Apps',
					DisplayApp: 'All Apps',
					MaxDuration: null,
					GrantMask: 0
				}].concat(PgmD.data.App),
				fields: ['AppID', 'AppName', 'DisplayApp', 'MaxDuration', 'GrantMask'],
				idProperty: 'AppID'
			}),
			AppRole: new Ext.data.JsonStore({
				data: [{
					AppID: 'null',
					AppName: 'null',
					DisplayApp: 'null',
					DisplayRole: 'All Roles',
					Privileges: 0,
					RoleName: 'All Roles',
					RoleTypeID: 'null'
				}].concat(PgmD.data.AppRoles),
				fields: ['AppID', 'AppName', 'DisplayApp', 'RoleTypeID', 'RoleName', 'DisplayRole', 'Privileges', {
					name: 'AppRole',
					convert: function (v, record) {
						return record.AppID + ';' + record.RoleTypeID;
					}
				}, {
					name: 'DisplayAppRole',
					convert: function (v, record) {
						return record.DisplayApp + ': ' + record.DisplayRole;
					}
				}],
				storeId: 'AppRoles'
			})
		};
		me.stores.AppRoleSave = new Ext.data.Store({
			recordType: me.stores.AppRole.recordType
		});
		me.rowActions = new Ext.ux.grid.RowActions({
			autoWidth: true,
			getEditor: function () {
				return;
			},
			keepSelection: true,
			widthIntercept: 5,
			actions: [{
				hideIndex: 'hideRowDelete',
				iconCls: 'silk-cross',
				tooltip: 'Delete user privilege',
				callback: function (grid, record, action, rowIndex, colIndex) {
					me.onDeleteUserPrivilegeClick(grid, record, action, rowIndex, colIndex);
				}
			}, {
				hideIndex: 'hideRowDelete',
				iconCls: 'silk-page-white-edit',
				style: 'margin:0 0 0 3px',
				tooltip: 'Edit user privilege',
				callback: function (grid, record, action, rowIndex, colIndex) {
					me.onEditUserPrivilegeClick(grid, record, 'edit', rowIndex, colIndex);
				}
			}, {
				hideIndex: 'hideRowDelete',
				iconCls: 'silk-date-next',
				style: 'margin:0 0 0 3px',
				tooltip: 'Extend expiration date',
				callback: function (grid, record, action, rowIndex, colIndex) {
					me.onExtendExpirationDateClick(grid, record, action, rowIndex, colIndex);
				}
			}],
			groupActions: [{
				hideIndex: 'hideGroupAdd',
				iconCls: 'pgmd-add-icon',
				tooltip: 'Add user privilege for this organization',
				callback: function (grid, records, action, groupId) {
					me.onEditUserPrivilegeClick(grid, records[0], 'add', null, null);
				}
			}]
		});
		Ext.apply(me, {
			plugins: [me.rowActions],
			colModel: new Ext.grid.ColumnModel({
				defaults: {
					editable: false,
					hideable: false,
					menuDisabled: true,
					sortable: false
				},
				columns: [{
					dataIndex: 'sortBC'
				}, {
					dataIndex: 'appDisplayName',
					header: 'APPLICATION',
					sortable: true,
					width: 100
				}, {
					dataIndex: 'roleName',
					header: 'ROLE',
					sortable: true,
					width: 160
				}, {
					dataIndex: 'userId',
					header: 'USER',
					renderer: function (value, metaData, record, rowIndex, colIndex, store) {
						return Ext.isEmpty(value) ? '' : String.format('{0} ({1})', record.get('userName'), value);
					},
					sortable: true,
					width: 160
				}, {
					dataIndex: 'expiredDate',
					header: 'EXPIRATION',
					renderer: function (value, metadata, record, rowIndex, colIndex, store) {
						if (value) {
							var today = new Date();
							if (value <= today) {
								metadata.css = 'x-grid3-cell-red';
							}
							return value.format('m/d/Y');
						} else {
							return value;
						}
					},
					sortable: true,
					width: 65
				}, {
					dataIndex: 'reason',
					header: 'REASON',
					renderer: function (value, metadata, record, rowIndex, colIndex, store) {
						metadata.attr = 'ext:qtip=\'' + Ext.util.Format.htmlEncode(value) + '\'';
						return value;
					},
					width: 280
				}, {
					dataIndex: 'modID',
					header: 'LAST MODIFIED',
					renderer: function (value, metadata, record, rowIndex, colIndex, store) {
						metadata.attr = 'ext:qtip=\'' + record.get('modName') + '\'';
						return value;
					},
					width: 90
				}, me.rowActions]
			}),
			sm: new Ext.grid.RowSelectionModel({
				singleSelect: true
			}),
			store: new Ext.data.GroupingStore({
				reader: new Ext.data.JsonReader({
					root: 'data',
					fields: ['appDisplayName', {
						name: 'appId',
						type: 'int'
					}, 'appName', {
						name: 'appPrivileges'
					}, {
						dateFormat: 'c',
						name: 'expiredDate',
						type: 'date'
					}, {
						name: 'generation',
						type: 'int'
					}, {
						name: 'hideGroupAdd',
						type: 'int'
					}, {
						name: 'hideRowDelete',
						type: 'int'
					}, 'longName', 'modID', 'modName', {
						name: 'oeId',
						type: 'int'
					}, 'reason', {
						name: 'root',
						type: 'int'
					}, {
						name: 'roleId',
						type: 'int'
					}, 'roleName', 'shortName', 'sortBC', 'userId', 'userName', 'userSource', {
						name: 'extendMonths',
						convert: function (v, record) {
							return Ext.isEmpty(record.appId) ? 0 : me.stores.App.getById(record.appId).get('MaxDuration');
						},
						type: 'int'
					}, {
						name: 'rowactions',
						mapping: 23
					}]
				}),
				baseParams: {
					action: 'getac',
					context: me.context,
					hierarchy: me.name,
					hierClass: 'Production'
				},
				proxy: new Ext.data.HttpProxy({
					method: 'POST',
					url: 'view/GetContent.aspx',
					failure: function (response, opts) {
						if (response.status === 0) {
							Ext.Msg.alert(response.statusText.toUpperCase(), 'WSSO Session Expired', function (btn) {
								top.location = PgmD.basePath;
							});
						}
					}
				}),
				groupField: 'sortBC'
			}),
			view: new Ext.grid.GroupingView({
				enableGroupingMenu: false,
				enableNoGroups: false,
				forceFit: true,
				groupTextTpl: '{[Array(values.rs[0].data[\'generation\']*6+1).join(\'&nbsp;\') + values.rs[0].data[\'shortName\']]}',
				hideGroupedColumn: true,
				scrollOffset: 15,
				showGroupName: false
			}),
			tbar: new Ext.Toolbar({
				enableOverflow: true,
				id: String.format('{0}-{1}', me.id || me.xtype, 'tbar'),
				defaults: {
					labelAlign: 'right',
					labelSeparator: ''
				},
				items: [{
					frame: false,
					id: String.format('{0}-{1}', me.id || me.xtype, 'ButtonGroupFilters1'),
					labelWidth: 75,
					layout: 'form',
					ref: 'ButtonGroupFilters1',
					items: [{
						allowBlank: false,
						displayField: 'DisplayApp',
						editable: false,
						fieldLabel: 'Application <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Choose which application(s) to view or edit access privileges\' />',
						hideLabels: false,
						id: String.format('{0}-{1}', me.id || me.xtype, 'comboApp'),
						listWidth: 120,
						maxHeight: 200,
						mode: 'local',
						ref: 'comboApp',
						store: me.stores.App,
						triggerAction: 'all',
						valueField: 'AppID',
						//value: PgmD.initApp || undefined,
						width: 85,
						listeners: {
							blur: function (combo) {
								if (combo.getCheckedValue() === 0 || combo.getCheckedValue() === combo.getAllValue().replace(/0,/g, '')) {
									combo.selectAll();
								}
								var comboRole = me.getTopToolbar().ButtonGroupFilters2.comboRole;
								comboRole.store.filterBy(function (record, id) {
									return ((',' + combo.getCheckedValue().replace(/0,/g, '') + ',').search(',' + record.get('AppID') + ',') !== -1) || (record.get('AppID') === '0');
								});
								if (comboRole.getCheckedValue() === '' || comboRole.getCheckedValue().replace(/null;null,/g, '') === comboRole.getAllValue().replace(/null;null,/g, '')) {
									comboRole.selectAll();
								} else {
									comboRole.setValue(comboRole.getCheckedValue().replace(/null;null,/g, ''));
								}
							},
							select: function (combo, record, index) {
								if (record.get('AppID') === 0 && record.get('checked')) {
									combo.selectAll();
								} else if (record.get('AppID') === 0 && !record.get('checked')) {
									combo.deselectAll();
								} else if (record.get('AppID') !== 0 && !record.get('checked')) {
									combo.setValue(combo.getCheckedValue().split(',').remove('0').join(','));
								}
							}
						},
						xtype: 'lovcombo'
					}, {
						allowBlank: false,
						displayField: 'StatusType',
						editable: false,
							fieldLabel: 'Org Status <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Active only – current existing entities<br>All – entities with status of active or inactive. Inactive entities are completed, cancelled or previous entities.\' />',
						forceSelection: true,
						id: String.format('{0}-{1}', me.id || me.xtype, 'comboStatus'),
						mode: 'local',
						ref: 'comboStatus',
						store: new Ext.data.ArrayStore({
							id: 0,
							fields: ['StatusType'],
							data: [['All'], ['Active Only']]
						}),
						triggerAction: 'all',
						value: 'Active Only',
						valueField: 'StatusType',
						width: 85,
						xtype: 'combo'
					}],
					xtype: 'buttongroup'
				}, {
					frame: false,
					id: String.format('{0}-{1}', me.id || me.xtype, 'ButtonGroupFilters2'),
					labelWidth: 50,
					layout: 'form',
					ref: 'ButtonGroupFilters2',
					items: [{
						allowBlank: false,
						displayField: 'DisplayRole',
						editable: false,
						fieldLabel: 'Role <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Choose which role(s) to view or edit access privileges\' />',
						id: String.format('{0}-{1}', me.id || me.xtype, 'comboRole'),
						lastQuery: '',
						listWidth: 200,
						maxHeight: 200,
						mode: 'local',
						ref: 'comboRole',
						store: me.stores.AppRole,
						triggerAction: 'all',
						valueField: 'AppRole',
						width: 150,
						listeners: {
							select: function (combo, record, index) {
								if (record.get('AppRole') === 'null;null' && record.get('checked')) {
									combo.selectAll();
								} else if (record.get('AppRole') === 'null;null' && !record.get('checked')) {
									combo.deselectAll();
								} else if (record.get('AppRole') !== 'null;null' && !record.get('checked')) {
									combo.setValue(combo.getCheckedValue().replace('null;null,', '').replace('null;null', ''));
								}
							}
						},
						xtype: 'lovcombo'
					}, {
						allowBlank: false,
						displayField: 'ExpirationStatus',
						editable: false,
						fieldLabel: 'Validity <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Select access validity (Expired, Active, All) to view or edit access privileges. A validity of \'All\' will retrieve all applicable access privileges irrespective of expiration date\' /> ',
						forceSelection: true,
						id: String.format('{0}-{1}', me.id || me.xtype, 'comboExpStatus'),
						mode: 'local',
						ref: 'comboExpStatus',
						store: new Ext.data.ArrayStore({
							id: 0,
							fields: ['ExpirationStatus'],
							data: [['All'], ['Valid'], ['Expired']]
						}),
						triggerAction: 'all',
						value: 'All',
						valueField: 'ExpirationStatus',
						width: 75,
						xtype: 'combo'
					}],
					xtype: 'buttongroup'
				}, {
					frame: false,
					id: String.format('{0}-{1}', me.id || me.xtype, 'ButtonGroupFilters3'),
					labelWidth: 75,
					layout: 'form',
					ref: 'ButtonGroupFilters3',
					items: [{
						bemsId: new Ext.form.Hidden({
							name: 'ACGrantees'
						}),
						fieldLabel: 'User <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Enter BEMS ID or last name of individual user(s) to view or edit access privileges\' />',
						id: String.format('{0}-{1}', me.id || me.xtype, 'srchUsers'),
						multiSelect: false,
						ref: 'srchUsers',
						source: 'DB',
						width: 150,
						xtype: 'EdsNameField'
					}, {
						fieldLabel: 'As of Date <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Specifies the date as of which the accesses are valid or expired. A validity of \'All\' will retrieve all applicable access privileges irrespective of expiration date\' /> ',
						id: String.format('{0}-{1}', me.id || me.xtype, 'dfExpDate'),
						ref: 'dfExpDate',
						value: new Date(),
						width: 85,
						xtype: 'datefield'
					}],
					xtype: 'buttongroup'
				}, {
					handler: function (item, evt) {
						me.onGetPrivsClick(item, evt);
					},
					iconAlign: 'top',
					iconCls: 'silk-group-key',
					id: String.format('{0}-{1}', me.id || me.xtype, 'btnGetPrivs'),
					tooltip: 'Get Privileges',
					text: 'Get Privs'
				}, {
					handler: function (item, evt) {
						me.onMyAccessClick(item, evt);
					},
					iconAlign: 'top',
					iconCls: 'silk-user-key',
					id: String.format('{0}-{1}', me.id || me.xtype, 'btnMyAccess'),
					tooltip: 'Get My Access',
					text: 'My Access'
				}, {
					handler: function (item, evt) {
						me.onResetFiltersClick(item, evt);
					},
					iconAlign: 'top',
					iconCls: 'pgmd-filter-delete-icon',
					id: String.format('{0}-{1}', me.id || me.xtype, 'btnClear'),
					tooltip: 'Reset Filters',
					text: 'Reset'
				}, '-', {
					handler: function (item, evt) {
						me.view.toggleAllGroups(true);
					},
					iconAlign: 'top',
					iconCls: 'icon-expandAll',
					id: String.format('{0}-{1}', me.id || me.xtype, 'btnExpandAll'),
					tooltip: 'Expand All',
					text: 'Expand All'
				}, {
					handler: function (item, evt) {
						me.view.toggleAllGroups(false);
					},
					iconAlign: 'top',
					iconCls: 'icon-collapseAll',
					id: String.format('{0}-{1}', me.id || me.xtype, 'btnCollapseAll'),
					tooltip: 'Collapse All',
					text: 'Collapse All'
				}, '-', '->', {
					handler: function (item, evt) {
						me.onExportClick(item, evt);
					},
					iconAlign: 'top',
					iconCls: 'silk-page-excel',
					id: String.format('{0}-{1}', me.id || me.xtype, 'btnExport'),
					tooltip: 'Excel Export',
					text: 'Export'
				}]
			}),
			tools: [{
				handler: function (evt, tool, panel) {
					me.view.toggleAllGroups(true);
				},
				id: 'plus',
				qtip: 'Expand All'
			}, {
				handler: function (evt, tool, panel) {
					me.view.toggleAllGroups(false);
				},
				id: 'minus',
				qtip: 'Collapse All'
			}]
		});
		me.constructor.superclass.initComponent.call(me);
		me.on({
			render: function (panel) {
				var tbar = panel.getTopToolbar();
				tbar.ButtonGroupFilters1.comboApp.selectAll();
				tbar.ButtonGroupFilters2.comboRole.selectAll();
			}
		});
	},
	/**
	 *
	 * @param {Ext.grid.EditorGridPanel} grid Grid panel
	 * @param {Ext.data.Record} record current record
	 * @param {String} action current action
	 * @param {Number} rowIndex row index
	 * @param {Number} colIndex column index
	 */
	onDeleteUserPrivilegeClick: function (grid, record, action, rowIndex, colIndex) {
		var me = this;
		Ext.Msg.confirm('Confirmation', 'Are you sure you want to delete this privilege?', function (btn) {
			if (btn === 'yes') {
				Ext.Ajax.request({
					method: 'GET',
					params: {
						action: 'deleteAC',
						appId: record.get('appId'),
						bemsId: record.get('userId'),
						context: me.context,
						oeId: record.get('oeId'),
						roleId: record.get('roleId'),
						root: record.get('root'),
						source: record.get('userSource')
					},
					url: 'view/GetContent.aspx',
					success: function (response, options) {
						if (response.status === 200) {
							var json = Ext.util.JSON.decode(response.responseText);
							if (json.success) {
								me.getStore().remove(record);
								Ext.Msg.setIcon(Ext.MessageBox.INFO);
								Ext.Msg.alert('Success', json.msg);
							} else {
								Ext.Msg.setIcon(Ext.MessageBox.ERROR);
								Ext.Msg.alert('Error', json.msg);
							}
						}
					},
					failure: function (response, options) {
						Ext.Msg.alert('AJAX Deletion Failure', response.responseText);
					}
				});
			}
		});
	},
	/**
	 * Edit user previlege Click event
	 * @param {Ext.grid.EditorGridPanel} grid Grid Panel
	 * @param {Ext.data.Record} record Current Record
	 * @param {String} action Action
	 * @param {Number} rowIndex Row Index
	 * @param {Number} colIndex Column Index
	 */
	onEditUserPrivilegeClick: function (grid, record, action, rowIndex, colIndex) {
		var me = this;
		// copy the filtered records into the combo boxes to limit the selections
		new Ext.Window({
			border: false,
			closable: true,
			constrainHeader: true,
			iconCls: action === 'add' ? 'silk-page-white-add' : 'silk-page-white-edit',
			id: String.format('{0}-{1}', me.id || me.xtype, 'window'),
			minWidth: 480,
			modal: true,
			resizable: true,
			stateful: false,
			title: action === 'add' ? 'Add Privileges...' : 'Edit Privileges...',
			items: [{
				context: me.context,
				height: action === 'add' ? 305 : 200,
				grid: me,
				id: String.format('{0}-{1}', me.id || me.xtype, 'AcFormPanel'),
				record: record,
				stores: me.stores,
				viewType: action,
				width: 670,
				xtype: 'AcFormPanel'
			}]
		}).show();
	},
	/**
	 * Extend Expiration Date validation 
	 * @param {Ext.grid.EditorGridPanel} grid Grid Panel
	 * @param {Ext.data.Record} record Current Record
	 * @param {String} action Action
	 * @param {Number} rowIndex Row Index
	 * @param {Number} colIndex Column Index
	 */
	onExtendExpirationDateClick: function (grid, record, action, rowIndex, colIndex) {
		var me = this;
		var now = new Date();
		var newDate = new Date(record.get('expiredDate'));
		newDate = newDate > now.getToDateOnly() && now.add(Date.DAY, PgmD.acWarningPeriod) > newDate ? newDate.add(Date.MONTH, Number(record.get('extendMonths'))) : now.getToDateOnly().add(Date.MONTH, Number(record.get('extendMonths')));
		Ext.Msg.confirm('Confirmation', String.format('Are you sure you want to extend the expiration date for {0} ({1}) to {2}?', record.get('userName'), record.get('roleName'), newDate.format('m/d/Y')), function (btn) {
			if (btn === 'yes') {
				Ext.Ajax.request({
					method: 'GET',
					params: {
						action: 'updateAC',
						appId: record.get('appId'),
						bemsId: record.get('userId'),
						context: me.context,
						expiredDate: newDate,
						oeId: record.get('oeId'),
						reason: record.get('reason'),
						roleId: record.get('roleId'),
						root: record.get('root'),
						source: record.get('userSource')
					},
					url: 'view/GetContent.aspx',
					success: function (response, options) {
						if (response.status === 200) {
							var json = Ext.util.JSON.decode(response.responseText);
							if (json.success) {
								record.set('expiredDate', newDate);
								me.getView().refresh();
								Ext.Msg.show({
									buttons: Ext.MessageBox.OK,
									icon: Ext.MessageBox.INFO,
									msg: 'Expiration Extended',
									title: 'Success'
								});
							} else {
								Ext.Msg.show({
									buttons: Ext.MessageBox.OK,
									icon: Ext.MessageBox.ERROR,
									msg: 'Error occurred during expiration extension',
									title: 'Error'
								});
							}
						}
					},
					failure: function (response, options) {
						Ext.Msg.show({
							buttons: Ext.MessageBox.OK,
							icon: Ext.MessageBox.ERROR,
							msg: 'Error occurred during expiration extension',
							title: 'Error'
						});
					}
				});
			}
		});
	},
	/**
	 *
	 * @param {Button} item Button
	 * @param {EventObject} evt Event
	 */
	onExportClick: function (item, evt) {
		var me = this;
		var store = me.getStore();
		if (store.lastOptions.params) {
			PgmD.ws.postToUrl('view/ExcelExporter.aspx', Ext.apply(store.lastOptions.params, {
				action: 'accesscontrol',
				fo: me.filterDisplays ? me.filterDisplays.oeList : '',
				fa: me.filterDisplays ? me.filterDisplays.applist : '',
				fr: me.filterDisplays ? me.filterDisplays.roleList : '',
				fu: me.filterDisplays ? me.filterDisplays.usernames : '',
				fs: me.filterDisplays ? me.filterDisplays.statustype : ''
			}), 'POST');
		}
	},
	/**
	 *
	 * @param {Button} item Button
	 * @param {EventObject} evt Event
	 */
	onGetPrivsClick: function (item, evt) {
		var me = this;
		var tbar = me.getTopToolbar();
		// preserve the list of applicable roles in the filter in order to control the selections in the ac add/edit popup
		var comboRole = tbar.ButtonGroupFilters2.comboRole;
		me.stores.AppRoleSave.removeAll();
		me.stores.AppRole.each(function (rec) {
			if (rec.get('AppID') !== null && rec.get(comboRole.checkField)) {
				me.stores.AppRoleSave.add([rec.copy()]);
			}
		});
		// set and preserve variables to be written to the header
		var statusType = tbar.ButtonGroupFilters1.comboStatus.getValue();
		var statusList = statusType === 'Active Only' ? 'Inactive' : '';
		var roleAppList = comboRole.getCheckedValue('AppID').replace(/null,/g, '');
		var roleList = comboRole.getCheckedValue('RoleTypeID').replace(/null,/g, '');
		var userList = tbar.ButtonGroupFilters3.srchUsers.bemsId.value ? tbar.ButtonGroupFilters3.srchUsers.bemsId.value.replace(/; /g, ',') : '';
		var userSourceList = '';
		var expStatus = tbar.ButtonGroupFilters2.comboExpStatus.getValue();
		var expiredDate = tbar.ButtonGroupFilters3.dfExpDate.value;

		var appList = tbar.ButtonGroupFilters1.comboApp.getRawValue();
		appList = appList.indexOf('All Apps') !== -1 || appList === '' ? '(All Applications)' : appList;
		var roleTextList = tbar.ButtonGroupFilters2.comboRole.getRawValue();
		roleTextList = roleTextList.indexOf('All Roles') !== -1 || roleTextList === '' ? '(All Roles)' : roleTextList;

		var hierTreePanel = me.previousSibling();
		var orgs = hierTreePanel.getChecked('id');
		var orgList = (orgs.length === hierTreePanel.nodesLength && orgs.length > 0) ? 'All' : (orgs.length === 0 ? '' : hierTreePanel.getChecked('id').join(','));
		var orgTextList = hierTreePanel.getChecked('text');
		var orgFilter = (orgTextList.length === hierTreePanel.nodesLength && orgTextList.length > 0) ? '(All Entities)' : (orgTextList.length === 0 ? '(Entities Matching Selection Filters)' : hierTreePanel.getChecked('text').join(',').replace(/,/g, ', '));
		orgFilter = me.getPrivileged || (me.filterDisplays && me.filterDisplays.oeList === '(Entities Where I Have Privileges)' && (me.lastOrgList === undefined || me.lastOrgList === orgList) && (me.lastAppList === undefined || me.lastAppList === appList)) ? me.filterDisplays.oeList : orgFilter;

		Ext.apply(me, {
			filterDisplays: {
				oeList: orgFilter,
				statustype: statusType,
				applist: appList,
				roleList: roleTextList,
				usernames: tbar.ButtonGroupFilters3.srchUsers.getValue() ? tbar.ButtonGroupFilters3.srchUsers.getValue() : '(All Users)',
				validity: expStatus,
				asofdate: expiredDate
			},
			lastAppList: appList,
			lastOrgList: orgList,
			lastExcStatusList: statusList,
			lastRoleAppList: roleAppList,
			lastRoleList: roleList,
			lastUserList: userList,
			lastUserSourceList: userSourceList,
			getPrivileged: false
		});
		me.view.toggleAllGroups(true);
		me.getStore().load({
			params: {
				context: me.context,
				hierarchy: me.name,
				oeList: orgList,
				excludeStatusList: statusList,
				roleAppList: roleAppList,
				roleList: roleList,
				userList: userList,
				userSourceList: userSourceList,
				expiredType: expStatus,
				expiredDate: expiredDate
			}
		});
	},
	/**
	 *
	 * @param {Button} item Button
	 * @param {EventObject} evt Event
	 */
	onMyAccessClick: function (item, evt) {
		var me = this;
		var tbar = me.getTopToolbar();
		var hierTreePanel = me.previousSibling();
		hierTreePanel.onAllCheckStateClick(false);
		hierTreePanel.getRootNode().cascade(function (n) {
			var priv = n.attributes.appPrivileges;
			for (var p in priv) {
				if (priv.hasOwnProperty(p)) {
					var rec = tbar.ButtonGroupFilters1.comboApp.findRecord('AppName', priv[p].appName);
					// don't count non-role based privileges. currently, this means don't count default user privs in pgmd.
					var defaultPriv = priv[p].appName === 'PgmD' ? PgmD.privMask.defaultUserPriv : 0;
					var hasPriv = (~defaultPriv & priv[p].privileges) !== 0;
					if (rec.get('AppID') !== 'null' && rec.get('checked') && hasPriv && n.attributes.loaded) {
						n.ui.toggleCheck(true);
					}
				}
			}
		});
		Ext.apply(me, {
			filterDisplays: {
				oeList: '(Orgs Where I Have Privileges)'
			},
			getPrivileged: true
		});
		me.onGetPrivsClick(item, evt);
	},
	/**
	 *
	 * @param {Button} item Button
	 * @param {EventObject} evt Event
	 */
	onResetFiltersClick: function (item, evt) {
		var me = this;
		var tbar = me.getTopToolbar();
		tbar.ButtonGroupFilters1.comboApp.reset();
		tbar.ButtonGroupFilters1.comboStatus.reset();
		tbar.ButtonGroupFilters2.comboRole.reset();
		tbar.ButtonGroupFilters2.comboExpStatus.reset();
		tbar.ButtonGroupFilters3.srchUsers.reset();
		tbar.ButtonGroupFilters3.srchUsers.bemsId.setValue('');
		tbar.ButtonGroupFilters3.dfExpDate.reset();
		me.previousSibling().onAllCheckStateClick(false);
	}
});
Ext.reg('AccessGrid', PgmD.access.AccessGrid);