/**
 * @namespace PgmD
 * @class HierTreePanel
 * @extends Ext.tree.TreePanel
 */
PgmD.HierTreePanel = Ext.extend(Ext.tree.TreePanel, {
	activeOnly: false,
	context: 'Boeing Program Hierarchy',
	name: 'General',
	hierClass: 'Production',
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		me.addEvents(
			/**
			 * Fires before a value is selected and set to this field
			 * @event treeloaded
			 * @param {Ext.tree.TreePanel} tree This tree panel
			 * @param {Ext.tree.TreeLoader} treeloader The selected record
			 */
			'treeloaded'
		);
		Ext.apply(me, {
			animate: true,
			autoScroll: true,
			containerScroll: true,
			rootVisible: false,
			root: {
				expanded: true,
				id: 'root',
				nodeType: 'async',
				text: 'Root'
			},
			loader: new Ext.tree.TreeLoader({
				baseAttrs: {
					checked: me.checked,
					listeners: {
						beforeexpand: function (node, deep, anim) {
							return node.getOwnerTree() !== null;
						},
						contextmenu: function (node, evt) {
							me.onContextMenuEvent(node, evt);
						}
					}
				},
				baseParams: {
					action: 'gethiertree',
					context: me.context,
					version: me.version,
					hierarchy: me.name,
					hierClass: me.hierClass,
					excludeStatusList: me.activeOnly ? 'Inactive' : ''
				},
				preloadChildren: true,
				requestMethod: 'GET',
				url: 'view/GetContent.aspx',
				listeners: {
					beforeload: function (loader, node, callback) {
						me.getEl().mask('Loading...', 'x-mask-loading');
					},
					load: function (loader, node, response) {
						if (response.status === 200) {
							var animate = me.animate;
							me.animate = false;
							me.expandAll();
							me.collapseAll();
							me.animate = animate;
							me.setNodesLength();
						}
						var el = me.getEl();
						if (el.isMasked) {
							el.unmask();
						}
						me.fireEvent('treeloaded', me, loader);
					},
					loadexception: function (loader, node, response) {
						var el = me.getEl();
						if (el.isMasked) {
							el.unmask();
						}
					}
				}
			}),
			nodesLength: 0,
			tbar: {
				defaultType: 'toolbar',
				//id: String.format('{0}-{1}', me.id || me.xtype, 'tbar'),
				items: [{
					hidden: me.activeOnly === undefined ? true : false,
					//id: String.format('{0}-{1}', me.id || me.xtype, 'tb1'),
					items: ['->', {
						checked: me.activeOnly === true ? true : false,
						boxLabel: 'Active Only <img src=\'/CDN/resources/images/famfamfam_silk_icons/help.gif\' align=\'top\' ext:qtip=\'Display only active entities.  An active organization is a current existing organization.\' />',
						handler: function (item, evt) {
							me.onCheckStatusClick(item.checked);
						},
						id: String.format('{0}-{1}', me.id || me.xtype, 'chkStatus'),
						ref: '../chkStatus',
						xtype: 'checkbox'
					}],
					ref: 'tb1'
				}, {
					//id: String.format('{0}-{1}', me.id || me.xtype, 'tb2'),
					layout: 'hbox',
					items: [{
						emptyText: 'Search',
						flex: 1,
						id: String.format('{0}-{1}', me.id || me.xtype, 'TreeSearchField'),
						ref: '../TreeSearchField',
						tree: me,
						xtype: 'TreeSearchField'
					}],
					ref: 'tb2'
				}],
				xtype: 'container'
			},
			tools: [{
				handler: function (evt, tool, panel) {
					me.onAllCheckStateClick(true);
				},
				hidden: me.checked === undefined,
				id: 'check',
				qtip: 'Check All'
			}, {
				handler: function (evt, tool, panel) {
					me.onAllCheckStateClick(false);
				},
				hidden: me.checked === undefined,
				id: 'uncheck',
				qtip: 'Uncheck All'
			}, {
				handler: function (evt, tool, panel) {
					me.onExpandAllClick(evt, tool, panel);
				},
				id: 'plus',
				qtip: 'Expand All'
			}, {
				handler: function (evt, tool, panel) {
					me.onCollapseAllClick(evt, tool, panel);
				},
				id: 'minus',
				qtip: 'Collapse All'
			}, {
				handler: function (evt, tool, panel) {
					me.onRefreshClick(evt, tool, panel);
				},
				id: 'refresh',
				qtip: 'Reload Hierarchy'
			}, {
				hidden: me.qtiphelp === undefined,
				id: 'qtiphelp',
				qtip: me.qtiphelp
			}]
		});
		me.constructor.superclass.initComponent.call(me);
		me.filter = new Ext.ux.tree.TreeFilterX(me, {
			autoClear: true
		});
	},
	/**
	 * toggle check status
	 * @param {Boolean} state node stage
	 */
	onAllCheckStateClick: function (state) {
		var me = this;
		me.getRootNode().cascade(function (node) {
			node.ui.toggleCheck(state);
		});
	},
	/**
	 *
	 * @param {Boolean} activeOnly node state
	 */
	onCheckStatusClick: function (activeOnly) {
		var me = this;
		me.getRootNode().firstChild.cascade(function () {
			if (this.attributes.status === 'Inactive' && activeOnly) {
				this.getUI().hide();
			} else {
				this.getUI().show();
			}
		});
	},
	/**
	 *
	 * @param {TreeNode} node tree node
	 * @param {EventObject} evt event
	 */
	onContextMenuEvent: function (node, evt) {
		evt.stopEvent();
		if (!node.attributes.loaded) {
			var m = new Ext.menu.Menu({
				items: [{
					handler: function (item, e) {
						item.parentMenu.node.expand(true, true);
					},
					hidden: node.attributes.loaded,
					text: 'Expand',
					iconCls: 'icon-expandAll'
				}, {
					handler: function (item, e) {
						item.parentMenu.node.collapse(true, true);
					},
					hidden: node.attributes.loaded,
					iconCls: 'icon-collapseAll',
					text: 'Collapse'
				}]
			});
			m.node = node;
			var c = evt.getXY();
			m.showAt([c[0], c[1]]);
		}
	},
	/**
	 *
	 * @param {EventObject} evt event
	 * @param {Element} tool toolbar
	 * @param {Panel} panel current panel
	 */
	onCollapseAllClick: function (evt, tool, panel) {
		var me = this;
		me.collapseAll();
	},
	/**
	 *
	 * @param {EventObject} evt event
	 * @param {Element} tool toolbar
	 * @param {Panel} panel current panel
	 */
	onExpandAllClick: function (evt, tool, panel) {
		var me = this;
		me.expandAll();
	},
	/**
	 *
	 * @param {EventObject} evt event
	 * @param {Element} tool toolbar
	 * @param {Panel} panel current panel
	 */
	onRefreshClick: function (evt, tool, panel) {
		var me = this;
		var treeLoader = me.getLoader();
		treeLoader.baseParams.hierClass = me.hierClass;
		treeLoader.baseParams.version = me.version;
		treeLoader.baseParams.excludeStatusList = me.getTopToolbar().chkStatus.checked ? 'Inactive' : '';
		treeLoader.baseParams.reload = "true";
		treeLoader.load(me.getRootNode(), function (node) {
			for (var p in node.stateHash) {
				if (node.stateHash.hasOwnProperty(p)) {
					node.expandPath(me.stateHash[p]);
				}
			}
		});
	},
	/**
	 *
	 */
	setNodesLength: function () {
		var me = this;
		me.getRootNode().cascade(function (node) {
			if (!node.isRoot) {
				++node.ownerTree.nodesLength;
			}
		});
	}
});
Ext.reg('HierTreePanel', PgmD.HierTreePanel);