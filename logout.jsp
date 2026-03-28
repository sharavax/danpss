<%@ page import="javax.servlet.http.HttpSession" %>
<%
    HttpSession sessionRef = request.getSession(false);
    if (sessionRef != null) {
        sessionRef.invalidate();
    }
    response.sendRedirect(request.getContextPath() + "/login.html?logout=1");
%>
