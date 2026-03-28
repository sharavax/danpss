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
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
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
    StudentProfile student = (StudentProfile) request.getAttribute("student");
    List<Recommendation> recommendations = (List<Recommendation>) request.getAttribute("recommendations");
    Rules rules = (Rules) request.getAttribute("rules");
    int recommendationCount = recommendations == null ? 0 : recommendations.size();
    double recommendationAverage = request.getAttribute("recommendationAverage") == null ? 0.0d : ((Double) request.getAttribute("recommendationAverage")).doubleValue();
    int profileStrength = student == null ? 0 : 65;
    if (student != null && student.graduationYear > 0) {
        profileStrength += 15;
    }
    if (student != null && safe(student.skills).length() > 0) {
        profileStrength += 20;
    }
%>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard/student">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/studentprofile.html">Profile</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/jobs">Opportunities</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell app-main">
    <div class="dashboard-shell">
        <section class="app-panel dashboard-hero">
            <div class="dashboard-hero-copy">
                <span class="kicker">Student Workspace</span>
                <h1 class="section-title mt-3">Welcome back, <%=safe(userName)%></h1>
                <p class="section-muted">Review your profile readiness, explore relevant opportunities, and keep your placement data current from one focused dashboard.</p>
                <div class="dashboard-actions">
                    <a class="btn btn-primary" href="<%=request.getContextPath()%>/reports/jobs">Explore Opportunities</a>
                    <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/studentprofile.html">Update Profile</a>
                </div>
            </div>
            <div class="dashboard-side">
                <div class="soft-card">
                    <div class="label">Workspace Access</div>
                    <div class="content"><%=safe(userRole)%></div>
                    <div class="dashboard-note mt-2">Role-based access is active for forms, reports, and dashboard routes.</div>
                </div>
                <div class="soft-card">
                    <div class="label">Recommendation Policy</div>
                    <div class="content"><%=rules.maxRecommendations%> focused matches</div>
                    <div class="dashboard-note mt-2">Recommendations are prioritized using skills, eligibility, and graduation-year fit.</div>
                </div>
            </div>
        </section>

        <section class="stat-grid">
            <div class="app-card stat-card">
                <span class="eyebrow">Profile Strength</span>
                <span class="value"><%=profileStrength%>%</span>
                <div class="caption">Based on the readiness fields completed in your profile.</div>
            </div>
            <div class="app-card stat-card">
                <span class="eyebrow">Matches</span>
                <span class="value"><%=recommendationCount%></span>
                <div class="caption">Relevant opportunities currently available for your profile.</div>
            </div>
            <div class="app-card stat-card">
                <span class="eyebrow">Average Score</span>
                <span class="value"><%=String.format("%.2f", recommendationAverage)%></span>
                <div class="caption">Average fit score across your current recommendation list.</div>
            </div>
            <div class="app-card stat-card">
                <span class="eyebrow">Primary Track</span>
                <span class="value"><%=student == null ? "--" : safe(student.department)%></span>
                <div class="caption">Your current department and recommendation context.</div>
            </div>
        </section>

        <% if (student == null) { %>
        <section class="app-card app-section">
            <div class="empty-state">
                <h2 class="h5">Complete Your Student Profile</h2>
                <p class="mb-3">Your dashboard is ready, but recommendations and opportunity tracking will appear after you complete the student profile.</p>
                <a class="btn btn-primary" href="<%=request.getContextPath()%>/studentprofile.html">Create Student Profile</a>
            </div>
        </section>
        <% } else { %>
        <section class="soft-grid">
            <div class="soft-card">
                <div class="label">Department</div>
                <div class="content"><%=safe(student.department)%></div>
            </div>
            <div class="soft-card">
                <div class="label">Graduation Year</div>
                <div class="content"><%=safe(student.graduationYear)%></div>
            </div>
            <div class="soft-card">
                <div class="label">Profile Skills</div>
                <div class="content"><%=safe(student.skills)%></div>
            </div>
        </section>

        <section class="app-card app-section">
            <div class="section-head">
                <div>
                    <h2 class="h5 mb-1">Recommended Opportunities</h2>
                    <p class="section-muted">A focused list of roles aligned to your current profile and platform matching rules.</p>
                </div>
                <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/reports/jobs">Open Full Jobs Report</a>
            </div>
            <% if (recommendations == null || recommendations.isEmpty()) { %>
            <div class="empty-state">No recommendations are available yet. Update your skills or profile details to improve matching.</div>
            <% } else { %>
            <div class="opportunity-list">
                <% for (Recommendation r : recommendations) { %>
                <div class="opportunity-card">
                    <div class="recommendation-row">
                        <div class="recommendation-score">
                            <strong><%=String.format("%.2f", r.score)%></strong>
                            <span class="dashboard-note">Fit Score</span>
                        </div>
                        <div>
                            <div class="opportunity-meta">
                                <span class="meta-chip"><%=safe(r.postType)%></span>
                                <span class="meta-chip"><%=safe(r.jobType)%></span>
                                <span class="meta-chip"><%=safe(r.location)%></span>
                            </div>
                            <h3><%=safe(r.title)%></h3>
                            <p class="section-muted mb-2"><%=safe(r.company)%> • Posted <%=safe(r.postedDate)%></p>
                            <p class="mb-2"><%=safe(r.reason)%></p>
                            <div class="dashboard-note">Skills <%=String.format("%.2f", r.skillsScore)%> • Eligibility <%=String.format("%.2f", r.eligibilityScore)%> • Graduation Year <%=String.format("%.2f", r.gradYearScore)%></div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </section>
        <% } %>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Student Dashboard</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>
