// ReSharper disable UnusedParameter
// ReSharper disable UseOfImplicitGlobalInFunctionScope
/**
 * @namespace PgmD
 * @class TreeSearchField
 * @extends Ext.form.TwinTriggerField
 */
PgmD.TreeSearchField = Ext.extend(Ext.form.TwinTriggerField, {
	hideTrigger1: true,
	paramName: 'query',
	trigger1Class: 'x-form-clear-trigger',
	trigger2Class: 'x-form-search-trigger',
	validateOnBlur: false,
	validationEvent: false,
	/**
	 *  This method is invoked by the constructor. It is used to initialize data, set up configurations, and attach event handlers.
	 */
	initComponent: function () {
		var me = this;
		me.constructor.superclass.initComponent.call(me);
		me.on('specialkey', function (f, evt) {
			switch (evt.getKey()) {
				case Ext.EventObject.ENTER:
					evt.preventDefault();
					me.onTrigger2Click();
					break;
				case Ext.EventObject.ESC:
					evt.preventDefault();
					me.onTrigger1Click();
					break;
				default:
			}
		});
		me.on('afterrender', function (f, evt) {
			var wrapDiv = me.wrap;
			if (wrapDiv) {
				wrapDiv.setWidth(me.width);
			}
		});
	},
	/**
	 * Reset click
	 * @param {Ext.EventObject} evt Event
	 */
	onTrigger1Click: function (evt) {
		var me = this;
		var tree = me.tree || me.ownerCt.ownerCt;
		var tbar = tree.getTopToolbar();
		me.setValue('');
		tree.collapseAll();
		tree.filter.clear();
		me.triggers[0].hide();
		if (tbar.chkStatus) {
			tbar.chkStatus.setDisabled(false);
		}
	},
	/**
	 * Search click
	 * @param {Ext.EventObject} evt Event
	 */
	onTrigger2Click: function (evt) {
		var me = this;
		var value = me.getRawValue();
		if (value.length < 1) {
			me.onTrigger1Click();
			return;
		}
		var tree = me.tree || me.ownerCt.ownerCt;
		var tbar = tree.getTopToolbar();
		if (tbar.chkStatus) {
			tbar.chkStatus.setDisabled(true);
		}
		tree.filter.filter(tbar.chkStatus.getValue(), value, ['abbreviation', 'qtip', 'alias']);
		me.triggers[0].show();
		var isHidden = true;
		var node = tree.root.firstChild;
		while (node) {
			if (!node.hidden) {
				isHidden = false;
				break;
			}
			node = node.nextSibling;
		}
		if (isHidden) {
			Ext.Msg.alert('Organization Search', 'No record found that matches your search.');
		}
	}
});
Ext.reg('TreeSearchField', PgmD.TreeSearchField);