Ext.ns('Ext.ux.grid');
if ('function' !== typeof RegExp.escape) {
	RegExp.escape = function (s) {
		if ('string' !== typeof s) {
			return s;
		}
		return s.replace(/([.*+?\^=!:${}()|\[\]\/\\])/g, '\\$1');
	};
}
Ext.ux.grid.RowActions = function (config) {
	Ext.apply(this, config);
	this.addEvents('beforeaction', 'action', 'beforegroupaction', 'groupaction');
	Ext.ux.grid.RowActions.superclass.constructor.call(this);
};
Ext.extend(Ext.ux.grid.RowActions, Ext.util.Observable, {
	actionEvent: 'click',
	autoWidth: true,
	dataIndex: '',
	editable: false,
	header: '',
	isColumn: true,
	keepSelection: false,
	menuDisabled: true,
	sortable: false,
	//    tplGroup: '<tpl for="actions">' + '<div class="ux-grow-action-item<tpl if="\'right\'===align"> ux-action-right</tpl> ' + '{cls}" style="{style}" qtip="{qtip}">{text}</div>' + '</tpl>',
	tplGroup: '<tpl for="actions">' + '<div class="ux-grow-action-item<tpl if="\'right\'===align"> ux-action-right</tpl> ' + '{cls}" style="hideGroupAction{style}" qtip="{qtip}">{text}</div>' + '</tpl>',
	tplRow: '<div class="ux-row-action">' + '<tpl for="actions">' + '<div class="ux-row-action-item {cls} <tpl if="text">' + 'ux-row-action-text</tpl>" style="{hide}{style}" qtip="{qtip}">' + '<tpl if="text"><span qtip="{qtip}">{text}</span></tpl></div>' + '</tpl>' + '</div>',
	hideMode: 'visibility',
	widthIntercept: 4,
	widthSlope: 21,
	init: function (grid) {
		this.grid = grid;
		this.id = this.id || Ext.id();
		var lookup = grid.getColumnModel().lookup;
		delete (lookup[undefined]);
		lookup[this.id] = this;
		if (!this.tpl) {
			this.tpl = this.processActions(this.actions);
		}
		if (this.autoWidth) {
			this.width = this.widthSlope * this.actions.length + this.widthIntercept;
			this.fixed = true;
		}
		var view = grid.getView();
		var cfg = {
			scope: this
		};
		cfg[this.actionEvent] = this.onClick;
		grid.afterRender = grid.afterRender.createSequence(function () {
			view.mainBody.on(cfg);
			grid.on('destroy', this.purgeListeners, this);
		}, this);
		if (!this.renderer) {
			this.renderer = function (value, cell, record, row, col, store) {
				cell.css += (cell.css ? ' ' : '') + 'ux-row-action-cell';
				return this.tpl.apply(this.getData(value, cell, record, row, col, store));
			}.createDelegate(this);
		}
		if (view.groupTextTpl && this.groupActions) {
			view.interceptMouse = view.interceptMouse.createInterceptor(function (e) {
				if (e.getTarget('.ux-grow-action-item')) {
					return false;
				}
			});
			view.groupTextTpl = '<div class="ux-grow-action-text">' + view.groupTextTpl + '</div>' + this.processActions(this.groupActions, this.tplGroup).apply();
			// workaround to allow hideIndex on the group actions - inserted 'hideGroupAction' in the tplGroup above and replaced it with the dynamic value
			Ext.each(this.groupActions, function (a, i) {
				view.groupTextTpl = view.groupTextTpl.replace(/hideGroupAction/, '{[values.rs[0].data[\'' + a.hideIndex + '\'] ? \'' + ('display' === this.hideMode ? 'display:none' : 'visibility:hidden') + '\' : \'' + (a.hide ? ('display' === this.hideMode ? 'display:none' : 'visibility:hidden') : '') + '\']}');
			});
		}
		if (true === this.keepSelection) {
			grid.processEvent = grid.processEvent.createInterceptor(function (name, e) {
				if ('mousedown' === name) {
					return !this.getAction(e);
				}
			}, this);
		}
	},
	getData: function (value, cell, record, row, col, store) {
		return record.data || {};
	},
	processActions: function (actions, template) {
		var acts = [];
		Ext.each(actions, function (a, i) {
			if (a.iconCls && 'function' === typeof (a.callback || a.cb)) {
				this.callbacks = this.callbacks || {};
				this.callbacks[a.iconCls] = a.callback || a.cb;
			}
			var o = {
				cls: a.iconIndex ? '{' + a.iconIndex + '}' : (a.iconCls ? a.iconCls : ''),
				qtip: a.qtipIndex ? '{' + a.qtipIndex + '}' : (a.tooltip || a.qtip ? a.tooltip || a.qtip : ''),
				text: a.textIndex ? '{' + a.textIndex + '}' : (a.text ? a.text : ''),
				hide: a.hideIndex ? '<tpl if="' + a.hideIndex + '">' + ('display' === this.hideMode ? 'display:none' : 'visibility:hidden') + ';</tpl>' : (a.hide ? ('display' === this.hideMode ? 'display:none' : 'visibility:hidden;') : ''),
				align: a.align || 'right',
				//style: a.style ? a.style : ''
				style: a.styleIndex ? '{' + a.styleIndex + '}' : (a.style ? a.style : '')
			};
			acts.push(o);
		}, this);
		var xt = new Ext.XTemplate(template || this.tplRow);
		return new Ext.XTemplate(xt.apply({
			actions: acts
		}));
	},
	getAction: function (e) {
		var action = false;
		var t = e.getTarget('.ux-row-action-item');
		if (t) {
			action = t.className.replace(/ux-row-action-item /, '');
			if (action) {
				action = action.replace(/ ux-row-action-text/, '');
				action = action.trim();
			}
		}
		return action;
	},
	onClick: function (e, target) {
		var view = this.grid.getView();
		var row = e.getTarget('.x-grid3-row');
		var col = view.findCellIndex(target.parentNode.parentNode);
		var action = this.getAction(e);
		if (false !== row && false !== col && false !== action) {
			var record = this.grid.store.getAt(row.rowIndex);
			if (this.callbacks && 'function' === typeof this.callbacks[action]) {
				this.callbacks[action](this.grid, record, action, row.rowIndex, col);
			}
			if (true !== this.eventsSuspended && false === this.fireEvent('beforeaction', this.grid, record, action, row.rowIndex, col)) {
				return;
			} else if (true !== this.eventsSuspended) {
				this.fireEvent('action', this.grid, record, action, row.rowIndex, col);
			}
		}
		var t = e.getTarget('.ux-grow-action-item');
		if (t) {
			var group = view.findGroup(target);
			var groupId = group ? group.id.replace(/ext-gen[0-9]+-gp-/, '') : null;
			var records;
			if (groupId) {
				var re = new RegExp(RegExp.escape(groupId).replace(/$/, '$'));
				records = this.grid.store.queryBy(function (r) {
					return Ext.util.Format.htmlDecode(r._groupId).match(re);
				});
				records = records ? records.items : [];
			}
			action = t.className.replace(/ux-grow-action-item (ux-action-right )*/, '');
			if ('function' === typeof this.callbacks[action]) {
				this.callbacks[action](this.grid, records, action, groupId);
			}
			if (true !== this.eventsSuspended && false === this.fireEvent('beforegroupaction', this.grid, records, action, groupId)) {
				return false;
			}
			this.fireEvent('groupaction', this.grid, records, action, groupId);
		}
	}
});
Ext.reg('rowactions', Ext.ux.grid.RowActions);