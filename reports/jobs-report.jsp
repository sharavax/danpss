<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
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
    <title>Jobs and Internship Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/app.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark app-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand app-brand" href="<%=request.getContextPath()%>/index.html">DANPSS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/jobs">Jobs Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/forms.html">Forms Hub</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/reports/placement">Placement Report</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/dashboard">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" data-nav href="<%=request.getContextPath()%>/logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-shell app-main" data-needs-lookups="true">
    <section class="app-panel dashboard-hero mb-4">
        <div class="dashboard-hero-copy">
            <span class="kicker">Opportunity Report</span>
            <h1 class="section-title mt-3">Jobs and Internships</h1>
            <p class="section-muted mb-0">Search the live opportunity pipeline through a cleaner operational report.</p>
        </div>
        <div class="dashboard-side">
            <div class="soft-card">
                <div class="label">Report Scope</div>
                <div class="content"><%=safe(request.getAttribute("resultCount"))%> visible results</div>
                <div class="dashboard-note mt-2">Filters are backed by the same structured opportunity records used in matching.</div>
            </div>
        </div>
    </section>
    <% if (request.getAttribute("errorMessage") != null) { %>
    <div class="alert alert-danger"><%=safe(request.getAttribute("errorMessage"))%></div>
    <% } %>

    <div class="app-card mb-4">
        <form method="get" action="<%=request.getContextPath()%>/reports/jobs" class="row g-3">
            <div class="col-md-6 col-xl-3">
                <label class="form-label">Title</label>
                <input class="form-control" type="text" name="title" placeholder="Title" value="<%=safe(request.getAttribute("title"))%>"/>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Company</label>
                <input class="form-control" type="text" name="company" placeholder="Company" list="reportJobsCompanyList" value="<%=safe(request.getAttribute("company"))%>"/>
                <datalist id="reportJobsCompanyList"></datalist>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Post Type</label>
                <select class="form-select" name="postType">
                    <option value="">All Post Types</option>
                    <option value="Job" <%= "Job".equals(request.getAttribute("postType")) ? "selected" : "" %>>Job</option>
                    <option value="Internship" <%= "Internship".equals(request.getAttribute("postType")) ? "selected" : "" %>>Internship</option>
                </select>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Job Type</label>
                <select class="form-select" id="reportJobType" name="jobType" data-selected="<%=safe(request.getAttribute("jobType"))%>">
                    <option value="">Loading job types...</option>
                </select>
            </div>
            <div class="col-md-6 col-xl-2">
                <label class="form-label">Location</label>
                <input class="form-control" type="text" name="location" placeholder="Location" list="reportLocationList" value="<%=safe(request.getAttribute("location"))%>"/>
                <datalist id="reportLocationList"></datalist>
            </div>
            <div class="col-md-6 col-xl-1 d-flex align-items-end">
                <button class="btn btn-primary w-100" type="submit">Apply</button>
            </div>
            <div class="col-md-6 col-xl-2 d-flex align-items-end">
                <a class="btn btn-outline-secondary w-100" href="<%=request.getContextPath()%>/reports/jobs">Reset</a>
            </div>
        </form>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Visible Posts</div><div class="kpi-value"><%=safe(request.getAttribute("resultCount"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Total Jobs</div><div class="kpi-value"><%=safe(request.getAttribute("totalJobs"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Total Internships</div><div class="kpi-value"><%=safe(request.getAttribute("totalInternships"))%></div></div></div>
        <div class="col-md-6 col-xl-3"><div class="app-card kpi-card"><div class="kpi-label">Hiring Companies</div><div class="kpi-value"><%=safe(request.getAttribute("hiringCompanies"))%></div></div></div>
    </div>

    <div class="app-card app-section">
        <div class="section-head">
            <div>
                <h2 class="h5 mb-1">Opportunity Results</h2>
                <p class="section-muted">Current jobs and internships matching the selected filters.</p>
            </div>
            <span class="meta-chip"><%=safe(request.getAttribute("resultCount"))%> result(s)</span>
        </div>
        <div class="opportunity-list">
            <%
                List<String[]> rows = (List<String[]>) request.getAttribute("rows");
                if (rows != null && !rows.isEmpty()) {
                    for (String[] row : rows) {
            %>
            <div class="opportunity-card">
                <div class="opportunity-meta">
                    <span class="meta-chip"><%=safe(row[1])%></span>
                    <span class="meta-chip"><%=safe(row[5])%></span>
                    <span class="meta-chip"><%=safe(row[4])%></span>
                </div>
                <h3><%=safe(row[2])%></h3>
                <p class="section-muted mb-2"><%=safe(row[3])%> • Posted <%=safe(row[9])%></p>
                <p class="mb-2"><%=safe(row[6])%></p>
                <div class="dashboard-note">
                    <% if (!safe(row[7]).isEmpty()) { %>Duration <%=safe(row[7])%> months • <% } %>
                    <% if (!safe(row[8]).isEmpty()) { %>Stipend <%=safe(row[8])%> • <% } %>
                    Opportunity ID <%=safe(row[0])%>
                </div>
            </div>
            <%      }
                } else { %>
            <div class="empty-state">No jobs or internships found for the selected filters.</div>
            <% } %>
        </div>
    </div>

    <footer class="page-footer">&copy; 2026 DANPSS | Opportunity Intelligence Report</footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/app-ui.js"></script>
</body>
</html>

