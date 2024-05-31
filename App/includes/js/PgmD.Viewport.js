/**
 * @namespace PgmD
 * @class Viewport
 */
PgmD.Viewport = Ext.extend(Ext.Viewport, {
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		Ext.apply(me, {
			layout: 'border',
			items: [{
				autoShow: true,
				border: false,
				contentEl: 'header',
				height: 60,
				id: String.format('{0}-{1}', me.id || me.xtype, 'north'),
				region: 'north',
				xtype: 'box'
			}, {
				activeTab: 0,
				border: true,
				id: String.format('{0}-{1}', me.id || me.xtype, 'center'),
				ref: 'center',
				region: 'center',
				items: [{
					iconCls: 'silk-house',
					id: 'tbHome',
					layout: 'border',
					title: 'Home',
					items: [{
						border: false,
						context: 'Boeing Program Hierarchy',
						name: 'General',
						id: String.format('{0}-{1}', me.id || me.xtype, 'HierTreePanel'),
						ref: 'HierTreePanel',
						region: 'west',
						style: {
							borderRight: '1px solid #99bbe8'
						},
						title: 'Organization',
						width: 255,
						footerCfg: {
							cls: 'x-panel-footer',
							html: [
								''
							].join('')
						},
						footerStyle: {
							borderTop: '1px solid #99bbe8',
							color: '#0038A9',
							font: '11px arial,tahoma,helvetica,sans-serif',
							height: '155px',
							padding: '5px'
						},
						xtype: 'HierTreePanel'
					}, {
						autoScroll: true,
						contentEl: 'contentHome',
						id: String.format('{0}-{1}', me.id || me.xtype, 'ContentHome'),
						region: 'center',
						style: 'background-color: #ffffff',
						xtype: 'box'
					}],
					xtype: 'panel'
				}, {
					iconCls: 'silk-user',
					id: 'tbAccessCntlPanel',
					layout: 'border',
					ref: 'AccessPanel',
					title: 'Access Manager',
					defaults: {
						border: false,
						context: 'Boeing Program Hierarchy',
						name: 'General'
					},
					items: [{
						activeOnly: true,
						border: false,
						checked: false,
						collapsible: true,
						iconCls: 'silk-chart-organization',
						id: String.format('{0}-{1}', me.id || me.xtype, 'tbAccessCntlPanel-HierTreePanel'),
						layoutConfig: {
							fill: true,
							hideCollapseTool: true,
							titleCollapse: true
						},
						maxWidth: 400,
						minWidth: 220,
						qtiphelp: 'Select the entities for which you wish to see access.<br>Access is displayed for that organization and for entities above.<br>If no organization is selected, only those entities with access matching the other Selection Filters and entities above them are displayed.',
						ref: 'HierTreePanel',
						region: 'west',
						split: true,
						title: 'Organization',
						useSplitTips: true,
						width: 220,
						xtype: 'HierTreePanel'
					}, {
						border: false,
						columnLines: true,
						id: String.format('{0}-{1}', me.id || me.xtype, 'tbAccessCntlPanel-AccessGrid'),
						loadMask: true,
						ref: 'AccessGrid',
						region: 'center',
						stripeRows: true,
						title: 'Selection Filters',
						listeners: {
							afterrender: function (panel) {
								var comboApp = panel.getTopToolbar().ButtonGroupFilters1.comboApp;
								var record = comboApp.findRecord('AppName', PgmD.initApp === '' ? 'All Apps' : PgmD.initApp);
								comboApp.setValue(record.id);
								comboApp.fireEvent('select', comboApp, record, comboApp.getStore().indexOfId(record.id));
								if (PgmD.initFunction.toLowerCase() === 'getprivs') {
									panel.onGetPrivsClick();
								}
							}
						},
						xtype: 'AccessGrid'
					}]
				}],
				xtype: 'tabpanel'
			}, {
				autoShow: true,
				border: false,
				collapseMode: 'mini',
				collapsible: true,
				contentEl: 'footer',
				header: false,
				height: 80,
				id: String.format('{0}-{1}', me.id || me.xtype, 'south'),
				maxHeight: 80,
				minHeight: 80,
				region: 'south',
				split: true,
				stateEvents: ['collapse', 'expand'],
				stateful: true,
				stateId: 'pgmd-south',
				style: 'background-color:white',
				xtype: 'panel'
			}]
		});
		me.constructor.superclass.initComponent.call(me);
	},
	postToUrl: function (path, params, method) {
		var form = document.createElement('form');
		form.setAttribute('method', method || 'post');
		form.setAttribute('action', path);
		for (var key in params) {
			if (params.hasOwnProperty(key)) {
				var hiddenField = document.createElement('input');
				hiddenField.setAttribute('type', 'hidden');
				hiddenField.setAttribute('name', key);
				hiddenField.setAttribute('value', params[key]);
				form.appendChild(hiddenField);
			}
		}
		document.body.appendChild(form);
		form.submit();
		document.body.removeChild(form);
	}
});