<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.danpss.servlets.DashboardServlet.StudentProfile" %>
<%@ page import="com.danpss.servlets.DashboardServlet.Recommendation" %>
<%@ page import="com.danpss.servlets.DashboardServlet.Rules" %>
<!DOCTYPE html>
<html>
<head>
    <title>DANPSS Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f7fb; color: #1f2937; }
        .top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .card { background: #fff; border: 1px solid #d7deea; border-radius: 8px; padding: 14px; margin-bottom: 12px; }
        .muted { color: #64748b; font-size: 13px; }
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 8px; overflow: hidden; }
        th, td { border: 1px solid #e5e7eb; padding: 8px; text-align: left; }
        th { background: #f1f5f9; }
        .score { font-weight: 700; color: #0f766e; }
        .warn { background: #fff7ed; border-color: #fed7aa; }
        .pill { display: inline-block; padding: 2px 8px; border-radius: 999px; background: #e2e8f0; font-size: 12px; }
        .links a { margin-right: 10px; }
    </style>
</head>
<body>
<%
    String userName = String.valueOf(request.getAttribute("userName"));
    String userRole = String.valueOf(request.getAttribute("userRole"));
    StudentProfile student = (StudentProfile) request.getAttribute("student");
    List<Recommendation> recommendations = (List<Recommendation>) request.getAttribute("recommendations");
    Rules rules = (Rules) request.getAttribute("rules");
%>

<div class="top">
    <div>
        <h2 style="margin: 0;">Dashboard</h2>
        <div class="muted">Welcome, <strong><%= userName %></strong> (<%= userRole %>)</div>
    </div>
    <div class="links">
        <a href="<%=request.getContextPath()%>/index.html">Home</a>
        <a href="<%=request.getContextPath()%>/reports/placement">Placement Report</a>
        <a href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a>
    </div>
</div>

<div class="card">
    <h3 style="margin-top: 0;">Matching Rules</h3>
    <div class="muted">
        Skills Weight: <span class="pill"><%= String.format("%.2f", rules.skillsWeight) %></span>
        Eligibility Weight: <span class="pill"><%= String.format("%.2f", rules.eligibilityWeight) %></span>
        Graduation Year Weight: <span class="pill"><%= String.format("%.2f", rules.gradYearWeight) %></span>
        Minimum Score: <span class="pill"><%= String.format("%.2f", rules.minScore) %></span>
    </div>
</div>

<% if (student == null) { %>
<div class="card warn">
    <h3 style="margin-top: 0;">Student Profile Required</h3>
    <p>No student profile found for your login email. Create one to get recommendations.</p>
    <a href="<%=request.getContextPath()%>/studentprofile.html">Create Student Profile</a>
</div>
<% } else { %>
<div class="card">
    <h3 style="margin-top: 0;">Profile Snapshot</h3>
    <div class="muted">
        Department: <strong><%= student.department %></strong> |
        Graduation Year: <strong><%= student.graduationYear %></strong> |
        Skills: <strong><%= student.skills %></strong>
    </div>
</div>

<h3>Recommended Jobs</h3>
<table>
    <thead>
    <tr>
        <th>Score</th>
        <th>Post Type</th>
        <th>Title</th>
        <th>Company</th>
        <th>Location</th>
        <th>Job Type</th>
        <th>Why Matched</th>
    </tr>
    </thead>
    <tbody>
    <% if (recommendations == null || recommendations.isEmpty()) { %>
    <tr><td colspan="7">No recommendations available with current rules.</td></tr>
    <% } else {
        for (Recommendation r : recommendations) { %>
    <tr>
        <td class="score"><%= String.format("%.2f", r.score) %></td>
        <td><%= r.postType %></td>
        <td><%= r.title %></td>
        <td><%= r.company %></td>
        <td><%= r.location %></td>
        <td><%= r.jobType %></td>
        <td><%= r.reason %></td>
    </tr>
    <%  }
       } %>
    </tbody>
</table>
<% } %>

</body>
</html>
