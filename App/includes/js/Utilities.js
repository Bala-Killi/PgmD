// PgmD Common Function
Ext.ns('PgmD', 'PgmD.Common');

Array.prototype.pushArray = function (a) {
	var me = this;
	me.push.apply(me, a);
};
Array.prototype.unique = function () {
	var me = this;
	var a = [];
	var l = me.length;
	for (var i = 0; i < l; i++) {
		for (var j = i + 1; j < l; j++) {
			// If this[i] is found later in the array
			if (me[i] === me[j]) {
				j = ++i;
			}
		}
		a.push(me[i]);
	}
	return a;
};
Date.prototype.getAddDays = function (days) {
	var me = this;
	var d = new Date(me.toString());
	d.setDate(me.getDate() + days);
	return d;
};
Date.prototype.getAddMonths = function (months) {
	var me = this;
	var d = new Date(me.toString());
	d.setMonth(me.getMonth() + months);
	return d;
};
Date.prototype.getDayName = function () {
	var me = this;
	var d = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
	return d[me.getDay()];
};
Date.prototype.getDayShort = function () {
	var me = this;
	var d = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
	return d[me.getDay()];
};
Date.prototype.getDOY = function () {
	var me = this;
	var onejan = new Date(me.getFullYear(), 0, 1);
	if (onejan.getDST()) {
		onejan.addHours(1);
	}
	if (me.getDST()) {
		onejan.addHours(-1);
	}
	return Math.ceil((me - onejan + 1) / 86400000);
};
Date.prototype.getDST = function () {
	var me = this;
	return me.getTimezoneOffset() < me.getStdTimezoneOffset();
};
Date.prototype.getISOWeek = function () {
	var me = this;
	var onejan = new Date(me.getISOYear(), 0, 1);
	var wk = Math.ceil((((me - onejan) / 86400000) + onejan.getMDay() + 1) / 7);
	if (onejan.getMDay() > 3) {
		wk--;
	}
	return wk;
};
Date.prototype.getISOYear = function () {
	var me = this;
	var thu = new Date(me.getFullYear(), me.getMonth(), me.getDate() + 3 - me.getMDay());
	return thu.getFullYear();
};
Date.prototype.getJulian = function () {
	var me = this;
	return Math.floor((me / 86400000) - (me.getTimezoneOffset() / 1440) + 2440587.5);
};
Date.prototype.getMonthName = function () {
	var me = this;
	var m = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
	return m[me.getMonth()];
};
Date.prototype.getMonthShort = function () {
	var me = this;
	var m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
	return m[me.getMonth()];
};
Date.prototype.getMDay = function () {
	var me = this;
	return (me.getDay() + 6) % 7;
};
Date.prototype.getOrdinal = function () {
	var me = this;
	var d = me.getDate();
	switch (d) {
		case 1:
		case 21:
		case 31:
			return 'st';
		case 2:
		case 22:
			return 'nd';
		case 3:
		case 23:
			return 'rd';
		default:
			return 'th';
	}
};
Date.prototype.getStdTimezoneOffset = function () {
	var me = this;
	var jan = new Date(me.getFullYear(), 0, 1);
	var jul = new Date(me.getFullYear(), 6, 1);
	return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
};
Date.prototype.getSwatch = function () {
	var me = this;
	var swatch = ((me.getUTCHours() + 1) % 24) + me.getUTCMinutes() / 60 + me.getUTCSeconds() / 3600;
	return Math.floor(swatch * 1000 / 24);
};
Date.prototype.getToDateOnly = function () {
	var me = this;
	var d = new Date(me.toString());
	d.setHours(0, 0, 0, 0);
	return d;
};
Date.prototype.getWeek = function () {
	var me = this;
	var onejan = new Date(me.getFullYear(), 0, 1);
	return Math.ceil((((me - onejan) / 86400000) + onejan.getDay() + 1) / 7);
};
Date.prototype.format = function (f) {
	var me = this;
	var fmt = f.split('');
	var res = '';
	var d, h, m, s;
	for (var i = 0, l = fmt.length; i < l; i++) {
		switch (fmt[i]) {
			case '^':
				res += fmt[++i];
				break;
			case 'd':
				d = me.getDate();
				res += ((d < 10) ? '0' : '') + d;
				break;
			case 'D':
				res += me.getDayShort();
				break;
			case 'j':
				res += me.getDate();
				break;
			case 'l':
				res += me.getDayName();
				break;
			case 'S':
				res += me.getOrdinal();
				break;
			case 'w':
				res += me.getDay();
				break;
			case 'z':
				res += me.getDOY() - 1;
				break;
			case 'R':
				var dy = me.getDOY();
				if (dy < 9) {
					dy = '0' + dy;
				}
				res += (dy > 99) ? dy : '0' + dy;
				break;
			case 'F':
				res += me.getMonthName();
				break;
			case 'm':
				m = me.getMonth() + 1;
				res += ((m < 10) ? '0' : '') + m;
				break;
			case 'M':
				res += me.getMonthShort();
				break;
			case 'n':
				res += (me.getMonth() + 1);
				break;
			case 't':
				res += me.daysInMonth(me.getMonth() + 1, me.getFullYear());
				break;
			case 'L':
				res += (me.daysInMonth(2, me.getFullYear()) === 29) ? 1 : 0;
				break;
			case 'Y':
				res += me.getFullYear();
				break;
			case 'y':
				var y = me.getFullYear().toString().substr(3);
				res += ((y < 10) ? '0' : '') + y;
				break;
			case 'a':
				res += (me.getHours() > 11) ? 'pm' : 'am';
				break;
			case 'A':
				res += (me.getHours() > 11) ? 'PM' : 'AM';
				break;
			case 'g':
				h = me.getHours() % 12;
				res += (h === 0) ? 12 : h;
				break;
			case 'G':
				res += me.getHours();
				break;
			case 'h':
				h = me.getHours() % 12;
				res += (h === 0) ? 12 : (h > 9) ? h : '0' + h;
				break;
			case 'H':
				h = me.getHours();
				res += (h > 9) ? h : '0' + h;
				break;
			case 'i':
				m = me.getMinutes();
				res += (m > 9) ? m : '0' + m;
				break;
			case 's':
				s = me.getSeconds();
				res += (s > 9) ? s : '0' + s;
				break;
			case 'O':
				m = me.getTimezoneOffset();
				s = (m < 0) ? '+' : '-';
				m = Math.abs(m);
				h = Math.floor(m / 60);
				m = m % 60;
				res += s + ((h > 9) ? h : '0' + h) + ((m > 9) ? m : '0' + m);
				break;
			case 'P':
				m = me.getTimezoneOffset();
				s = (m < 0) ? '+' : '-';
				m = Math.abs(m);
				h = Math.floor(m / 60);
				m = m % 60;
				res += s + ((h > 9) ? h : '0' + h) + ':' + ((m > 9) ? m : '0' + m);
				break;
			case 'U':
				res += Math.floor(me.getTime() / 1000);
				break;
			case 'I':
				res += me.getDST() ? 1 : 0;
				break;
			case 'K':
				res += me.getDST() ? 'DST' : 'Std';
				break;
			case 'c':
				res += me.format('Y-m-d^TH:i:sP');
				break;
			case 'r':
				res += me.format('D, j M Y H:i:s P');
				break;
			case 'Z':
				var tz = me.getTimezoneOffset() * -60;
				res += tz;
				break;
			case 'W':
				res += me.getISOWeek();
				break;
			case 'X':
				res += me.getWeek();
				break;
			case 'x':
				var w = me.getWeek();
				res += ((w < 10) ? '0' : '') + w;
				break;
			case 'B':
				res += me.getSwatch();
				break;
			case 'N':
				d = me.getDay();
				res += d ? d : 7;
				break;
			case 'u':
				res += me.getMilliseconds() * 1000;
				break;
			case 'o':
				res += me.getISOYear();
				break;
			case 'J':
				res += me.getJulian();
				break;
			case 'e':
			case 'T':
				break;
			default:
				res += fmt[i];
		}
	}
	return res;
};
Date.prototype.toDateOnly = function () {
	var me = this;
	me.setHours(0, 0, 0, 0);
	return me;
};
Date.prototype.daysInMonth = function (month, year) {
	var dd = new Date(year, month, 0);
	return dd.getDate();
};
