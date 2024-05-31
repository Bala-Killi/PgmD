Ext.override(Ext.grid.GroupingView, {
	interceptMouse: Ext.emptyFn,
	toggleGroup: function (group, expanded) {
		var me = this;
		if (!me._flyweight.hasClass('ux-grow-action-item')) {
			var gel = Ext.get(group);
			var id = Ext.util.Format.htmlEncode(gel.id);
			expanded = Ext.isDefined(expanded) ? expanded : gel.hasClass('x-grid-group-collapsed');
			if (me.state[id] !== expanded) {
				if (me.cancelEditOnToggle !== false) {
					me.grid.stopEditing(true);
				}
				me.state[id] = expanded;
				gel[expanded ? 'removeClass' : 'addClass']('x-grid-group-collapsed');
			}
		}
	}
});
Ext.override(Ext.ux.form.LovCombo, {
	beforeBlur: Ext.emptyFn
});