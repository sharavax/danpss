<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.danpss.servlets.PlacementOfficerDashboardServlet.OfficerSummary" %>
<%@ page import="com.danpss.servlets.PlacementOfficerDashboardServlet.StudentRow" %>
<%@ page import="com.danpss.servlets.PlacementOfficerDashboardServlet.JobRow" %>
<%@ page import="com.danpss.servlets.PlacementOfficerDashboardServlet.MatchingRules" %>
<%!
    private String safe(Object value) {
        if (value == null) {
            return "";
        }
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
    MatchingRules rules = (MatchingRules) request.getAttribute("rules");
%>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard/officer">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/placement">Placement Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell app-main">
    <div class="dashboard-shell">
        <section class="app-panel dashboard-hero">
            <div class="dashboard-hero-copy">
                <span class="kicker">Placement Operations</span>
                <h1 class="section-title mt-3">Placement Officer Dashboard</h1>
                <p class="section-muted">A consolidated operational view for placement outcomes, student readiness, and opportunity flow.</p>
                <div class="dashboard-actions">
                    <a class="btn btn-primary" href="<%=request.getContextPath()%>/reports/placement">Placement Report</a>
                    <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a>
                </div>
            </div>
            <div class="dashboard-side">
                <div class="soft-card">
                    <div class="label">Workspace Access</div>
                    <div class="content"><%=safe(userRole)%></div>
                    <div class="dashboard-note mt-2">Administrative controls are restricted to placement officers.</div>
                </div>
                <div class="soft-card">
                    <div class="label">Signed In As</div>
                    <div class="content"><%=safe(userName)%></div>
                    <div class="dashboard-note mt-2"><%=safe(userEmail)%></div>
                </div>
            </div>
        </section>

        <% if ("rules_updated".equals(request.getParameter("success"))) { %>
        <div class="alert alert-success">Matching rules updated successfully.</div>
        <% } %>
        <% if ("rules_invalid_number".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger">Enter valid numeric values for every matching rule field.</div>
        <% } %>
        <% if ("rules_out_of_range".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger">Weights and minimum score must stay between 0.00 and 1.00.</div>
        <% } %>
        <% if ("rules_max_invalid".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger">Max recommendations must be between 1 and 20.</div>
        <% } %>
        <% if ("rules_weight_sum".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger">Skills, eligibility, and graduation-year weights must add up to exactly 1.00.</div>
        <% } %>

        <section class="stat-grid">
            <div class="app-card stat-card"><span class="eyebrow">Users</span><span class="value"><%=safe(summary.totalUsers)%></span><div class="caption">Registered accounts across the platform.</div></div>
            <div class="app-card stat-card"><span class="eyebrow">Students</span><span class="value"><%=safe(summary.totalStudents)%></span><div class="caption">Student records available for placement tracking.</div></div>
            <div class="app-card stat-card"><span class="eyebrow">Alumni</span><span class="value"><%=safe(summary.totalAlumni)%></span><div class="caption">Alumni profiles contributing to the ecosystem.</div></div>
            <div class="app-card stat-card"><span class="eyebrow">Placement Rate</span><span class="value"><%=String.format("%.2f", summary.placementRate)%>%</span><div class="caption">Students currently marked as placed.</div></div>
        </section>

        <section class="app-card app-section">
            <div class="section-head">
                <div>
                    <h2 class="h5 mb-1">Recommendation Rules</h2>
                    <p class="section-muted">Tune how the student workspace prioritizes opportunities.</p>
                </div>
            </div>
            <form action="<%=request.getContextPath()%>/admin/matching-rules" method="post" class="row g-3">
                <div class="col-md-6 col-xl-2">
                    <label class="form-label" for="skillsWeight">Skills Weight</label>
                    <input class="form-control" id="skillsWeight" name="skillsWeight" type="number" min="0" max="1" step="0.05" value="<%=safe(rules.skillsWeight)%>">
                </div>
                <div class="col-md-6 col-xl-2">
                    <label class="form-label" for="eligibilityWeight">Eligibility Weight</label>
                    <input class="form-control" id="eligibilityWeight" name="eligibilityWeight" type="number" min="0" max="1" step="0.05" value="<%=safe(rules.eligibilityWeight)%>">
                </div>
                <div class="col-md-6 col-xl-2">
                    <label class="form-label" for="gradYearWeight">Graduation Year Weight</label>
                    <input class="form-control" id="gradYearWeight" name="gradYearWeight" type="number" min="0" max="1" step="0.05" value="<%=safe(rules.gradYearWeight)%>">
                </div>
                <div class="col-md-6 col-xl-3">
                    <label class="form-label" for="minScore">Minimum Match Score</label>
                    <input class="form-control" id="minScore" name="minScore" type="number" min="0" max="1" step="0.05" value="<%=safe(rules.minScore)%>">
                </div>
                <div class="col-md-6 col-xl-2">
                    <label class="form-label" for="maxRecommendations">Max Recommendations</label>
                    <input class="form-control" id="maxRecommendations" name="maxRecommendations" type="number" min="1" max="20" step="1" value="<%=safe(rules.maxRecommendations)%>">
                </div>
                <div class="col-md-6 col-xl-1 d-flex align-items-end">
                    <button class="btn btn-primary w-100" type="submit">Save</button>
                </div>
            </form>
        </section>

        <div class="row g-4">
            <div class="col-lg-6">
                <div class="app-card h-100">
                    <h2 class="h5">Recent Students</h2>
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
                    <h2 class="h5">Recent Opportunities</h2>
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
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Placement Officer Dashboard</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>
