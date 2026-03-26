<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.danpss.servlets.StudentDashboardServlet.StudentProfile" %>
<%@ page import="com.danpss.servlets.StudentDashboardServlet.Recommendation" %>
<%@ page import="com.danpss.servlets.StudentDashboardServlet.Rules" %>
<%!
    private String safe(Object value) {
        if (value == null) {
            return "";
        }
        String text = String.valueOf(value);
        return text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - DANPSS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/app.css" rel="stylesheet">
</head>
<body>
<%
    String userName = String.valueOf(request.getAttribute("userName"));
    String userRole = String.valueOf(request.getAttribute("userRole"));
    String userEmail = String.valueOf(request.getAttribute("userEmail"));
    StudentProfile student = (StudentProfile) request.getAttribute("student");
    List<Recommendation> recommendations = (List<Recommendation>) request.getAttribute("recommendations");
    Rules rules = (Rules) request.getAttribute("rules");
%>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard/student">Student Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/forms.html">Forms Hub</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell">
    <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
        <div>
            <span class="kicker">Student Workspace</span>
            <h1 class="section-title mb-1">Student Dashboard</h1>
            <p class="section-muted mb-0">Track profile strength and AI-assisted opportunity recommendations.</p>
        </div>
        <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/index.html">Home</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/studentprofile.html">Update Profile</a>
            <a class="btn btn-primary" href="<%=request.getContextPath()%>/reports/jobs">Explore Openings</a>
        </div>
    </div>

    <div class="app-card mb-4">
        <div class="d-flex flex-wrap gap-2">
            <span class="meta-chip">User: <%=safe(userName)%></span>
            <span class="meta-chip">Role: <%=safe(userRole)%></span>
            <span class="meta-chip">Email: <%=safe(userEmail)%></span>
        </div>
        <hr>
        <div class="d-flex flex-wrap gap-2">
            <span class="badge badge-soft rounded-pill px-3 py-2">Skills Weight <%=String.format("%.2f", rules.skillsWeight)%></span>
            <span class="badge badge-soft rounded-pill px-3 py-2">Eligibility Weight <%=String.format("%.2f", rules.eligibilityWeight)%></span>
            <span class="badge badge-soft rounded-pill px-3 py-2">Grad Year Weight <%=String.format("%.2f", rules.gradYearWeight)%></span>
            <span class="badge badge-soft rounded-pill px-3 py-2">Minimum Score <%=String.format("%.2f", rules.minScore)%></span>
            <span class="badge badge-soft rounded-pill px-3 py-2">Max Results <%=rules.maxRecommendations%></span>
        </div>
    </div>

    <% if (student == null) { %>
    <div class="empty-state">
        <h2 class="h5">Student Profile Required</h2>
        <p class="mb-3">No profile was found for your session email. Create a profile to activate recommendations.</p>
        <a class="btn btn-primary" href="<%=request.getContextPath()%>/studentprofile.html">Create Student Profile</a>
    </div>
    <% } else { %>
    <div class="app-card mb-4">
        <h2 class="h5">Profile Snapshot</h2>
        <div class="row g-2 mt-1">
            <div class="col-md-4"><strong>Department:</strong> <%=safe(student.department)%></div>
            <div class="col-md-4"><strong>Graduation Year:</strong> <%=safe(student.graduationYear)%></div>
            <div class="col-md-4"><strong>Skills:</strong> <%=safe(student.skills)%></div>
        </div>
    </div>

    <div class="app-card mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="h5 mb-0">Top Recommendations</h2>
            <span class="badge badge-soft rounded-pill px-3 py-2"><%=safe(request.getAttribute("recommendationCount"))%> match(es)</span>
        </div>
        <% if (recommendations == null || recommendations.isEmpty()) { %>
        <div class="empty-state">No recommendations available with the current profile and rule thresholds.</div>
        <% } else { %>
        <div class="table-wrap">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>Score</th>
                        <th>Role</th>
                        <th>Company</th>
                        <th>Location</th>
                        <th>Type</th>
                        <th>Subscores</th>
                        <th>Reason</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Recommendation r : recommendations) { %>
                    <tr>
                        <td><strong><%=String.format("%.2f", r.score)%></strong><br><span class="text-muted small"><%=safe(r.postedDate)%></span></td>
                        <td><%=safe(r.title)%><br><span class="text-muted small"><%=safe(r.postType)%></span></td>
                        <td><%=safe(r.company)%></td>
                        <td><%=safe(r.location)%></td>
                        <td><%=safe(r.jobType)%></td>
                        <td class="text-muted small">Skills <%=String.format("%.2f", r.skillsScore)%><br>Eligibility <%=String.format("%.2f", r.eligibilityScore)%><br>Grad <%=String.format("%.2f", r.gradYearScore)%></td>
                        <td><%=safe(r.reason)%></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>

    <div class="app-card">
        <h2 class="h5">Next Actions</h2>
        <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/studentprofile.html">Maintain Profile</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/reports/jobs">Search Openings</a>
            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/dashboard">Refresh Dashboard</a>
        </div>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Student Insights and Recommendation Workspace</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>
