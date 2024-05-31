<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="PgmD.App.Default" MasterPageFile="~/master/Site.Master" Title="Program Directory" %>

<%@ Import Namespace="Newtonsoft.Json" %>
<asp:Content ID="headerContent" ContentPlaceHolderID="head" runat="server">
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	<meta name="robots" content="index,nofollow" />
	<meta name="subject" content="Program Directory v.<%= ConfigurationManager.AppSettings["Version"] %>" />
	<meta name="title" content="Program Directory" />
	<link rel="stylesheet" type="text/css" href="<%= ResolveUrl("~/includes/js/ux/form/LovCombo.min.css") %>" />
	<link rel="stylesheet" type="text/css" href="<%= ResolveUrl("~/includes/js/ux/grid/RowActions.min.css") %>" />
	<link rel="stylesheet" type="text/css" href="/CDN/resources/css/silk.css" />
	<link rel="stylesheet" type="text/css" href="<%= ResolveUrl("~/includes/css/PgmD.min.css") %>" />
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
	<div id="contentHome" style="font-size: 10pt; padding: 10px;">
	</div>
	<%: System.Web.Optimization.Scripts.Render("~/Scripts/Default") %>
	<script type="text/javascript">
		Ext.onReady(function(){
			Ext.QuickTips.init();
			Ext.apply(Ext.QuickTips.getQuickTip(), {
				defaultAlign: "t-b?",
				dismissDelay: 0
			});
			Ext.apply(PgmD, {
				data: <%=JsonConvert.SerializeObject(Data)%>,
				initTab: '<%=HttpUtility.HtmlEncode(InitTab)%>',
				initApp: '<%=HttpUtility.HtmlEncode(InitApp)%>',
				initFunction: '<%=HttpUtility.HtmlEncode(InitFunction)%>',
				privMask: <%=JsonConvert.SerializeObject(PrivMask)%>,
				acWarningPeriod: <%=AcWarningPeriod%>,
				user: {
					bemsId: '<%=HttpUtility.HtmlEncode(Bemsid)%>',
					isAdmin: function () {
						return <%=IsAdmin%>;
					}
				},
				// Custom function to submit new page call using POST method
				hasClass: function (ele, cls) {
					return ele.className.match(new RegExp('(\\s|^)' + cls + '(\\s|$)'));
				},
				addClass: function (ele, cls) {
					if (!PgmD.hasClass(ele, cls)) ele.className += " " + cls;
				},
				removeClass: function (ele, cls) {
					if (PgmD.hasClass(ele, cls)) {
						var reg = new RegExp('(\\s|^)' + cls + '(\\s|$)');
						ele.className = ele.className.replace(reg, ' ');
					}
				}
			});
			PgmD.ws = new PgmD.Viewport({
				id: 'PgmD'
			});
		});
	</script>
</asp:Content>