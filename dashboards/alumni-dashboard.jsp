<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.danpss.servlets.AlumniDashboardServlet.AlumniProfile" %>
<%@ page import="com.danpss.servlets.AlumniDashboardServlet.Opportunity" %>
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
    <title>Alumni Dashboard - DANPSS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/app.css" rel="stylesheet">
</head>
<body>
<%
    String userName = String.valueOf(request.getAttribute("userName"));
    String userRole = String.valueOf(request.getAttribute("userRole"));
    String userEmail = String.valueOf(request.getAttribute("userEmail"));
    AlumniProfile profile = (AlumniProfile) request.getAttribute("profile");
    List<Opportunity> opportunities = (List<Opportunity>) request.getAttribute("opportunities");
%>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard/alumni">Alumni Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/forms.html">Forms Hub</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/jobpost.html">Post Job</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell">
    <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
        <div>
            <span class="kicker">Alumni Workspace</span>
            <h1 class="section-title mb-1">Alumni Dashboard</h1>
            <p class="section-muted mb-0">Manage your profile and support campus hiring from one view.</p>
        </div>
        <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/index.html">Home</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/alumnireg.html">Update Alumni Profile</a>
            <a class="btn btn-primary" href="<%=request.getContextPath()%>/jobpost.html">Post Opportunity</a>
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
        <div class="col-md-4"><div class="app-card kpi-card"><div class="kpi-label">Total Jobs</div><div class="kpi-value"><%=safe(request.getAttribute("totalJobs"))%></div></div></div>
        <div class="col-md-4"><div class="app-card kpi-card"><div class="kpi-label">Total Internships</div><div class="kpi-value"><%=safe(request.getAttribute("totalInternships"))%></div></div></div>
        <div class="col-md-4"><div class="app-card kpi-card"><div class="kpi-label">Hiring Companies</div><div class="kpi-value"><%=safe(request.getAttribute("hiringCompanies"))%></div></div></div>
    </div>

    <div class="app-card mb-4">
        <h2 class="h5">Alumni Profile</h2>
        <% if (profile == null) { %>
        <div class="empty-state">No alumni profile found for this email. Complete the alumni form to enable full dashboard features.</div>
        <% } else { %>
        <div class="row g-2">
            <div class="col-md-4"><strong>Name:</strong> <%=safe(profile.name)%></div>
            <div class="col-md-4"><strong>Department:</strong> <%=safe(profile.department)%></div>
            <div class="col-md-4"><strong>Graduation Year:</strong> <%=safe(profile.graduationYear)%></div>
            <div class="col-md-4"><strong>Company:</strong> <%=safe(profile.company)%></div>
            <div class="col-md-4"><strong>Designation:</strong> <%=safe(profile.designation)%></div>
            <div class="col-md-4"><strong>Experience:</strong> <%=safe(profile.experience)%> years</div>
        </div>
        <% } %>
    </div>

    <div class="app-card mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="h5 mb-0">Latest Opportunities</h2>
            <a class="btn btn-sm btn-outline-primary" href="<%=request.getContextPath()%>/jobpost.html">Create New Post</a>
        </div>
        <div class="table-wrap">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="table-light">
                    <tr><th>ID</th><th>Type</th><th>Title</th><th>Company</th><th>Location</th><th>Job Type</th><th>Posted</th></tr>
                    </thead>
                    <tbody>
                    <% if (opportunities == null || opportunities.isEmpty()) { %>
                    <tr><td colspan="7" class="py-4"><div class="empty-state">No opportunities available yet.</div></td></tr>
                    <% } else { for (Opportunity o : opportunities) { %>
                    <tr>
                        <td><%=safe(o.jobId)%></td>
                        <td><%=safe(o.postType)%></td>
                        <td><%=safe(o.title)%></td>
                        <td><%=safe(o.company)%></td>
                        <td><%=safe(o.location)%></td>
                        <td><%=safe(o.jobType)%></td>
                        <td><%=safe(o.postedDate)%></td>
                    </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="app-card">
        <h2 class="h5">Next Actions</h2>
        <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/alumnireg.html">Refresh Alumni Profile</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/jobpost.html">Publish Job / Internship</a>
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/reports/jobs">View Jobs Report</a>
        </div>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Alumni Engagement and Hiring Collaboration</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>
