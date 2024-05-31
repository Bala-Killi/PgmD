<%@ Page Title="" Language="C#" MasterPageFile="~/master/Site.Master" AutoEventWireup="true" CodeBehind="NoAccess.aspx.cs" Inherits="PgmD.App.view.NoAccess" %>

<asp:Content ID="headerContent" ContentPlaceHolderID="head" runat="server">
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	<meta name="robots" content="noindex,nofollow" />
	<meta name="subject" content="Program Directory v.<%= ConfigurationManager.AppSettings["Version"] %>" />
	<meta name="title" content="Program Directory | No Access" />
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
	Show no access content here.
</asp:Content>