Ext.ns('Ext.ux.tree');
Ext.ux.tree.TreeFilterX = Ext.extend(Ext.tree.TreeFilter, {
	filter: function (status, value, attr, startNode) {
		var me = this;
		var animate = me.tree.animate;
		me.tree.animate = false;
		me.tree.expandAll();
		me.tree.animate = animate;
		me.filterBy(function (n) {
			var result = false;
			for (var id in attr) {
				if (RegExp('(^' + value + '$|^' + value + '[^a-z0-9]|[^a-z0-9]' + value + '[^a-z0-9]|[^a-z0-9]' + value + '$)', 'i').test(n.attributes[attr[id]]) && n.attributes.status === (status ? 'Active' : n.attributes.status)) {
					result = true;
					break;
				}
			}
			return result;
		}, null, startNode);
	},
	filterBy: function (fn, scope, startNode) {
		var me = this;
		startNode = startNode || me.tree.root;
		if (me.autoClear) {
			me.clear();
		}
		var af = me.filtered,
			rv = me.reverse;
		var f = function (n) {
			if (n === startNode) {
				return true;
			}
			if (af[n.id]) {
				return false;
			}
			var m = fn.call(scope || n, n);
			if (!m || rv) {
				af[n.id] = n;
				n.ui.hide();
				return true;
			} else {
				n.ui.show();
				var p = n.parentNode;
				while (p && p !== me.root) {
					p.ui.show();
					p = p.parentNode;
				}
				return true;
			}
		};
		startNode.cascade(f);
		if (me.remove) {
			for (var id in af) {
				if (typeof id !== 'function') {
					var n = af[id];
					if (n && n.parentNode) {
						n.parentNode.removeChild(n);
					}
				}
			}
		}
	}
});