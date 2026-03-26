<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.danpss.servlets.PlacementOfficerDashboardServlet.OfficerSummary" %>
<%@ page import="com.danpss.servlets.PlacementOfficerDashboardServlet.StudentRow" %>
<%@ page import="com.danpss.servlets.PlacementOfficerDashboardServlet.JobRow" %>
<%!
    private String safe(Object value) {
        if (value == null) return "";
        String text = String.valueOf(value);
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Placement Officer Dashboard - DANPSS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/app.css" rel="stylesheet">
</head>
<body>
<%
    String userName = String.valueOf(request.getAttribute("userName"));
    String userRole = String.valueOf(request.getAttribute("userRole"));
    String userEmail = String.valueOf(request.getAttribute("userEmail"));
    OfficerSummary summary = (OfficerSummary) request.getAttribute("summary");
    List<StudentRow> students = (List<StudentRow>) request.getAttribute("students");
    List<JobRow> jobs = (List<JobRow>) request.getAttribute("jobs");
%>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard/officer">Officer Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/forms.html">Forms Hub</a></li>`r`n                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/placement">Placement Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell">
    <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
        <div>
            <span class="kicker">Officer Workspace</span>
            <h1 class="section-title mb-1">Placement Officer Dashboard</h1>
            <p class="section-muted mb-0">Monitor pipeline health, recent profiles, and opportunity flow in one workspace.</p>
        </div>
        <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/index.html">Home</a>
            <a class="btn btn-primary" href="<%=request.getContextPath()%>/reports/placement">Placement Report</a>
            <a class="btn btn-primary" href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a>
        </div>
    </div>

    <div class="app-card mb-4">
        <div class="d-flex flex-wrap gap-2">
            <span class="meta-chip">User: <%=safe(userName)%></span>
            <span class="meta-chip">Role: <%=safe(userRole)%></span>
            <span class="meta-chip">Email: <%=safe(userEmail)%></span>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6 col-xl-2"><div class="app-card kpi-card"><div class="kpi-label">Users</div><div class="kpi-value"><%=safe(summary.totalUsers)%></div></div></div>
        <div class="col-md-6 col-xl-2"><div class="app-card kpi-card"><div class="kpi-label">Students</div><div class="kpi-value"><%=safe(summary.totalStudents)%></div></div></div>
        <div class="col-md-6 col-xl-2"><div class="app-card kpi-card"><div class="kpi-label">Alumni</div><div class="kpi-value"><%=safe(summary.totalAlumni)%></div></div></div>
        <div class="col-md-6 col-xl-2"><div class="app-card kpi-card"><div class="kpi-label">Jobs</div><div class="kpi-value"><%=safe(summary.totalJobs)%></div></div></div>
        <div class="col-md-6 col-xl-2"><div class="app-card kpi-card"><div class="kpi-label">Placed</div><div class="kpi-value"><%=safe(summary.placedStudents)%></div></div></div>
        <div class="col-md-6 col-xl-2"><div class="app-card kpi-card"><div class="kpi-label">Placement Rate</div><div class="kpi-value"><%=String.format("%.2f", summary.placementRate)%>%</div></div></div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-6">
            <div class="app-card h-100">
                <h2 class="h5">Latest Students</h2>
                <div class="table-wrap mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light"><tr><th>ID</th><th>Name</th><th>Department</th><th>Year</th><th>Skills</th></tr></thead>
                            <tbody>
                            <% if (students == null || students.isEmpty()) { %>
                            <tr><td colspan="5" class="py-4"><div class="empty-state">No student records available.</div></td></tr>
                            <% } else { for (StudentRow s : students) { %>
                            <tr>
                                <td><%=safe(s.studentId)%></td>
                                <td><%=safe(s.name)%></td>
                                <td><%=safe(s.department)%></td>
                                <td><%=safe(s.graduationYear)%></td>
                                <td><%=safe(s.skills)%></td>
                            </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="app-card h-100">
                <h2 class="h5">Latest Jobs / Internships</h2>
                <div class="table-wrap mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light"><tr><th>ID</th><th>Type</th><th>Title</th><th>Company</th><th>Location</th><th>Posted</th></tr></thead>
                            <tbody>
                            <% if (jobs == null || jobs.isEmpty()) { %>
                            <tr><td colspan="6" class="py-4"><div class="empty-state">No job records available.</div></td></tr>
                            <% } else { for (JobRow j : jobs) { %>
                            <tr>
                                <td><%=safe(j.jobId)%></td>
                                <td><%=safe(j.postType)%></td>
                                <td><%=safe(j.title)%></td>
                                <td><%=safe(j.company)%></td>
                                <td><%=safe(j.location)%></td>
                                <td><%=safe(j.postedDate)%></td>
                            </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="app-card">
        <h2 class="h5">Officer Actions</h2>
        <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/studentprofile.html">Student Form</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/jobpost.html">Job Form</a>
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/reports/placement">Placement Analytics</a>
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/reports/jobs">Jobs Analytics</a>
        </div>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Placement Governance and Outcome Analytics</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>

