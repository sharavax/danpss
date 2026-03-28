<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.danpss.servlets.AlumniDashboardServlet.AlumniProfile" %>
<%@ page import="com.danpss.servlets.AlumniDashboardServlet.Opportunity" %>
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
    <title>Alumni Dashboard - DANPSS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/app.css" rel="stylesheet">
</head>
<body>
<%
    String userName = String.valueOf(request.getAttribute("userName"));
    String userRole = String.valueOf(request.getAttribute("userRole"));
    AlumniProfile profile = (AlumniProfile) request.getAttribute("profile");
    List<Opportunity> opportunities = (List<Opportunity>) request.getAttribute("opportunities");
%>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard/alumni">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/alumnireg.html">Profile</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/jobpost.html">Post Opportunity</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell app-main">
    <div class="dashboard-shell">
        <section class="app-panel dashboard-hero">
            <div class="dashboard-hero-copy">
                <span class="kicker">Alumni Workspace</span>
                <h1 class="section-title mt-3">Welcome back, <%=safe(userName)%></h1>
                <p class="section-muted">Manage your alumni profile, review the live hiring pipeline, and contribute opportunities to students through a cleaner workspace.</p>
                <div class="dashboard-actions">
                    <a class="btn btn-primary" href="<%=request.getContextPath()%>/jobpost.html">Post Opportunity</a>
                    <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/alumnireg.html">Update Profile</a>
                </div>
            </div>
            <div class="dashboard-side">
                <div class="soft-card">
                    <div class="label">Workspace Access</div>
                    <div class="content"><%=safe(userRole)%></div>
                    <div class="dashboard-note mt-2">Role-based controls limit alumni contribution and posting actions to approved users.</div>
                </div>
                <div class="soft-card">
                    <div class="label">Contribution Focus</div>
                    <div class="content">Hiring and engagement</div>
                    <div class="dashboard-note mt-2">Use this workspace to keep profile details current and expand student opportunity flow.</div>
                </div>
            </div>
        </section>

        <section class="stat-grid">
            <div class="app-card stat-card">
                <span class="eyebrow">Active Jobs</span>
                <span class="value"><%=safe(request.getAttribute("totalJobs"))%></span>
                <div class="caption">Current full-time openings available in the platform.</div>
            </div>
            <div class="app-card stat-card">
                <span class="eyebrow">Internships</span>
                <span class="value"><%=safe(request.getAttribute("totalInternships"))%></span>
                <div class="caption">Internship opportunities visible to students right now.</div>
            </div>
            <div class="app-card stat-card">
                <span class="eyebrow">Hiring Companies</span>
                <span class="value"><%=safe(request.getAttribute("hiringCompanies"))%></span>
                <div class="caption">Distinct companies contributing to the opportunity pipeline.</div>
            </div>
            <div class="app-card stat-card">
                <span class="eyebrow">Profile Status</span>
                <span class="value"><%=profile == null ? "Pending" : "Ready"%></span>
                <div class="caption">Readiness for alumni contribution workflows.</div>
            </div>
        </section>

        <section class="soft-grid">
            <div class="soft-card">
                <div class="label">Department</div>
                <div class="content"><%=profile == null ? "--" : safe(profile.department)%></div>
            </div>
            <div class="soft-card">
                <div class="label">Graduation Year</div>
                <div class="content"><%=profile == null ? "--" : safe(profile.graduationYear)%></div>
            </div>
            <div class="soft-card">
                <div class="label">Current Company</div>
                <div class="content"><%=profile == null ? "--" : safe(profile.company)%></div>
            </div>
            <div class="soft-card">
                <div class="label">Designation</div>
                <div class="content"><%=profile == null ? "--" : safe(profile.designation)%></div>
            </div>
        </section>

        <section class="app-card app-section">
            <div class="section-head">
                <div>
                    <h2 class="h5 mb-1">Opportunity Feed</h2>
                    <p class="section-muted">Recent jobs and internships visible across the platform.</p>
                </div>
                <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/reports/jobs">Open Jobs Report</a>
            </div>
            <% if (opportunities == null || opportunities.isEmpty()) { %>
            <div class="empty-state">No opportunities are available yet.</div>
            <% } else { %>
            <div class="opportunity-list">
                <% for (Opportunity o : opportunities) { %>
                <div class="opportunity-card">
                    <div class="opportunity-meta">
                        <span class="meta-chip"><%=safe(o.postType)%></span>
                        <span class="meta-chip"><%=safe(o.jobType)%></span>
                        <span class="meta-chip"><%=safe(o.location)%></span>
                    </div>
                    <h3><%=safe(o.title)%></h3>
                    <p class="section-muted mb-2"><%=safe(o.company)%> • Posted <%=safe(o.postedDate)%></p>
                    <div class="dashboard-note">Opportunity ID <%=safe(o.jobId)%></div>
                </div>
                <% } %>
            </div>
            <% } %>
        </section>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Alumni Dashboard</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>
