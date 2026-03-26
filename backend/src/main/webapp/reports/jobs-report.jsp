<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Jobs and Internship Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; }
        form { display: grid; grid-template-columns: repeat(5, minmax(120px, 1fr)); gap: 8px; margin-bottom: 16px; }
        input, select, button { padding: 8px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f3f3f3; }
        .top-links { margin-bottom: 14px; }
    </style>
</head>
<body>
<div class="top-links">
    <a href="<%=request.getContextPath()%>/index.html">Home</a> |
    <a href="<%=request.getContextPath()%>/reports/placement">Placement Report</a>
</div>

<h2>Jobs and Internship Report</h2>

<form method="get" action="<%=request.getContextPath()%>/reports/jobs">
    <input type="text" name="title" placeholder="Title" value="<%=request.getAttribute("title")%>"/>
    <input type="text" name="company" placeholder="Company" value="<%=request.getAttribute("company")%>"/>
    <select name="postType">
        <option value="">All Post Types</option>
        <option value="Job" <%= "Job".equals(request.getAttribute("postType")) ? "selected" : "" %>>Job</option>
        <option value="Internship" <%= "Internship".equals(request.getAttribute("postType")) ? "selected" : "" %>>Internship</option>
    </select>
    <input type="text" name="location" placeholder="Location" value="<%=request.getAttribute("location")%>"/>
    <button type="submit">Apply Filters</button>
</form>

<table>
    <thead>
    <tr>
        <th>ID</th>
        <th>Post Type</th>
        <th>Title</th>
        <th>Company</th>
        <th>Location</th>
        <th>Job Type</th>
        <th>Posted Date</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<String[]> rows = (List<String[]>) request.getAttribute("rows");
        if (rows != null && !rows.isEmpty()) {
            for (String[] row : rows) {
    %>
    <tr>
        <td><%=row[0]%></td>
        <td><%=row[1]%></td>
        <td><%=row[2]%></td>
        <td><%=row[3]%></td>
        <td><%=row[4]%></td>
        <td><%=row[5]%></td>
        <td><%=row[6]%></td>
    </tr>
    <%      }
        } else { %>
    <tr><td colspan="7">No jobs found for selected filters.</td></tr>
    <% } %>
    </tbody>
</table>

</body>
</html>
