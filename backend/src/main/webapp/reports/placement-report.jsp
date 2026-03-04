<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Placement Analytics Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; }
        .cards { display: flex; gap: 12px; margin-bottom: 16px; }
        .card { border: 1px solid #ccc; padding: 12px; min-width: 180px; border-radius: 6px; background: #fafafa; }
        form { display: grid; grid-template-columns: repeat(5, minmax(120px, 1fr)); gap: 8px; margin-bottom: 16px; }
        input, button { padding: 8px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f3f3f3; }
        .top-links { margin-bottom: 14px; }
    </style>
</head>
<body>
<div class="top-links">
    <a href="<%=request.getContextPath()%>/index.html">Home</a> |
    <a href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a>
</div>

<h2>Placement Analytics Report</h2>

<form method="get" action="<%=request.getContextPath()%>/reports/placement">
    <input type="text" name="search" placeholder="Search student name" value="<%=request.getAttribute("search")%>"/>
    <input type="text" name="department" placeholder="Department" value="<%=request.getAttribute("department")%>"/>
    <input type="text" name="graduationYear" placeholder="Graduation Year" value="<%=request.getAttribute("graduationYear")%>"/>
    <input type="text" name="company" placeholder="Company" value="<%=request.getAttribute("company")%>"/>
    <button type="submit">Apply Filters</button>
</form>

<div class="cards">
    <div class="card">
        <strong>Total Students</strong>
        <div><%=request.getAttribute("totalStudents")%></div>
    </div>
    <div class="card">
        <strong>Placed Students</strong>
        <div><%=request.getAttribute("placedStudents")%></div>
    </div>
    <div class="card">
        <strong>Placement Rate</strong>
        <div><%=request.getAttribute("placementRate")%>%</div>
    </div>
</div>

<table>
    <thead>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Department</th>
        <th>Graduation Year</th>
        <th>Company</th>
        <th>Designation</th>
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
    <tr><td colspan="7">No records found for selected filters.</td></tr>
    <% } %>
    </tbody>
</table>

</body>
</html>
